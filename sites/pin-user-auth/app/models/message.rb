class Message < ActiveRecord::Base
  
  belongs_to :reader,:class_name=>"User",:foreign_key=>:reader_id

  named_scope :reader_is,lambda {|reader|
    {:conditions=>"reader_id = #{reader.id}"}
  }

  named_scope :unread,:conditions=>"has_read = false"

  def read
    MessageProxy.new(self.reader).delete_from_unread_message_vector_cache(self.other_user,self)
    self.update_attributes(:has_read=>true)
  end

  def the_other_user
    sender = EmailActor.get_user_by_email(self.sender_email)
    receiver = EmailActor.get_user_by_email(self.receiver_email)
    (self.reader.id == sender.id) ? receiver : sender
  end

  after_create :set_to_message_redis_cache
  def set_to_message_redis_cache
    MessageProxy.new(self.reader).add_to_vector_cache(self.the_other_user,self)
  end

  class ForbidSendToSelfError < StandardError;end
  class ForbidSendToUnfans < StandardError;end
  class NotFoundReceiverError < StandardError;end

end
