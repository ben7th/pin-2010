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
end
