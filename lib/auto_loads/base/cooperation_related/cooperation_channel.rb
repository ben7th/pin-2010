class CooperationChannel < Mev6Abstract
  belongs_to :channel
  belongs_to :mindmap
  validates_presence_of :channel
  validates_presence_of :mindmap
  validates_uniqueness_of :channel_id, :scope => :mindmap_id

  module ChannelMethods
    def self.included(base)
      base.has_many :cooperation_channels
      base.has_many :cooperate_mindmaps_db,:through=>:cooperation_channels,:source=>:mindmap
    end
  end
end
