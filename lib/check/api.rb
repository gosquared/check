require_relative '../check/metric'

require 'grape'

module Check
  class API < Grape::API

    KEY = ENV.fetch('CHECK_API_KEY') { false }

    default_format :json
    error_format :json
    format :json

    helpers do
      def authorize!
        if API::KEY
          unless params[:key] == API::KEY
            throw :error,
                  :message => { :errors => { :key => ["invalid"] } },
                  :status  => 401
          end
        end
      end
    end

    before { authorize! }

    resources :doc do
      # This should have been the default route, but grape requires a fix for this:
      # https://github.com/intridea/grape/issues/86
      desc 'The current page, showing details about all available routes'
      get do
        API.routes.map { |route| route.instance_variable_get(:@options) }
      end
    end

    resources :metrics do
      desc 'Create metric check'
      post '/' do
        metric_check = Metric.new(params).save

        if metric_check.valid?
          [metric_check.name]
        else
          error!({:errors => metric_check.errors.messages}, 409)
        end
      end

      desc 'Delete specific metric check'
      delete '/' do
        Metric.find(params).delete
      end

      desc 'Delete all matching metric checks'
      delete '/:metric_name' do
        Metric.delete_all(params[:metric_name])
      end

      desc 'List all matching metric checks'
      get '/' do
        metric_check = Metric.find(params)

        if metric_check.persisted?
          metric_check.similar
        else
          []
        end
      end
    end
  end
end
