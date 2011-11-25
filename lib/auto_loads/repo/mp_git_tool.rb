class MpGitTool
  # 在 path 初始化 一个版本库
  def self.init_repo(path)
    g = Grit::Repo.init(path)
    # git config core.quotepath false
    # core.quotepath设为false的话，就不会对0x80以上的字符进行quote。中文显示正常
    g.config["core.quotepath"] = "false"
  end

  # 设置提交者
  def self.set_commiter(git,user)
    name = !!user ? user.name : "anonymous"
    email = !!user ? user.email : "anonymous@mindpin.com"
    git.config['user.name'] = name
    git.config['user.email'] = email
  end

  # 增加一段文本片段
  # write_hash 举例 {file_name=>file_content,file_name=>file_content}
  def self.add_text_content!(git,user,write_hash,message="")
    Dir.chdir(git.working_dir) do
      # 设置提交者
      set_commiter(git,user)
      # 把内容写入版本库
      write_hash.each do |name,text|
        # 根据 text 生成文件
        absolute_file_path = File.join(git.working_dir,name)
        File.open(absolute_file_path,"w"){|f| f << text }
      end
      git.add(write_hash.keys) if write_hash.keys.size != 0
      # 提交版本库
      message = "add files" if message.blank?
      git.commit_index(message)
    end
  end

  # 删除一段文本片段
  def self.delete_file!(git,user,file_name)
    Dir.chdir(git.working_dir) do
      # 设置提交者
      set_commiter(git,user)
      # 删除文件
      delete_names = file_name.is_a?(Array) ? file_name : [file_name]
      delete_names.each do |fname|
        absolute_file_path = File.join(git.working_dir,fname)
        raise "要删除的文件不存在" if !File.exist?(absolute_file_path)
        git.remove(fname)
      end
      # 提交版本库
      git.commit_index("##")
    end
  end

  # 找到所有的提交（包括回滚操作）
  def self.ref_commits(git,path = "")
    # 改变目录是为了让  path 这个相对路径可以起作用
    Dir.chdir(git.working_dir) do
      Grit::Commit.find_all(git,["master",path],{:g=>true})
    end
  end

  def self.fork(src_git,des_git_path)
    FileUtils.rm_rf(des_git_path) if File.exist?(des_git_path)
    FileUtils.mkdir_p(File.dirname(des_git_path)) if !File.exist?(des_git_path)
    src_git.fork_bare(des_git_path,{:bare => false,:shared=>false})
  end

end
