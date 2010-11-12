class User
  @@users = {}

  def initialize(hash)
    if hash.class==UserResource
      @hash ||=hash.attributes
    else
      @hash ||=hash
    end
  end

  def id
    @hash['id']
  end

  def name
    @hash['name']
  end

  def created_at
    @hash['created_at']
  end

  def logo_url
    "#{UserResource.site}#{@hash['logo']}"
  end

  # 定义这个的目的是为了url相关方法能够正常的工作
  def to_s
    id.to_s
  end

  def new_record?
    false
  end

  def ==(u)
    return false if u.blank?
    (self.id == u.id) && (self.name == u.name)
  end

  def self.find(*arguments)
    begin
      return User.new(UserResource.find(arguments))
    rescue Exception => ex
      nil
    end
  end

  class UserResource < ActiveResource::Base
    self.site = USER_API_SITE
    self.element_name = "user"
  end

  def mindmaps
    unless @mindmaps
      #arr = PinResource.find(:all,:params=>{:pintype=>'Mindmap'})
      #ids = arr.map{|x| x.item_id}
      #@mindmaps = Mindmap.scoped(:conditions=>['id in (?)',ids])
      # 此处必须这样写
      # 写成 scoped_by_user_id(self.id)
      # 或者写成 scoped(:conditions=>["user_id = ?",self.id])
      # 都会导致在调用 tag_counts 方法的时候导致SQL组装错误
      # 以后要换用自己的tag系统，这个有点脑残了
      @mindmaps = Mindmap.scoped(:conditions=>["user_id = #{self.id}"])
    end
    @mindmaps
  end


  # 该用户最近创建的mindmaps
  def recently_mindmaps
    Mindmap.find(:all,:conditions=>["user_id  = ?",self.id],:order=>'created_at desc',:limit=>5)
  end

end
