class WeiboCart < UserAuthAbstract
  validates_presence_of :user_id
  validates_presence_of :mid

  belongs_to :weibo_status,:class_name=>"WeiboStatus",:foreign_key=>:mid,:primary_key=>:mid

  def self.has_cart?(user, mid)
    wc = WeiboCart.find_by_user_id_and_mid(user.id,mid)
    !wc.blank?
  end

  module UserMethods
    def self.included(base)
      base.has_many :weibo_carts
    end

    def weibo_statuses
      WeiboStatus.find(:all,:conditions=>"weibo_carts.user_id = #{self.id}",
        :joins=>"inner join weibo_carts on weibo_carts.mid = weibo_statuses.mid",
        :order=>"id desc"
      )
    end

    def add_status_to_cart(mid)
      WeiboStatus.get(mid)
      WeiboCart.find_or_create_by_user_id_and_mid(self.id,mid)
    end
  end
end
