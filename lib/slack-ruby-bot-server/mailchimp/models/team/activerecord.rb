require_relative 'methods'

class Team < ActiveRecord::Base
  include SlackRubyBotServer::Mailchimp::Models::Team::Methods
end
