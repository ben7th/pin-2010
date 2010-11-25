class Snapshot < ActiveRecord::Base
#  缓存暂时注释掉
  index :mindmap_id
  
  belongs_to :mindmap
  
  validates_presence_of :mindmap
  validates_presence_of :title

  def initialize(*args)
    super(*args)
    time = Time.now
    str = "#{time.year}_#{time.month}_#{time.day}_#{time.hour}_#{time.min}"
    self.title = "#{self.mindmap.title}_#{str}"
  end

  before_create :set_struct
  def set_struct
    self.struct = self.mindmap.struct
  end

  # 把 mindmap 恢复到 快照的状态
  def to_recover
    self.mindmap.update_attributes(:struct=>self.struct)
  end

  module MindmapMethods
    def self.included(base)
      base.has_many :snapshots
    end
  end
end