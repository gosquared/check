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
            typecast_value = if v.match(/^\d+$/)
              v.to_i
            elsif v.index(',')
              v.split(',')
            else
              v
            end
            result[k.to_sym] = typecast_value
          end
          result
        end
      end
    end

    resource :metric do
      desc 'List all matching metric checks'
      params do
        optional :name, :type => String, :desc => "Name of metric check"
      end
      get do
        metric_check = Metric.find(metric_params)

        if metric_check.persisted?
          metric_check.similar.to_json
        else
          []
        end
      end

      desc 'Delete all matching metric checks'
      params do
        requires :name, :type => String, :desc => "Name of metric check"
      end
      delete do
        Metric.delete_all(params[:name])
      end
    end

    resources :metrics do
      desc 'Create metric check'
      params do
        requires :name, :type => String, :desc => "Name of metric check"
      end
      post '/' do
        metric_check = Metric.new(metric_params).save
        [metric_check.name]
      end

      desc 'Delete specific metric check'
      delete '/' do
        Metric.find(metric_params).delete
      end

      desc 'Delete all matching metric checks'
      params do
        requires :name, :type => String, :desc => "Name of metric check"
      end
      delete '/:name' do
        Metric.delete_all(params[:name])
      end

      desc 'List all matching metric checks'
      params do
        optional :name, :type => String, :desc => "Name of metric check"
      end
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
