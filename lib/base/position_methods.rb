module PositionMethods
  def self.included(base)
    raise "不存在 position 字段" if !base.new.has_attribute?(:position)
    base.before_create :set_position
  end

  def set_position
    self.position = Time.now.to_f
  end

#  def move_to_first
#    first_item = self.class.first(:order=>"position desc")
#    self.position = first_item.position + 1
#    self.save
#  end
#
#  def move_to_last
#    last_item = self.class.last(:order=>"position desc")
#    self.position = last_item.position/2
#    self.save
#  end
#
#  def insert_prev_of(item)
#    prev_item = self.class.last(
#      :conditions=>"position > #{item.position}",:order=>"position desc")
#    return move_to_first if prev_item.blank?
#
#    self.position = (prev_item.position + item.position)/2
#    self.save
#  end
#
#  def insert_next_of(item)
#    next_item = self.class.first(
#      :conditions=>"position < #{item.position}",:order=>"position desc")
#    return move_to_last if next_item.blank?
#
#    self.position = (item.position + next_item.position)/2
#    self.save
#  end
end
