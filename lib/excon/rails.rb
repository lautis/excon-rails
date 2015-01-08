require 'excon/rails/version'
require 'excon/rails/middleware'
require 'sweet_notifications'
require 'active_support'
require 'excon'

module Excon
  module Rails
    Middleware.install

    Railtie, LogSubscriber = SweetNotifications.subscribe :excon,
                                                          label: 'Excon' do
      color ActiveSupport::LogSubscriber::BLUE

      event :request do |event|
        next unless logger.debug?
        debug request_info(event)
      end

      event :response do |event|
        next unless logger.debug?
        debug message(event, 'Excon Response',
                      "#{status(event)} (#{length(event)})")
      end

      event :retry do |event|
        next unless logger.debug?
        debug request_info(event)
      end

      event :error do |event|
        next unless logger.info?
        info message(event, 'Excon Error', event.payload[:error])
      end

      private

      def length(event)
        ActiveSupport::NumberHelper::NumberToHumanSizeConverter
          .convert(event.payload[:body].length, {})
      end

      def status(event)
        status_code = event.payload[:status]
        status_message = Rack::Utils::HTTP_STATUS_CODES[status_code]
        "#{status_code} #{status_message}"
      end

      def request_info(event)
        payload = event.payload
        url = "#{payload[:scheme]}://#{payload[:host]}#{payload[:path]}"
        type = event.name.split('.').first.titleize
        method = event.payload[:method].try(:upcase)
        message(event, "Excon #{type}", [method, url].compact.join(' '))
      end
    end
  end
end
