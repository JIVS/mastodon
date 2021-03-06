# frozen_string_literal: true

class AfterRemoteFollowRequestWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(follow_request_id)
    follow_request  = FollowRequest.find(follow_request_id)
    updated_account = FetchRemoteAccountService.new.call(follow_request.target_account.remote_url)

    return if updated_account.locked?

    follow_request.destroy
    FollowService.new.call(follow_request.account, updated_account.acct)
  end
end
