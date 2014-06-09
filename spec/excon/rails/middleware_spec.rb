describe Excon::Rails::Middleware do
  before :each do
    stub_request(:any, 'example.com').to_return(body: 'abc', status: 200)
    stub_request(:any, 'example.com/timeout').to_timeout
    stub_request(:any, 'example.com/retry').to_return(status: 400)
  end

  it 'emits events for requests' do
    received = 0
    ActiveSupport::Notifications.subscribe 'request.excon' do
      received += 1
    end
    Excon.get('http://example.com')
    ActiveSupport::Notifications.unsubscribe 'request.excon'
    expect(received).to eq(1)
  end

  it 'emits events for responses' do
    statuses = []
    ActiveSupport::Notifications.subscribe 'response.excon' do |name, start, finish, id, payload|
      statuses << payload[:status]
    end
    Excon.get('http://example.com')
    ActiveSupport::Notifications.unsubscribe 'response.excon'
    expect(statuses).to eq([200])
  end

  it 'emits events for retried requests' do
    retries = 0
    ActiveSupport::Notifications.subscribe 'retry.excon' do
      retries += 1
    end
    connection = Excon.new('http://example.com/retry')
    begin
      connection.request(expects: [200], idempotent: true, retry_limit: 3)
    rescue Excon::Errors::BadRequest
    end
    expect(retries).to eq(2)
    ActiveSupport::Notifications.unsubscribe 'retry.excon'
  end

  it 'emits events for errors' do
    errors = 0
    ActiveSupport::Notifications.subscribe 'error.excon' do
      errors += 1
    end
    begin
      Excon.get('http://example.com/timeout')
    rescue Excon::Errors::Timeout
    end
    expect(errors).to eq(1)
    ActiveSupport::Notifications.unsubscribe 'error.excon'
  end
end
