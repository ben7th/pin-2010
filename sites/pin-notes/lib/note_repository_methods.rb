module NoteRepositoryMethods
  module ClassMethods
    def fork(old_note,user)
      attrs = {}
      attrs[:user_id] = user.id
      attrs[:private] = false
      attrs[:fork_from_data] = {:note_id=>old_note.id,:email=>old_note.user.email}.to_json
      note = Note.create(attrs)
      FileUtils.rm_rf(note.repository_path)
      old_note.grit_repo.fork_bare(note.repository_path,{:bare => false,:shared=>false})
      note
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end


  if RAILS_ENV != "test"
    REPO_BASE_PATH = YAML.load(CoreService.project("pin-notes").settings)[:note_repo_path]
  else
    REPO_BASE_PATH = "/root/mindpin_base/note_repo_test"
  end

  REPOSITORIES_PATH = "#{REPO_BASE_PATH}/notes"

  NOTE_FILE_PREFIX = "notefile_"

  BLOB_CACHE_PATH = "#{REPO_BASE_PATH}/blob_cache"

  # 找到版本库
  def grit_repo(reload = false)
    @grit_repo = _grit_repo if reload
    @grit_repo ||= _grit_repo
  end

  # 版本库在硬盘中的路径
  def repository_path
    id_path = self.private ? self.private_id : self.id
    "#{REPOSITORIES_PATH}/#{id_path}"
  end

  # 用户的 回收站 地址
  def recycler_path
    "#{REPO_BASE_PATH}/deleted/users/#{self.user.id}"
  end

  # 编辑文本片段
  # submit_text_hash 格式
  # {"notefile_1"=>"xx","notefile_2"=>"yy"...}
  # rename_hash 格式
  # {"旧名字"=>"新名字"...}
  def save_text_hash!(submit_text_hash,rename_hash = {})
    # 设置提交者
    set_creator_as_commiter
    # 对比 self.text_hash 和 submit_text_hash 找到需要写入的 文本片段
    write_hash = find_text_hash_of_need_to_write(submit_text_hash)
    # 对文件片段 进行改名,改名必须在 修改文件前
    # 比如 a 文件 改名 b 文件 和 增加或修改 b 文件内容 同时存在时
    # 必须先给文件改名，在进行增加修改操作，不然改名会失败
    rename_notefiles(rename_hash)
    # 把 文本片段 写入文件
    create_or_update_notefiles(write_hash)
    # 对比 self.text_hash 和 submit_text_hash, rename_hash 找到要删除的文件
    delete_names = self.text_hash.keys - submit_text_hash.keys - rename_hash.keys
    # 删除 文本片段
    delete_notefiles(delete_names)
    # 提交到版本库
    grit_repo.commit_index("##")
    # 创建搜索索引
    NoteLucene.add_index(self) if !self.private
  end

  # 得到 所有提交数组
  def commits
    grit_repo.commits
  end

  def ref_commits
    Grit::Commit.find_all(grit_repo,"master",{:g=>true})
  end

  # 根据 commit_id 得到 对应的 提交对象
  def commit(commit_id)
    grit_repo.commit(commit_id)
  end

  # 得到所有的版本号,新版本号在数组的前面
  def commit_ids
    grit_repo.commits.map{|commit|commit.id}
  end

  # 得到某一个版本下的 所有 文本片段
  def text_hash(commit_id = "master")
    hash = {}
    _notefile_blob(commit_id).map do |blob|
      hash[blob.name] = blob.data
    end
    hash
  end

  # 得到某一个版本下的所有 blob
  def blobs(commit_id = "master",options={:order=>"created_at"})
    blobs = _notefile_blob(commit_id).map do |blob|
      commits = grit_repo.log(commit_id,blob.name)
      updated_at = commits.first.date
      created_at = commits.last.date
      NoteBlob.new({:id=>blob.id,:basename=>blob.name,:data=>blob.data,:mime_type=>blob.mime_type,
          :updated_at=>updated_at,:created_at=>created_at})
    end
    blobs = case options[:order]
    when "created_at" then blobs.sort{|blob_1,blob_2|blob_1.created_at <=> blob_2.created_at}
    when "updated_at" then blobs.sort{|blob_1,blob_2|blob_1.updated_at <=> blob_2.updated_at}
    end
    blobs
  end

  # 增加一个文件到版本库
  def add_file!(file)
    # 设置提交者
    set_creator_as_commiter
    # 把文件写入版本库
    file_name = file.original_filename
    absolute_file_path = File.join(repository_path,file_name)

    FileUtils.copy_file(file.path,absolute_file_path)
    grit_repo.add(file_name)
    # 提交版本库
    grit_repo.commit_index("##")
  end

  def fork_from
    return nil if self.fork_from_data.blank?
    json = ActiveSupport::JSON.decode(self.fork_from_data)
    json.each_key do |key|
      value = json.delete(key)
      json[key.to_sym] = value
    end
    json
  end

  # 把 note 中的内容打成 zip 包，返回磁盘文件路径 文件名是 utf8编码
  def zip_pack(commit_id = "master")
    _zip_pack(commit_id ,"utf8")
  end

  # 把 note 中的内容打成 zip 包，返回磁盘文件路径 文件名是 gbk编码
  def windows_zip_pack(commit_id = "master")
    _zip_pack(commit_id ,"gbk")
  end

  private

  # 代表 文件片段的 blob 对象数组
  def _notefile_blob(commit_id)
    contents = grit_repo.commit(commit_id) ? grit_repo.commit(commit_id).tree.contents : []
    contents.select do |item|
      item.instance_of?(Grit::Blob) && item.name != ".git"
    end
  end

  # 把 文本片段 写入文件
  def create_or_update_notefiles(write_hash)
    write_hash.each do |name,text|
      # 根据 text 生成文件
      absolute_file_path = File.join(repository_path,name)
      File.open(absolute_file_path,"w") do |f|
        f << text
      end
    end
    if write_hash.keys.size != 0
      grit_repo.add(write_hash.keys)
    end
  end

  # 对 文件片段 进行改名
  def rename_notefiles(rename_hash)
    rename_hash.each do |old_name,new_name|
      grit_repo.move(old_name, new_name)
    end
  end

  # 设置提交者为版本库的创建者
  def set_creator_as_commiter
    _user = self.user
    name = !!_user ? _user.name : "anonymous"
    email = !!_user ? _user.email : "anonymous@mindpin.com"
    grit_repo.config['user.name'] = name
    grit_repo.config['user.email'] = email
  end

  # 对比 self.text_hash 和 submit_text_hash 找到需要写入的 文本片段
  def find_text_hash_of_need_to_write(submit_text_hash)
    old_hash = self.text_hash
    need_write_hash = {}
    # 对比 self.text_hash 和 submit_text_hash 找到要编辑的文本 和 新增的文本
    submit_text_hash.each do |name,text|
      is_new = old_hash[name].blank?
      is_edit = (old_hash[name] != text)
      need_write_hash[name] = text if is_new || is_edit
    end
    need_write_hash
  end

  # 删除文件
  def delete_notefiles(delete_names)
    delete_names.each do |notefile_name|
      absolute_file_path = File.join(repository_path,notefile_name)
      raise "要删除的文件不存在" if !File.exist?(absolute_file_path)
      grit_repo.remove(notefile_name)
    end
  end

  def _grit_repo
    path = self.repository_path
    return nil if !File.exist?(path)
    Grit::Repo.new(path)
  end

  # 创建一个 git 版本库
  def init_repo
    _path = self.repository_path
    g = Grit::Repo.init(_path)
    # git config core.quotepath false
    # core.quotepath设为false的话，就不会对0x80以上的字符进行quote。中文显示正常
    g.config["core.quotepath"] = "false"
  end

  # 删除一个版本库
  # 其实是把该版本库 放入 回收站 目录
  def delete_repo
    return false if !File.exist?(self.repository_path)
    recycle_path = self.recycler_path
    FileUtils.mkdir_p(recycle_path) if !File.exist?(recycle_path)
    `mv #{self.repository_path} #{recycle_path}/#{self.id}_#{randstr}`
    return true
  end

  def _zip_pack(commit_id ,file_name_coding)
    zip_path = File.join(Dir::tmpdir,UUIDTools::UUID.random_create.to_s)
    zip = Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE)
    text_hash = self.text_hash(commit_id)

    # 在压缩包中创建文件
    text_hash.each do |file_name,file_content|
      path = "notes_#{self.nid}/#{file_name}"
      path = path.utf8_to_gbk if file_name_coding == "gbk"
      zip.get_output_stream(path){|f|f.puts file_content}
    end

    # 在压缩包中创建 manifest 文件
    zip.get_output_stream("manifest") do |f|
      f.puts "#{self.nid}";f.puts "#{commit_id}";f.puts ""
      text_hash.each{|file_name,file_content|f.puts file_name}
    end

    zip.close
    return zip_path
  end

  # private end

end