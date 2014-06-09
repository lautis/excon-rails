require 'excon'

module Excon
  module Rails
    class Middleware < Excon::Middleware::Base
      class << self
        def install
          index = ::Excon.defaults[:middlewares].index(::Excon::Middleware::Instrumentor)
          ::Excon.defaults[:middlewares].insert(index || -1, self)
        end
      end

      def error_call(datum)
        ActiveSupport::Notifications.instrument('error.excon', error: datum[:error])
        @stack.error_call(datum)
      end

      def request_call(datum)
        event_name = if datum[:retries_remaining] < datum[:retry_limit]
          'retry.excon'
        else
          'request.excon'
        end
        ActiveSupport::Notifications.instrument(event_name, datum) do
          @stack.request_call(datum)
        end
      end

      def response_call(datum)
        ActiveSupport::Notifications.instrument('response.excon', datum[:response])
        @stack.response_call(datum)
      end
    end
  end
end
