Slack Ruby Bot Server Mailchimp Extension
=========================================

[![Gem Version](https://badge.fury.io/rb/slack-ruby-bot-server-mailchimp.svg)](https://badge.fury.io/rb/slack-ruby-bot-server-mailchimp)
[![Build Status](https://travis-ci.org/slack-ruby/slack-ruby-bot-server-mailchimp.svg?branch=master)](https://travis-ci.org/slack-ruby/slack-ruby-bot-server-mailchimp)

A lifecycle extension to [slack-ruby-bot-server](https://github.com/slack-ruby/slack-ruby-bot-server) that subscribes new bot users to a Mailchimp mailing list.

### Usage

Add 'slack-ruby-bot-server-mailchimp' to Gemfile.

```ruby
gem 'slack-ruby-bot-server-mailchimp'
```

Configure.

```ruby
SlackRubyBotServer::Mailchimp.configure do |config|
  config.mailchimp_api_key = ENV['MAILCHIMP_API_KEY'] # defaults to ENV['MAILCHIMP_API_KEY']
  config.mailchimp_list_id = ENV['MAILCHIMP_LIST_ID'] # defaults to ENV['MAILCHIMP_LIST_ID']
  config.additional_member_tags = ['my_bot'] # any additional Mailchimp member tags
  config.additional_merge_fields = { 'BOT' => 'MyBot' } # any additional Mailchimp member merge fields
end
```

Users that install the bot are automatically subscribed via [bot server lifecycle](lib/slack-ruby-bot-server/mailchimp/lifecycle.rb).

### Team Tags

If your `Team` model responds to `.tags`, those will be merged onto member tags.

### Copyright & License

Copyright [Daniel Doubrovkine](http://code.dblock.org) and Contributors, 2019

[MIT License](LICENSE)
