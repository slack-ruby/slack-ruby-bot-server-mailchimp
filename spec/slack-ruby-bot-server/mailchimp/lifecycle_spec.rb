require 'spec_helper'

describe SlackRubyBotServer::Mailchimp do
  let(:team) { Fabricate(:team, activated_user_id: 'activated_user_id') }
  let(:list) { double(Mailchimp::List, members: double(Mailchimp::List::Members)) }

  before do
    SlackRubyBotServer::Mailchimp.configure do |config|
      config.mailchimp_api_key = 'api-key'
      config.mailchimp_list_id = 'list-id'
    end

    allow_any_instance_of(Slack::Web::Client).to receive(:users_info).with(
      user: 'activated_user_id'
    ).and_return(
      user: {
        profile: {
          email: 'user@example.com',
          first_name: 'First',
          last_name: 'Last'
        }
      }
    )

    allow_any_instance_of(Mailchimp::Client).to receive(:lists).with('list-id').and_return(list)

    allow(SlackRubyBotServer::Config.service_class.instance).to receive(:start!).with(team)
  end

  after do
    SlackRubyBotServer::Mailchimp.config.reset!
  end

  context 'new subscription' do
    before do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return([])
    end

    it 'subscribes the activating user' do
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: {
          'FNAME' => 'First',
          'LNAME' => 'Last'
        },
        status: 'pending',
        name: nil,
        tags: %w[],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )

      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end

    context 'with custom member status' do
      before do
        SlackRubyBotServer::Mailchimp.config.member_status = 'subscribed'
      end
      it 'subscribes the activating user with a different status' do
        expect(list.members).to receive(:create_or_update).with(hash_including(status: 'subscribed'))
        SlackRubyBotServer::Config.service_class.instance.create!(team)
      end
    end
  end

  context 'with tags' do
    before do
      allow_any_instance_of(Team).to receive(:tags).and_return(['trial'])
    end

    it 'merges tags' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return(
        [
          double(
            Mailchimp::List::Member,
            tags: [{ 'id' => 1513, 'name' => 'subscribed' }, { 'id' => 1525, 'name' => 'something' }],
            status: 'subscribed'
          )
        ]
      )
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: {
          'FNAME' => 'First',
          'LNAME' => 'Last'
        },
        status: 'subscribed',
        name: nil,
        tags: %w[something subscribed trial],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end

    it 'does not attempt to create a new pending subscription' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return(
        [
          double(
            Mailchimp::List::Member,
            tags: [
              { 'id' => 1234, 'name' => 'trial' },
              { 'id' => 1513, 'name' => 'subscribed' },
              { 'id' => 1525, 'name' => 'mailbot' }
            ],
            status: 'pending'
          )
        ]
      )
      expect(list.members).to_not receive(:create_or_update)
      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end
  end

  context 'with globally configured tags' do
    before do
      SlackRubyBotServer::Mailchimp.config.additional_member_tags = ['mailbot']
    end

    it 'uses tags' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return([])
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: { 'FNAME' => 'First', 'LNAME' => 'Last' },
        status: 'pending',
        name: nil,
        tags: %w[mailbot],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end

    it 'merges tags' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return(
        [
          double(
            Mailchimp::List::Member,
            tags: [{ 'id' => 1513, 'name' => 'subscribed' }, { 'id' => 1525, 'name' => 'something' }],
            status: 'subscribed'
          )
        ]
      )
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: { 'FNAME' => 'First', 'LNAME' => 'Last' },
        status: 'subscribed',
        name: nil,
        tags: %w[something subscribed mailbot],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end
  end

  context 'with dynamic tags' do
    before do
      SlackRubyBotServer::Mailchimp.config.additional_member_tags = ->(team, _options) { [team.id.to_s] }
    end

    it 'uses tags' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return([])
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: { 'FNAME' => 'First', 'LNAME' => 'Last' },
        status: 'pending',
        name: nil,
        tags: [team.id.to_s],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end

    it 'merges tags' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return(
        [
          double(
            Mailchimp::List::Member,
            tags: [{ 'id' => 1513, 'name' => 'subscribed' }, { 'id' => 1525, 'name' => 'something' }],
            status: 'subscribed'
          )
        ]
      )
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: { 'FNAME' => 'First', 'LNAME' => 'Last' },
        status: 'subscribed',
        name: nil,
        tags: ['something', 'subscribed', team.id.to_s],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end
  end

  context 'with globally configured merge fields' do
    before do
      SlackRubyBotServer::Mailchimp.config.additional_merge_fields = { 'BOT' => 'MailBot' }
    end

    it 'merges fields' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return([])
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: {
          'BOT' => 'MailBot',
          'FNAME' => 'First',
          'LNAME' => 'Last'
        },
        status: 'pending',
        name: nil,
        tags: %w[],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end
  end

  context 'with globally configured dynamic merge fields' do
    before do
      SlackRubyBotServer::Mailchimp.config.additional_merge_fields = ->(team, _options) { { 'ID' => team.id.to_s } }
    end

    it 'merges fields' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return([])
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: {
          'ID' => team.id.to_s,
          'FNAME' => 'First',
          'LNAME' => 'Last'
        },
        status: 'pending',
        name: nil,
        tags: %w[],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      SlackRubyBotServer::Config.service_class.instance.create!(team)
    end
  end
end
