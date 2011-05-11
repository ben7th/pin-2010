class BaseTipProxy

  def remove_tip_by_tip_id(tip_id)
    raise('tip rh 未定义') if @rh.nil?
    @rh.remove(tip_id)
  end

  def remove_all_tips
    raise('tip rh 未定义') if @rh.nil?
    @rh.del
  end

  def self.definition_tip_attrs(*options)
    attrs_str = options.map{|a|":#{a}"}*","
    class_eval %`
      class Tip < Struct.new(#{attrs_str})
      end
    `
  end
end
