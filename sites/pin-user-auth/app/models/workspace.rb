class Workspace < WorkspaceAbstract
  set_readonly(true)

  belongs_to :user
end
