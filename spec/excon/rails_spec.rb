module Excon
  describe Rails do
    before do
      stub_request(:any, 'example.com').to_return(body: 'OK')
    end

    after do
      if Rails::Railtie.instance.send(:instance_variable_defined?, :@ran)
        Rails::Railtie.instance.send(:remove_instance_variable, :@ran)
      end
    end

    it 'registers Excon middleware' do
      middlewares = ::Excon.defaults[:middlewares]
      expect(middlewares).to include(Excon::Rails::Middleware)
    end

    it 'initializes a Railtie' do
      expect(Excon::Rails::Railtie.superclass).to eq(::Rails::Railtie)
    end

    it 'logs runtimes' do
      stub_request(:any, 'example.com').to_return(body: 'OK')
      Rails::Railtie.run_initializers
      Excon.get('http://example.com')
      expect(Rails::LogSubscriber.runtime).to be > 0
    end

    it 'logs requests to logger' do
      @logger.level = Logger::DEBUG
      Rails::Railtie.run_initializers
      Excon.get('http://example.com')
      expect(@logger.logged(:debug)[0])
        .to match(%r{Excon Request \(\d+\.\d+ms\)  GET http://example\.com/})
    end
  end
end
