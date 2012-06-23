Mustacci.configure do |config|

  # Define what you want to do when the build was successful
  #
  # config.on_success do |build|
  # end

  # Define what you want to do when the build failed
  #
  # This example will notify campfire:
  #
  # config.on_failed do |build|
  #   require 'blaze'
  #   Blaze.configure do |c|
  #     c.room_id = 1234
  #     c.account = "37signals"
  #     c.token   = "123abc"
  #   end
  #   Blaze.speak "Build failed"
  # end

  # Set the hostname of your Mustacci server
  config.hostname = "mustacci.example.com"

  # Protect your github post receive notifications
  # You need to enter these in the URL you configure in Github:
  #
  #   http://username:password@mustacci.example.com:8081/github
  #
  # config.github_auth "username", "password"

  # For more configuration options, see the docs of Mustacci::Configuration

end
