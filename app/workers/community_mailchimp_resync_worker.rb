class CommunityMailchimpResyncWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mailchimp_synchro, retry: 1

  def perform(community_id)
    resource = Community.find community_id
    resource.widgets.find_each do |w|
      w.resync_all
    end
  end
end
