SlackRubyBotServer::Config.service_class.instance.on :created do |team, _error, options|
  raise 'missing ENV["MAILCHIMP_API_KEY"]' unless SlackRubyBotServer::Mailchimp.config.mailchimp_api_key
  raise 'missing ENV["MAILCHIMP_LIST_ID"]' unless SlackRubyBotServer::Mailchimp.config.mailchimp_list_id

  mailchimp_client = Mailchimp.connect(SlackRubyBotServer::Mailchimp.config.mailchimp_api_key)
  mailchimp_list = mailchimp_client.lists(SlackRubyBotServer::Mailchimp.config.mailchimp_list_id)

  slack_client = Slack::Web::Client.new(token: team.token)

  # fetch profile of the user installing the bot
  raise 'missing team.activated_user_id' unless team.activated_user_id

  profile = Hashie::Mash.new(slack_client.users_info(user: team.activated_user_id)).user.profile
  raise "error fetching user profile for #{team.activated_user_id}" unless profile

  # fetch and merge member tags
  tags = SlackRubyBotServer::Mailchimp.config.additional_member_tags
  tags = tags.call(team, options) if tags.respond_to?(:call)
  tags = (tags + team.tags).uniq if team.respond_to?(:tags)

  member = mailchimp_list.members.where(email_address: profile.email).first
  if member
    member_tags = member.tags.map { |tag| tag['name'] }.sort
    tags = (member_tags + tags).uniq
    if tags == member_tags
      SlackRubyBot::Client.logger.debug "Skipping #{profile.email} with identical tags (#{tags.join(', ')}), will not be added to #{SlackRubyBotServer::Mailchimp.config.mailchimp_list_id}, #{team}."
      next
    end
  end

  # merge fields
  merge_fields = SlackRubyBotServer::Mailchimp.config.additional_merge_fields
  merge_fields = merge_fields.call(team, options) if merge_fields.respond_to?(:call)
  merge_fields = merge_fields.merge(
    'FNAME' => profile.first_name.to_s,
    'LNAME' => profile.last_name.to_s
  )

  # subscribe
  mailchimp_list.members.create_or_update(
    name: profile.name,
    email_address: profile.email,
    unique_email_id: "#{team.team_id}-#{team.activated_user_id}",
    status: member ? member.status : SlackRubyBotServer::Mailchimp.config.member_status,
    tags: tags,
    merge_fields: merge_fields
  )

  SlackRubyBot::Client.logger.info "Subscribed #{profile.email} to #{SlackRubyBotServer::Mailchimp.config.mailchimp_list_id}, #{team}."
end
