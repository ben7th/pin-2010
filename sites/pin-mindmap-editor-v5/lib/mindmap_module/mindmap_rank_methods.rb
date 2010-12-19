module MindmapRankMethods
  def rank
    MindmapRank.new(self).rank_value
  end

  # 导图的节点数
  def node_count
    Nokogiri::XML(self.struct).css("N").count
  end

  def self.included(base)
    base.before_save :update_rank_value
    base.extend(ClassMethods)
  end
  
  def update_rank_value
    self.weight = MindmapRank.new(self).weight_value
    mmw = MindmapRank.map_max_weight
    if mmw < self.weight
      MindmapRank.map_max_weight=(self.weight)
    end
    return true
  end

  module ClassMethods
    def has_too_many_zero_mindmap?(user)
      _more(user) && _zero_more_than_unzero(user)
    end

    def _more(user)
      Mindmap.of_user_id(user.id).count > 1
    end

    def _zero_more_than_unzero(user)
      Mindmap.of_user_id(user.id).is_zero_weight?(true).count >
        Mindmap.of_user_id(user.id).is_zero_weight?(false).count
    end

    # user 的所有导图的 平均 rank
    def average_rank_of_user(user)
      ranks = Mindmap.of_user_id(user.id).map do |mindmap|
        mindmap.rank.to_f
      end
      return 0 if ranks.count == 0
      format("%.1f",(ranks.sum / ranks.count)).to_f
    end

    # user 的所有导图的 平均 node_count
    def average_node_count_of_user(user)
      ranks = Mindmap.of_user_id(user.id).map do |mindmap|
        mindmap.node_count.to_f
      end
      return 0 if ranks.count == 0
      format("%.1f",(ranks.sum / ranks.count)).to_f.ceil
    end
  end
end