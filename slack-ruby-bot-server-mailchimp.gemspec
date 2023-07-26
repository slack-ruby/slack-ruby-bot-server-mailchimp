lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack-ruby-bot-server/mailchimp/version'

Gem::Specification.new do |spec|
  spec.name          = 'slack-ruby-bot-server-mailchimp'
  spec.version       = SlackRubyBotServer::Mailchimp::VERSION
  spec.authors       = ['Daniel Doubrovkine']
  spec.email         = ['dblock@dblock.org']

  spec.summary       = 'Mailchimp extension for slack-ruby-bot-server.'
  spec.homepage      = 'https://github.com/slack-ruby/slack-ruby-bot-server-mailchimp'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mailchimp_api_v3'
  spec.add_dependency 'slack-ruby-bot-server', '>= 2.0.1'
end
