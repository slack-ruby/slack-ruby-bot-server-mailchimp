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
end
```

Users that install the bot are automatically subscribed via [bot server lifecycle](lib/slack-ruby-bot-server/mailchimp/lifecycle.rb).

### Additional Member Tags

If your `Team` model responds to `.tags`, those will be attached to new subscriptions and appear as "tags" in Mailchimp. You can also supplement member tags for new subscriptions through `member_tags` configuration.

```ruby
SlackRubyBotServer::Mailchimp.config.member_tags = ['my_bot']
```

### Additional Profile Information

The default member profile information that appears in Mailchimp under "Profile Information" for each new subscriber contains the user's email address, first and last name from Slack. You can supplement this data with `additional_merge_fields`.

```ruby
SlackRubyBotServer::Mailchimp.config.additional_merge_fields = { 'BOT' => 'MyBot' }
```

### Double Opt-In

This integration subscribes users with double opt-in by default. Configure `member_status` to disable double opt-in. See [this doc](https://developer.mailchimp.com/documentation/mailchimp/guides/manage-subscribers-with-the-mailchimp-api) for more details.

```ruby
SlackRubyBotServer::Mailchimp.config.member_status = 'subscribed'
```

### Copyright & License

Copyright [Daniel Doubrovkine](http://code.dblock.org) and Contributors, 2019

[MIT License](LICENSE)
