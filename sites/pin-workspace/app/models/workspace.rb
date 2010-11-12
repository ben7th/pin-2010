class Workspace < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :user

  after_create :create_repository
  def create_repository
    WorkspaceGitRepository.create(:user=>self.user,:repo_name=>self.id)
  end

  module UserMethods
    def self.included(base)
      base.has_many :workspaces
    end
  end

  include Membership::WorkspaceMethods
  include FileEntry::WorkspceMethods
end
