module FavsMethods
  def self.included(base)
    base.extend ClassMethods
  end

  def create_favs_tip(kind,feed,operator)
    tip_id = find_tip_id_by_hash({"feed_id"=>feed.id,"user_id"=>operator.id,"kind"=>kind})
    if tip_id.blank?
      tip_id = randstr
      tip_hash = {"feed_id"=>feed.id,"user_id"=>operator.id,"kind"=>kind,"time"=>Time.now.to_f.to_s}
    else
      tip_hash = @rh.get(tip_id)
      tip_hash["time"] = Time.now.to_f.to_s
    end
    @rh.set(tip_id,tip_hash)
  end

  module ClassMethods
    def create_favs_tip(kind,feed,operator)
      users = feed.fav_users
      (users-[operator]).each do |user|
        UserTipProxy.new(user).create_favs_tip(kind,feed,operator)
      end
    end
  end
end
