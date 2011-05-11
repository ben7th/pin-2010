module TipRule
  def self.included(base)
    base.after_create   :refresh_tip_after_create
    base.after_update   :refresh_tip_after_update
    base.after_destroy  :refresh_tip_after_destroy
  end

  def refresh_tip_after_create
    refresh_tip_cache(:after_create)
  end

  def refresh_tip_after_update
    refresh_tip_cache(:after_update)
  end

  def refresh_tip_after_destroy
    refresh_tip_cache(:after_destroy)
  end

  def refresh_tip_cache(callback_type)
    TipManagement.refresh_tip_by_rules(self,callback_type)
    return true
  end
end
