describe Excon::Rails::Middleware do
  Notifications = ActiveSupport::Notifications

  def with_subscription(channel)
    payloads = []
    Notifications.subscribe channel do |_name, _start, _finish, _id, payload|
      payloads << payload
    end
    yield
    Notifications.unsubscribe channel
    payloads
  end

  before :each do
    stub_request(:any, 'example.com').to_return(body: 'abc', status: 200)
    stub_request(:any, 'example.com/timeout').to_timeout
    stub_request(:any, 'example.com/retry').to_return(status: 400)
  end

  it 'emits events for requests' do
    received = with_subscription 'request.excon' do
      Excon.get('http://example.com')
    end
    expect(received.length).to eq(1)
  end

  it 'emits events for responses' do
    payloads = with_subscription 'response.excon' do
      Excon.get('http://example.com')
    end
    statuses = payloads.map { |payload| payload[:status] }
    ActiveSupport::Notifications.unsubscribe 'response.excon'
    expect(statuses).to eq([200])
  end

  it 'emits events for retried requests' do
    retries = with_subscription 'retry.excon' do
      connection = Excon.new('http://example.com/retry')
      begin
        connection.request(expects: [200], idempotent: true, retry_limit: 3)
      rescue Excon::Errors::BadRequest
      end
    end

    expect(retries.length).to eq(2)
  end

  it 'emits events for errors' do
    errors = with_subscription 'error.excon' do
      begin
        Excon.get('http://example.com/timeout')
      rescue Excon::Errors::Timeout
      end
    end
    expect(errors.length).to eq(1)
  end
end
