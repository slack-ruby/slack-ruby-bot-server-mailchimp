require 'slack-ruby-bot-server'
require 'slack-ruby-bot-server/mailchimp/version'
require "slack-ruby-bot-server/config/database_adapters/#{SlackRubyBotServer::Config.database_adapter}.rb"
