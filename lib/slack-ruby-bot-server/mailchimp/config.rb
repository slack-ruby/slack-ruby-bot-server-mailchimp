module SlackRubyBotServer
  module Mailchimp
    module Config
      extend self

      attr_accessor :mailchimp_api_key
      attr_accessor :mailchimp_list_id
      attr_accessor :additional_member_tags
      attr_accessor :additional_merge_fields
      attr_accessor :member_status

      def reset!
        self.mailchimp_list_id = ENV['MAILCHIMP_LIST_ID']
        self.mailchimp_api_key = ENV['MAILCHIMP_API_KEY']
        self.additional_member_tags = []
        self.additional_merge_fields = {}
        self.member_status = 'pending'
      end

      reset!
    end

    class << self
      def configure
        block_given? ? yield(Config) : Config
      end

      def config
        Config
      end
    end
  end
end
