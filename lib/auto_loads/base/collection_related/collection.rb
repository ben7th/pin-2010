class Collection < UserAuthAbstract
  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id
  validates_presence_of :title
  validates_presence_of :creator
  validates_uniqueness_of :title,:scope=>"creator_id"
  
  class SendStatus
    PUBLIC  = "public"
    PRIVATE = "private"
    SCOPED  = "scoped"
  end
  SEND_STATUSES = [
    Collection::SendStatus::PUBLIC,
    Collection::SendStatus::PRIVATE,
    Collection::SendStatus::SCOPED
  ]

  named_scope :publics,  :conditions=>['send_status = ?', Collection::SendStatus::PUBLIC]
  named_scope :privates, :conditions=>['send_status = ?', Collection::SendStatus::PRIVATE]

  named_scope :active, :conditions=>['active = ?', true]
  named_scope :unactive, :conditions=>['active = ?', false]

  def validate
    channel_ids = self.creator.channel_ids
    sent_c_ids = self.sent_channels.map{|c|c.id}
    cs = sent_c_ids-channel_ids

    unless cs.blank?
      errors.add(:base,"频道 #{cs*" "} 不是你的")
    end
  end

  def change_sendto(scope)
    self.collection_scopes.each{|cs|cs.destroy}
    CollectionScope.build_list_form_string(self,scope)
    self.save
  end

  module UserMethods
    def self.included(base)
      base.has_many :created_collections, :class_name=>"Collection", :foreign_key=>:creator_id
    end

    def created_collections_count; self.created_collections.count; end

    def public_collections; self.created_collections.publics; end

    def private_collections; self.created_collections.privates; end

    def create_collection_by_params(title, scope='public')
      collection = Collection.new(:creator=>self, :title=>title)
      CollectionScope.build_list_form_string(collection, scope)
      collection.save!
      return collection
    end

    def home_timeline_collections
      collections = []

      # 自己创建的收集册
      collections += self.created_collections
      # 每个联系人的公开收集册
      self.followings.map{|user|
        collections += user.public_collections
      }

      collections.uniq.sort{|x,y| y.id<=>x.id}
    end
  end

  include CollectionScope::CollectionMethods
  include FeedCollection::CollectionMethods
end
