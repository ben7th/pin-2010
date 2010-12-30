module MindmapImageMethods

  # 本地文件上传到版本库
  def upload_file_to_repo(file)
    # 文件名
    name_suffix = file_name_suffix_from_path(file.original_filename)
    file_name = "#{randstr(8)}.#{name_suffix}"
    # 把文件提交到版本库
    add_file_to_repo(file_name,file.path)
    return file_name
  rescue Exception => ex
    raise UploadError,ex.message
  end

  # 得到外站贴图，并上传到版本库
  def upload_web_file_to_repo(url)
    # 文件内容
    file_content = HandleGetRequest.get_response_from_url(url);
    # 文件名称
    name_suffix = file_name_suffix_from_url(url)
    file_name = "#{randstr(8)}.#{name_suffix}"
    file_path = File.join("tmp",file_name)
    # 建立 临时文件
    file = File.new(file_path, "w")
    file.write(file_content)
    file.close
    # 增加文件到版本库
    add_file_to_repo(file_name,file_path)
    # 删除临时文件
    FileUtils.rm(file_path)
    return file_name
  rescue Exception => ex
    raise UploadError,ex.message
  end

  def upload_file_absolute_path(file_name)
    File.join(self.note_repo_path,file_name)
  end

  def images
    repo = self.note_repo
    commit = repo.commit("master")
    contents = commit ? commit.tree.contents : []
    contents.map do |item|
      item.name if item.instance_of?(Grit::Blob) && item.mime_type.match("image")
    end.compact
  rescue
    []
  end

  class UploadError < StandardError;end

  private
  def file_name_suffix_from_url(url)
    fname = URI.parse(url).path.split("/").last
    file_name_suffix_from_name(fname)
  end

  def add_file_to_repo(file_name,tmp_file_path)
    # 增加一个文件到版本库
    note_repo_tmp = self.note_repo
    # 设置提交者
    MpGitTool.set_commiter(note_repo_tmp,self.user)
    # 把文件写入版本库
    absolute_file_path = File.join(note_repo_tmp.working_dir,file_name)

    FileUtils.copy_file(tmp_file_path,absolute_file_path)
    note_repo_tmp.add(file_name)
    # 提交版本库
    note_repo_tmp.commit_index("添加文件 #{file_name}")
  end

  def file_name_suffix_from_path(file_path)
    fname = file_path.split("/").last
    file_name_suffix_from_name(fname)
  end

  def file_name_suffix_from_name(file_name)
    name_splits = file_name.split(".")
    name_suffix = name_splits.last
    name_suffix = "data" if name_splits.count == 0
    name_suffix
  end
end