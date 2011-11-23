class Atme < UserAuthAbstract
  belongs_to :user
  belongs_to :atable,:polymorphic=>true
  belongs_to :creator,:class_name=>"User"

  validates_presence_of :user
  validates_presence_of :atable
  validates_presence_of :creator

  AT_REG = /@([A-Za-z0-9]{1}[A-Za-z0-9_]{2,20}|[一-龥]{2,20})/


  def self.parse_at_users(content)
    atme_strings = content.gsub(AT_REG).to_a
    atme_strings.map { |str|
      uname = str.gsub("@","")
      User.find_by_name(uname)
    }.compact
  end

  def self.add_atmes_by_atable(atable,content,creator)
    users = Atme.parse_at_users(content)
    users.each do |u|
      next if u == creator
      u.atmes.create(:atable=>atable,:creator=>creator)
    end
  end

  def self.change_atmes_by_atable(atable,detail,creator)
    users = Atme.parse_at_users(detail)
    old_users = atable.atmes.map{|a|a.user}

    # 增加没有的
    (users-old_users).each do |u|
      next if u == creator
      u.atmes.create(:atable=>atable,:creator=>creator)
    end
    # 删除去掉的
    (old_users-users).each do |u|
      atme = atable.atmes.find_by_user_id(u.id)
      atme.destroy
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :atmes,:order=>"id desc"
    end
  end

  module AtableMethods
    def self.included(base)
      base.has_many :atmes,:as=>:atable
    end
  end

  module FeedRevisionMethods
    def self.included(base)
      base.after_create :add_or_change_atmes_by_content
    end

    def add_or_change_atmes_by_content
      feed = self.feed
      detail = feed.detail
      user = self.user
      Atme.change_atmes_by_atable(feed,detail,user)
      return true
    end
  end

  module PostMethods
    def self.included(base)
      base.after_create :add_atmes_by_memo_on_create
      base.after_update :add_atmes_by_memo_on_update
    end

    def add_atmes_by_memo_on_create
      # Atme.add_atmes_by_atable(self, self.detail, self.user)
      return true
    end

    def add_atmes_by_memo_on_update
      Atme.change_atmes_by_atable(self, self.detail, self.user)
      return true
    end
  end

  module PostCommentMethods
    def self.included(base)
      base.after_create :add_atmes_by_content
      base.after_destroy :destroy_related_atmes
    end

    def add_atmes_by_content
      Atme.add_atmes_by_atable(self,self.content,self.user)
      return true
    end

    def destroy_related_atmes
      self.atmes.each{|a|a.destroy}
      return true
    end
  end


end
