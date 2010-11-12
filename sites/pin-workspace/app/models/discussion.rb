class Discussion < ActiveRecord::Base
  belongs_to :workspace
  set_readonly(true)
  build_database_connection("discuss")

  def document
    Document.find(:repo_user_id=>self.workspace.user_id,:repo_name=>self.workspace.id,:id=>self.id.to_s)
  end

end
