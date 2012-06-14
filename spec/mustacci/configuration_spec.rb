require 'mustacci/configuration'

describe Mustacci::Configuration do

  it 'should load the configuration' do
    Mustacci::Configuration.stub!(:path).and_return('config/mustacci.example.yml')
    configuration = Mustacci::Configuration.load
    configuration.should_not be_nil
  end

end
