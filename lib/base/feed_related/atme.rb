class Atme < UserAuthAbstract
  belongs_to :user
  belongs_to :atable,:polymorphic=>true

  validates_presence_of :user
  validates_presence_of :atable

  AT_REG = /@(\S+)/

  def self.parse_at_users(content)
    atme_strings = content.gsub(AT_REG).to_a
    atme_strings.map do |str|
      uname = str.gsub("@","")
      User.find_by_name(uname)
    end.compact
  end

  def self.add_atmes_by_atable(atable,content)
    users = Atme.parse_at_users(content)
    users.each{|u|u.atmes.create(:atable=>atable)}
  end

  def self.change_atmes_by_atable(atable,content)
    users = Atme.parse_at_users(content)
    old_users = atable.atmes.map{|a|a.user}

    # 增加没有的
    (users-old_users).each{|u|u.atmes.create(:atable=>atable)}
    # 删除去掉的
    (old_users-users).each do |u|
      atme = atable.atmes.find_by_user_id(u.id)
      atme.destroy
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :atmes
    end
  end

  module AtableMethods
    def self.included(base)
      base.has_many :atmes,:as=>:atable
    end
  end

  module FeedMethods
    def self.included(base)
      base.after_create :add_atmes_by_content
    end

    def add_atmes_by_content
      Atme.add_atmes_by_atable(self,self.content)
      return true
    end
  end

  module FeedDetailMethods
    def self.included(base)
      base.after_create :add_atmes_by_content
    end

    def add_atmes_by_content
      Atme.add_atmes_by_atable(self.feed,self.content)
      return true
    end
  end

  module ViewpointMethods
    def self.included(base)
      base.after_create :add_atmes_by_memo_on_create
      base.after_update :add_atmes_by_memo_on_update
    end

    def add_atmes_by_memo_on_create
      Atme.add_atmes_by_atable(self,self.memo)
      return true
    end

    def add_atmes_by_memo_on_update
      Atme.change_atmes_by_atable(self,self.memo)
      return true
    end
  end

  module FeedChangeMethods
    def self.included(base)
      base.after_create :change_atmes_by_feed_content
    end

    def change_atmes_by_feed_content
      feed = self.feed
      content = "#{feed.content} #{feed.detail_content}"
      Atme.change_atmes_by_atable(feed,content)
      return true
    end

  end

  module FeedCommentMethods
    def self.included(base)
      base.after_create :add_atmes_by_content
      base.after_destroy :destroy_related_atmes
    end

    def add_atmes_by_content
      Atme.add_atmes_by_atable(self,self.content)
    end

    def destroy_related_atmes
      self.atmes.each{|a|a.destroy}
    end
  end

  module ViewpointCommentMethods
    def self.included(base)
      base.after_create :add_atmes_by_content
      base.after_destroy :destroy_related_atmes
    end

    def add_atmes_by_content
      Atme.add_atmes_by_atable(self,self.content)
    end

    def destroy_related_atmes
      self.atmes.each{|a|a.destroy}
    end
  end


end
