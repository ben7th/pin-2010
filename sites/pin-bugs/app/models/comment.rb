class Comment < ActiveRecord::Base
  include Pacecar
  
  belongs_to :creator,:class_name => "User", :foreign_key => "creator_id"
  belongs_to :markable,:polymorphic => true
  belongs_to :reply_user,:class_name=>"User",:foreign_key=>"reply_to"

  validates_presence_of :content
  validates_presence_of :creator
  validates_presence_of :markable

  module MarkableMethods
    def self.included(base)
      base.has_many :comments,:as=>:markable,:order=>"created_at desc"
    end

    def create_comment(attrs)
      comment = self.comments.new(attrs)
      comment.save!
#      self.create_comment_special_logic_for(comment)
      comment
    end

    def create_comment_special_logic_for(comment)
      # 在这个方法里处理特殊逻辑
      # 例如 bug 的 comment 管理员评论时，要给remarkable 的作者发邮件
    end

    def comments_of_admin
      admins = User.role_of('Admin')
      self.comments.find_all_by_creator_id(admins.map{|admin|admin.id})
    end
  end
end