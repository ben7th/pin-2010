module AtmeMethods
  def self.included(base)
    base.extend ClassMethods
    base.add_rules({
        :class => Atme,
        :after_create => Proc.new{|atme|
          UserTipProxy.create_atme_tip_on_queue(atme)
        },
        :after_destroy => Proc.new{|atme|
          UserTipProxy.destroy_atme_tip(atme)
        }
      })
  end

  def create_atme_tip(atme)
    tip_id = find_tip_id_by_hash({"atme_id"=>atme.id,"kind"=>UserTipProxy::ATME})
    if tip_id.blank?
      tip_id = randstr
      tip_hash = {"atme_id"=>atme.id,"kind"=>UserTipProxy::ATME,"time"=>Time.now.to_f.to_s}
      @rh.set(tip_id,tip_hash)
    end
  end

  def destroy_atme_tip(atme)
    tip_id = find_tip_id_by_hash({"atme_id"=>atme.id,"kind"=>UserTipProxy::ATME})
    remove_tip_by_tip_id(tip_id) unless tip_id.blank?
  end

  module ClassMethods
    def create_atme_tip_on_queue(atme)
      UserTipResqueQueueWorker.async_user_tip(UserTipProxy::ATME,[atme.id])
    end

    def create_atme_tip(atme)
      UserTipProxy.new(atme.user).create_atme_tip(atme)
    end

    def destroy_atme_tip(atme)
      UserTipProxy.new(atme.user).destroy_atme_tip(atme)
    end

  end
end
