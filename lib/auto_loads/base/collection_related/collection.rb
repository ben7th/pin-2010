class Collection < UserAuthAbstract
  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id
  validates_presence_of :title
  validates_presence_of :creator
  validates_uniqueness_of :title,:scope=>"creator_id"
  
  class SendStatus
    PUBLIC = "public"
    PRIVATE = "private"
    SCOPED = "scoped"
  end
  SEND_STATUSES = [
    Collection::SendStatus::PUBLIC,
    Collection::SendStatus::PRIVATE,
    Collection::SendStatus::SCOPED
  ]

  named_scope :publics,:conditions=>"send_status ='#{Collection::SendStatus::PUBLIC}'"

  def validate
    channel_ids = self.creator.channels_db_ids
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
      base.has_many :created_collections_db,:class_name=>"Collection",:foreign_key=>:creator_id
    end

    def create_collection_by_params(title, scope='public')
      collection = Collection.new(:creator=>self, :title=>title)
      CollectionScope.build_list_form_string(collection,scope)
      collection.save
      return collection
    end

    def out_collections_db
      Collection.find(:all,:conditions=>"collections.creator_id = #{self.id} and collections.send_status = '#{Collection::SendStatus::PUBLIC}'",
        :order=>"collections.id desc"
      )
    end

    def private_collections_db
      Collection.find(:all,:conditions=>"collections.creator_id = #{self.id} and collections.send_status = '#{Collection::SendStatus::PRIVATE}'",
        :order=>"collections.id desc"
      )
    end

    def to_followings_out_collections_db
      joins=%`
        inner join collection_scopes on collection_scopes.collection_id = collections.id
          and collection_scopes.param = '#{CollectionScope::FOLLOWINGS}'
      `
      Collection.find(:all,:conditions=>"collections.creator_id = #{self.id} and collections.send_status = '#{Collection::SendStatus::SCOPED}'",
        :joins=>joins,:order=>"collections.id desc"
      )
    end

    def to_personal_out_collections_db
      joins=%`
        inner join collection_scopes on collection_scopes.collection_id = collections.id
          and collection_scopes.scope_type = 'User'
      `
      Collection.find(:all,:conditions=>"collections.creator_id = #{self.id}",
        :joins=>joins,:order=>"collections.id desc"
      )
    end

    def all_to_personal_in_collection_db
      joins=%`
        inner join collection_scopes on collection_scopes.collection_id = collections.id
      `
      conditions=%`
        collection_scopes.scope_type = 'User'
          and
        collection_scopes.scope_id = #{self.id}
      `
      Collection.find(:all,:conditions=>conditions,
        :joins=>joins,:order=>"collections.id desc"
      )
    end

    def to_personal_in_collections_db
      collections = self.all_to_personal_in_collection_db
      users = self.followings
      collections.select do |collection|
        users.include?(collection.creator)
      end
    end

    def incoming_to_personal_in_collections_db
      collections = self.all_to_personal_in_collection_db
      users = self.followings
      collections.select do |collection|
        !users.include?(collection.creator)
      end
    end

  end

  include CollectionScope::CollectionMethods
  include FeedCollection::CollectionMethods
  include Feed::CollectionMethods
end
