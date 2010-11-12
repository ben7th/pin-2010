class Contacting < ActiveRecord::Base
  include Pacecar

  belongs_to :host,:class_name=>"User",:foreign_key=>"host_id"
  belongs_to :contact,:class_name=>"User",:foreign_key=>"contact_id"

  before_create :set_show_share
  def set_show_share
    self.show_share = true
  end

  def validate
    cont = Contacting.find_by_host_id_and_contact_id(self.host_id,self.contact_id)
    if cont
      errors.add_to_base("不能重复创建")
    end
  end

  module HostMethods
    def self.included(base)
      base.has_many :contactings,:foreign_key=>"host_id",:order=>"created_at desc"
      base.has_many :contacts,:through => :contactings,:source=>:contact
    end

    # 是否关注
    def follow?(user)
      !!Contacting.find_by_host_id_and_contact_id(self.id,user.id)
    end

    # 关注
    def follow(user)
      con = Contacting.new(:host=>self,:contact=>user)
      con.save
    end

    # 取消关注
    def unfollow(user)
      con = Contacting.find_by_host_id_and_contact_id(self.id,user.id)
      con.destroy if con
    end

    # 将对方添加为联系人
    def add_contact(user)
      return Contacting.create(:host=>self,:contact=>user)
    end

    # 互相添加对方为联系人
    def add_contact_with_each_other(user)
      self.add_contact(user)
      user.add_contact(self)
    end

    # 是否互相关注
    def contact_each_other?(user)
      b_1 = Contacting.find_by_host_id_and_contact_id(self.id,user.id)
      b_2 = Contacting.find_by_host_id_and_contact_id(user.id,self.id)
      b_1 && b_2
    end

    # 关注
    def contacting
      # TODO 用 self.contacts 貌似不能跨数据库
      # 会去 user 的 数据库中找  contactings 表
      # belongs_to :contact,:class_name=>"User",:foreign_key=>"contact_id"
      # belongs_to 复杂的时候，会这样。貌似是个 rails bug
#     self.contacts
      contactings = Contacting.find_all_by_host_id(self.id)
      contactings.map{|c|c.contact}
    end

    # 被关注
    def contacters
      contactings = Contacting.find_all_by_contact_id(self.id)
      contactings.map{|c|c.host}
    end

    # 被关注的次数
    def contacters_count
      Contacting.count(:conditions=>{:contact_id => self.id})
    end

  end
end
