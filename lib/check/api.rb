require 'grape'
#require 'grape-swagger'

require_relative 'api/metrics'

module Check
  class API < Grape::API
    default_format :json
    error_format :json
    format :json

    KEY = ENV.fetch('API_KEY') { false }

    helpers do
      def authorize!
        if API::KEY
          unless params[:key] == API::KEY
            throw :error,
                  :message => { :errors => { :key => ['invalid'] } },
                  :status  => 401
          end
        end
      end
    end

    before { authorize! }

    mount Metrics
    # add_swagger_documentation(mount_path: '/swagger')
    #
    # TODO: would have been very nice to get this working, but grape-swagger
    # looks broken and I can't look into a fix for the initial release.
    #
    #   1. All REST methods get .json format hardcoded
    #
    #   2. When testing, all requests get sent with the OPTIONS method, even
    #   though they are clearly defined as POST, DELETE etc.
    #
    # In the meantime, let's expose all routes
    resources :routes do
      # This should have been the default route, but grape requires a fix for this:
      # https://github.com/intridea/grape/issues/86
      desc 'The current page, showing details about all available routes'
      get do
        Metrics.routes.map { |route| route.instance_variable_get(:@options) }
      end
    end

  end
end
