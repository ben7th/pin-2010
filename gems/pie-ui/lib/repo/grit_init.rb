require "grit"

module RepoInit
  def self.included(base)
    base.class_eval do
      # 运行Repo.log(path),Repo.add(path),Repo.remove(path)
      # 当前 shell 的 工作目录 必须是版本库的命令
      # 否则会 不识别 path
      def log_with_change_dir(commit = 'master', path = nil, options = {})
        Dir.chdir(working_dir) do
          self.git.checkout({},path) if !path.nil?
          log_without_change_dir(commit, path, options)
        end
      end
      alias_method_chain :log,:change_dir

      # repo.add
      def add_with_change_dir(*files)
        Dir.chdir(working_dir) do
          add_without_change_dir(*files)
        end
      end
      alias_method_chain :add,:change_dir

      # repo.remove
      def remove_with_change_dir(*files)
        Dir.chdir(working_dir) do
          remove_without_change_dir(*files)
        end
      end
      alias_method_chain :remove,:change_dir

      # repo.move
      def move(old_path,new_path)
        Dir.chdir(working_dir) do
          self.git.mv({},old_path,new_path)
        end
      end

      # repo.rollback
      def rollback(commit_id)
        Dir.chdir(working_dir) do
          self.git.reset({:hard=>true},commit_id)
        end
      end

      # 实现 初始化 普通 版本库
      def self.init(path)
        # create directory
        git_path = File.join(path, ".git")

        # generate initial git directory
        if !File.exist?(git_path)
          git = Grit::Git.new(git_path)
          git.fs_mkdir("")
          git.init({:bare=>false})
        end

        # create new Grit::Repo on that dir, return it
        self.new(path,{})
      end
      
    end
  end
end

# 修正 commit.diffs 获得的 diff 对象数组中
# diff.a_blob,diff.b_blob 的 mime_type 错误
# 如果 diff.name 是空的话，mime_type 就没办法得到正确结果
module DiffInit
  def initialize(repo, a_path, b_path, a_blob, b_blob, a_mode, b_mode, new_file, deleted_file, diff, renamed_file = false, similarity_index = 0)
    @repo   = repo
    @a_path = a_path
    @b_path = b_path
    @a_blob = a_blob =~ /^0{40}$/ ? nil : Blob.create(repo, :id => a_blob, :name => File.basename(a_path))
    @b_blob = b_blob =~ /^0{40}$/ ? nil : Blob.create(repo, :id => b_blob, :name => File.basename(b_path))
    @a_mode = a_mode
    @b_mode = b_mode
    @new_file         = new_file     || @a_blob.nil?
    @deleted_file     = deleted_file || @b_blob.nil?
    @renamed_file     = renamed_file
    @similarity_index = similarity_index.to_i
    @diff             = diff
  end
end

module Grit
  class Git
    def run_with_args_flatten(prefix, cmd, postfix, options, args, &block)
      run_without_args_flatten(prefix, cmd, postfix, options, args.flatten, &block)
    end
    alias_method_chain :run,:args_flatten
  end
end