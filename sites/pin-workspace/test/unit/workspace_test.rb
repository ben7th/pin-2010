require 'test_helper'

class WorkspaceTest < ActiveSupport::TestCase
  test "创建工作空间的时候创建一个版本库" do
    repo_lifei = users(:repo_lifei)
    destroy_repositories(repo_lifei.id)

    assert_difference("Workspace.count",1) do
      workspace = Workspace.create(:name=>"我的工作空间",:user=>repo_lifei)
      assert File.exist?(WorkspaceGitRepository.repository_path( repo_lifei.id,workspace.id))
    end
    
    destroy_repositories(repo_lifei.id)
  end

  def destroy_repositories(user_id)
    FileUtils.rm_rf(WorkspaceGitRepository.user_repository_path(user_id))
  end
  
end
