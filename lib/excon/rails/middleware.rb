require 'excon'

module Excon
  module Rails
    # Middleware for tracking requests
    class Middleware < Excon::Middleware::Base
      class << self
        def install
          index = ::Excon.defaults[:middlewares]
            .index(::Excon::Middleware::Instrumentor)
          ::Excon.defaults[:middlewares].insert(index || -1, self)
        end
      end

      def error_call(datum)
        ActiveSupport::Notifications
          .instrument('error.excon', error: datum[:error])
        @stack.error_call(datum)
      end

      def request_call(datum)
        ActiveSupport::Notifications.instrument(event_name(datum), datum) do
          @stack.request_call(datum)
        end
      end

      def response_call(datum)
        ActiveSupport::Notifications
          .instrument('response.excon', datum[:response])
        @stack.response_call(datum)
      end

      private

      def event_name(datum)
        if datum[:retries_remaining] < datum[:retry_limit]
          'retry.excon'
        else
          'request.excon'
        end
      end
    end
  end
end
