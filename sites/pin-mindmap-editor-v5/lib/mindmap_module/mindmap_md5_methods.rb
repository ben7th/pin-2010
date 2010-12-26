require 'digest/md5'

module MindmapMd5Methods
  # 取得一个导图内容的md5
  # 导图的内容由两部分组成
  # 1 节点的 struct
  # 2 每个节点的备注
  def md5
    # 所有备注的内容
    notes_content = self.node_notes.map{|local_id,note|"#{local_id} #{note}"}*" "
    # 备注和 struct 的内容
    all_content = "#{notes_content} #{self.struct}"
    Digest::MD5.hexdigest(all_content)
  end

  # 判断 md5_str 是否和 该导图的 md5串 相同
  def check_md5(md5_str)
    self.md5 == md5_str
  end

end
