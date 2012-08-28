require_relative '../../check/metric'

require 'grape'

module Check
  class Metrics < Grape::API
    default_format :json
    error_format :json
    format :json

    helpers do
      # We'll do pretty some other time, promise!
      def metric_params
        params.inject({}) do |result, (k, v)|
          unless (k == "route_info")
            typecast_value = v.match(/^\d+$/) ? v.to_i : v
            result[k.to_sym] = typecast_value
          end
          result
        end
      end
    end

    resources :metrics do
      desc 'Create metric check'
      post '/' do
        metric_check = Metric.new(metric_params).save

        if metric_check.valid?
          [metric_check.name]
        else
          error!({:errors => metric_check.errors}, 409)
        end
      end

      desc 'Delete specific metric check'
      delete '/' do
        Metric.find(metric_params).delete
      end

      desc 'Delete all matching metric checks'
      delete '/:name' do
        Metric.delete_all(params[:name])
      end

      desc 'List all matching metric checks'
      get '/:name' do
        metric_check = Metric.find(metric_params)

        if metric_check.persisted?
          metric_check.similar.to_json
        else
          []
        end
      end
    end
  end
end
