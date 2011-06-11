module NewbieHelper

  # 给新手推荐的主题
  def feeds_for_newbie
    # 查找观点数大于2的主题
    ActiveRecord::Base.connection.select_all(%~
      SELECT SUB.id

      FROM (
        SELECT DISTINCT F.*,count(*) COUNTF
        FROM feeds F
        JOIN viewpoints VP ON VP.feed_id = F.id
        WHERE F.hidden = false AND F.id <> 3121
        GROUP BY F.id
        ORDER BY RAND()
      ) SUB

      WHERE SUB.COUNTF >= 2
      LIMIT 7
    ~).map{|item|Feed.find_by_id(item["id"])}.uniq.compact
  end

  # 给新手推荐的用户
  def hot_users_for_newbie
    page_hot_users(14)
  end
end
