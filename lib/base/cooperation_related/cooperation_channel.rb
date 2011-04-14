class CooperationChannel < Mev6Abstract
  belongs_to :channel
  belongs_to :mindmap
  validates_presence_of :channel
  validates_presence_of :mindmap
  validates_uniqueness_of :channel_id, :scope => :mindmap_id
end
