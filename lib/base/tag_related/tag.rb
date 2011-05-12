class Tag < UserAuthAbstract
  validates_format_of :name,:with=>/^[A-Za-z0-9一-龥]+$/

  include FeedTag::TagMethods
end
