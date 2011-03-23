module FeedCommentProxy
  module UserMethods
    def being_replied_comments
      UserBeingRepliedCommentsProxy.new(self).xxxs_ids.map do |id|
        FeedComment.find_by_id(id)
      end.compact
    end
  end
end
