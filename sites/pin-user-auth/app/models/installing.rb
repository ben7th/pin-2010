class Installing < WorkspaceAbstract
  set_readonly(true)

  belongs_to :user
  belongs_to :app
end