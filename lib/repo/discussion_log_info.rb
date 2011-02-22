class DiscussionLogInfo < MplistRecord

  attr_reader :operate,:discussion_id,:text_pin_id,:email,:date,:id,:workspace
  def initialize(options)
    @operate = options[:operate]
    @discussion_id = options[:discussion_id]
    @text_pin_id = options[:text_pin_id]
    @email = options[:email]
    @date = options[:date]
    @id = @date.to_i
    @workspace = options[:workspace]
  end

  OPERATE_CREATE = 'create'
  OPERATE_DELETE = 'delete'
  OPERATE_REPLY = 'reply'
  OPERATE_EDIT = 'edit'
  
  def self.build_from_commit(commit,workspace)
    files = commit.stats.files
    files_hash = files_hash(files)
    operate = case true
    when is_create?(files_hash) then OPERATE_CREATE
    when is_reply?(files_hash) then OPERATE_REPLY
    when is_delete?(files_hash) then OPERATE_DELETE
    when is_edit?(files_hash) then OPERATE_EDIT
    end
    text_pin_id = files_hash[:text].blank? ? nil : files_hash[:text][:id]
    self.new(:operate=>operate,:discussion_id=>files_hash[:document_tree][:id],
      :text_pin_id=>text_pin_id,:email=>commit.author.email,:date=>commit.date,:workspace=>workspace)
  end

  # 解析下面这个数组成为比较容易操作的hash
  # [["document_tree/12", 11, 0, 11],
  # ["text/fb0d3a32-8e3d-483b-846e-d0b7102cab11", 8, 0, 8],
  # ["visable_config/12", 8, 0, 8]]
  def self.files_hash(files)
    hash = {}
    files.each do |file|
      type_id = file[0].split('/')
      hash.merge!(type_id[0].to_sym=>{:id => type_id[1],:add_num => file[1],:delete_num => file[2],:sum_num => file[3]})
    end
    hash
  end

  # 是否是创建话题
  def self.is_create?(hash)
    hash[:document_tree][:delete_num] == 0
  end

  # 是否是删除
  def self.is_delete?(hash)
    hash.keys.size == 1
  end

  # 是否是回复
  def self.is_reply?(hash)
    !hash[:text].blank? && hash[:text][:delete_num] == 0
  end

  # 是否是编辑
  def self.is_edit?(hash)
    !(is_create?(hash) || is_reply?(hash) || is_delete?(hash))
  end

  # 按照时间倒序排列
  def <=>(other_info)
    other_info.date <=> self.date
  end
end
