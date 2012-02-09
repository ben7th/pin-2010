class MindmapAlbum < Mev6Abstract
  
  class SendStatus
    PUBLIC = "public"
    PRIVATE = "private"
  end
  SEND_STATUSES = [
  MindmapAlbum::SendStatus::PUBLIC,
  MindmapAlbum::SendStatus::PRIVATE
  ]
  
  belongs_to :user
  validates_presence_of :title
  validates_presence_of :user
  
  def private?
    send_status == MindmapAlbum::SendStatus::PRIVATE
  end
  
  def toggle_private
    if private?
      update_attribute(:send_status,MindmapAlbum::SendStatus::PUBLIC)
    else
      update_attribute(:send_status,MindmapAlbum::SendStatus::PRIVATE)
    end
  end
  
  module UserMethods
    def self.included(base)
      base.has_many :mindmap_albums
    end
  end
end
