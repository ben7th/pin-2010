require 'grit'
require 'pie-repo/git_repository_methods'
require 'pie-repo/git_repository'
require 'pie-repo/document'
require 'pie-repo/repository_commit'
require 'pie-repo/repository_diff'
require 'pie-repo/repository_file_info'
require 'pie-repo/text_pin'
require 'pie-repo/visible_config'
require 'pie-repo/discussion_log_parse'
require 'pie-repo/discussion_log_info'

require 'pie-repo/grit_init'
Grit::Repo.send(:include,RepoInit)
Grit::Diff.send(:include,DiffInit)