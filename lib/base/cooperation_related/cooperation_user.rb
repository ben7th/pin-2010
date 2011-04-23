class CooperationUser < Mev6Abstract
  belongs_to :user
  belongs_to :mindmap
  validates_presence_of :user
  validates_presence_of :mindmap
  validates_uniqueness_of :user_id, :scope => :mindmap_id

end
