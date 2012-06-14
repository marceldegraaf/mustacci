require 'mustacci'
require 'webmock'

describe Mustacci::Campfire do
  include WebMock::API

  before do
    Mustacci::Configuration.stub!(:path).and_return('config/mustacci.example.yml')
  end

  around do |example|
    $stderr = StringIO.new
    example.run
    $stderr = STDERR
  end

  it 'should be able to speak' do
    token = "secret_token"
    room_id = "room_id"
    account = "campfire_subdomain"

    stub_request(:post, "https://#{token}:X@#{account}.campfirenow.com/room/#{room_id}/speak.json").
    with(:body => "{\"message\":{\"body\":\"O HAI\"}}",
         :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Mustacci::Campfire'}).
         to_return(:status => 200, :body => "", :headers => {})

    subject.speak "O HAI"
  end

end
