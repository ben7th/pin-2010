class DiscussionLogParse

  attr_reader :repo
  def initialize(workspace)
    @workspace = workspace
    @repo = GitRepository.find(workspace.user_id,workspace.id).repo
  end

  # 查询所有的workspace提交记录
  # 这里添加了document_tree的路径，就可以忽略掉 屏蔽操作
  def workspace_log_infos(emails=[])
    logs(emails, "document_tree")
  end

  # 这里查看的是讨论中某一个话题的提交记录
  def discussion_log_infos(discussion_id,emails=[])
    logs(emails, "document_tree/#{discussion_id}")
  end

  def logs(emails, path)
    emails_str = emails.map{|email| "<#{email}>"}*"\|"
    options = emails.blank? ? {} : {:author=>"#{emails_str}"}
    @repo.log("master",path,options).map do |commit|
      DiscussionLogInfo.build_from_commit(commit,@workspace)
    end
  end

end
