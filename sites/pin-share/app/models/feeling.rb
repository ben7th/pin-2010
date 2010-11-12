class Feeling < ActiveRecord::Base
  include Pacecar
  belongs_to :user
  belongs_to :feelable,:polymorphic => true
  has_polymorph :feelable

  GOOD = "GOOD"
  BAD = "BAD"

  named_scope :feel,lambda{ |feel|
    case feel
    when "bad","BAD"
      {:conditions=>{:evaluation=>"BAD"}}
    when "good","GOOD"
      {:conditions=>{:evaluation=>"GOOD"}}
    end
  }

  module UserMethods
    def self.included(base)
      base.has_many :feelings
    end
  end

  module FeelableMethods
    def self.included(base)
      base.has_many :feelings,:as=>:feelable
    end

    # user 对这个feelable评价 好
    # 点击两次，如果已经评为好，取消感觉
    # 如果没有感觉，点击的操作是 评为好
    def feel_good_or_cancel_feel(user)
      feeling = self.feelings.find_or_create_by_user_id(user.id)
      if feeling.evaluation == Feeling::GOOD
        feeling.update_attributes!(:evaluation=>nil)
      else
        feeling.update_attributes!(:evaluation=>Feeling::GOOD)
      end
    end

    # user 对这个feelable评价 不好
    def feel_bad(user)
      feeling = self.feelings.find_or_create_by_user_id(user.id)
      feeling.update_attributes!(:evaluation=>Feeling::BAD)
    end

    # user 对feelable的评价
    def feel_of(user)
      feel = self.feelings.find_by_user_id(user.id)
      return nil if feel.blank?
      return feel.evaluation
    end

    # 评为良好的次数
    def count_of_feel_good
      feelings.evaluation_equals(Feeling::GOOD).count
    end

    # 评为差的次数
    def count_of_feel_bad
      feelings.evaluation_equals(Feeling::BAD).count
    end
  end
end