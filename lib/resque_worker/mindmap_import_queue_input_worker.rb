class MindmapImportQueueInputWorker

  INFO_HASH = "import_mindmap_info_hash"
  @queue = :mindmap_import_resque_queue
  @info_hash = RedisQueueHash.new(INFO_HASH)
  @complete_queue = RedisMessageQueue.new("import_mindmap_complete_queue")

  SETTINGS = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)
  IMPORT_FILE_BASE_PATH = SETTINGS["import_mindmap_file_base_path"]
  
  def self.async_import_mindmap_input(file_name,file,user)
    # 生成  qid
    qid = randstr(10)
    # 生成 hashinfo
    path = File.join(IMPORT_FILE_BASE_PATH,qid)
    FileUtils.mkdir_p(IMPORT_FILE_BASE_PATH) if !File.exist?(IMPORT_FILE_BASE_PATH)
    FileUtils.cp(file.path,path)
    info = HashInfo.build_input_hash_info(path,file_name,user)
    # 向  import_mindmap_infohash 放入 :qid=>hashinfo
    @info_hash.set(qid,info)
    Resque.enqueue(MindmapImportQueueInputWorker, qid)
    return qid
  end

  def self.perform(qid)
    return true if qid == "wake_up"
    info = @info_hash.get(qid)
    # 处理这个任务
    _info = MindmapImportQueueInputWorker.new.create_mindmap_and_image_and_build_complete_info_hash(info)
    # 处理完成后 放入 complete_queue
    @info_hash.set(qid,_info)
    @complete_queue.push(qid)
    return true
  end

  # 把一个将要被转换的导图文件 放入待处理队列
  def add_task(file_name,file,user)
    # 生成  qid
    qid = randstr(10)
    # 生成 hashinfo
    path = File.join(IMPORT_FILE_BASE_PATH,qid)
    FileUtils.mkdir_p(IMPORT_FILE_BASE_PATH) if !File.exist?(IMPORT_FILE_BASE_PATH)
    FileUtils.cp(file.path,path)
    info = HashInfo.build_input_hash_info(path,file_name,user)
    # 向  import_mindmap_infohash 放入 :qid=>hashinfo
    @info_hash.set(qid,info)
    # 向  import_mindmap_input_queue 队列放入 qid (push)
    @input_queue.push(qid)
    return qid
  end

  # 检测 qid 对应的任务 是否完成
  # {"loaded"=>true,"success"=>true,"id"=>mindmap.id}
  # {"loaded"=>true,"success"=>false}
  # {"loaded"=>false}
  def import_result(qid)
    return HashInfo.build_uncomplete_import_result if !@complete_queue.all.include?(qid)
    info = @info_hash.get(qid)
    remove_qid_and_hashinfo(qid)
    HashInfo.build_import_result_by_complete_hash_info(info)
  end

  # 定时运行这个方法，清理没有被用户删除的 完成数据
  def check_complete_queue_and_hash_info
    c_keys = @complete_queue.all
    i_keys = @input_queue.all
    hash_info_hash = @info_hash.all
    c_keys.each do |key|
      timestamp = hash_info_hash[key]["timestamp"]
      # 从完成队列里删除过时的 qid 和对应的 hashinfo
      if !!timestamp && (Time.now.to_f - timestamp) > 60
        p "清除 未被用户清除的 导入成功的任务 #{key}"
        remove_qid_and_hashinfo(key)
      end
    end
    h_keys = hash_info_hash.keys
    h_keys.each do |key|
      # 检查 info_hash 里是否有 complete_queue input_queue 都没有的qid 并删除
      if !i_keys.include?(key) && !c_keys.include?(key)
        p "清除 导入错误的任务 #{key}"
        @info_hash.remove(key)
      end
    end
  end

  def remove_qid_and_hashinfo(qid)
    # 删除 import_mindmap_complate_queue 的 qid
    @complete_queue.remove(qid)
    # 删除 在import_mindmap_infohash 对应的数据
    @info_hash.remove(qid)
  end

  # 处理完成后生成的信息
  # {:loaded=>true,:success=>true,:id=>mindmap.id}
  # {:loaded=>true,:success=>false}
  # {:loaded=>false}
  def create_mindmap_and_image_and_build_complete_info_hash(info)
    hash_info_model = HashInfo.get_model_by_input_hash_info(info)
    file = File.new(hash_info_model.path,"r")
    user = EmailActor.get_user_by_email(hash_info_model.email)
    mindmap = Mindmap.import(user,hash_info_model.file_name,file)
    MindmapImageCache.new(mindmap).refresh_cache_file("450x338")
    path = MindmapImageCache.new(mindmap).img_path("450x338")
    FileUtils.rm(hash_info_model.path)
    HashInfo.build_success_complete_hash_info(mindmap.id)
  rescue Exception => ex
    puts ex.backtrace*"\n"
    puts ex.message
    HashInfo.build_error_complete_hash_info
  end

  class HashInfo
    def self.build_input_hash_info(path,file_name,user)
      {"path"=>path,"file_name"=>file_name,"user"=>user.email}
    end

    def self.build_success_complete_hash_info(mindmap_id)
      {:loaded=>true,:success=>true,:id=>mindmap_id,:timestamp=>Time.now.to_f}
    end

    def self.build_error_complete_hash_info
      {:loaded=>true,:success=>false,:timestamp=>Time.now.to_f}
    end

    # {"loaded"=>true,"success"=>true,"id"=>mindmap.id}
    # {"loaded"=>true,"success"=>false}
    # {"loaded"=>false}
    def self.build_import_result_by_complete_hash_info(complete_hash_info)
      loaded = complete_hash_info["loaded"]
      success = complete_hash_info["success"]
      id = complete_hash_info["id"]
      {"loaded"=>loaded,"success"=>success,"id"=>id}
    end

    def self.build_uncomplete_import_result
      {'loaded'=>false}
    end

    def self.get_model_by_input_hash_info(info)
      Struct.new(:path,:file_name,:email).new(info["path"],info["file_name"],info["user"])
    end
  end
end
