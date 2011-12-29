# 缓存，队列等一些模块的逻辑规则的调用
module MindpinLogicRule
  def self.included(base)
    base.after_save     :run_mindpin_logic_after_save
    base.after_create   :run_mindpin_logic_after_create
    base.after_update   :run_mindpin_logic_after_update
    base.after_destroy  :run_mindpin_logic_after_destroy

    base.alias_method_chain :method_missing, :mindpin_logic_rule
    base.alias_method_chain :respond_to?, :mindpin_logic_rule
  end

  def run_mindpin_logic_after_save
    run_mindpin_logic_by_callback_type(:after_save)
  end

  def run_mindpin_logic_after_create
    run_mindpin_logic_by_callback_type(:after_create)
  end

  def run_mindpin_logic_after_update
    run_mindpin_logic_by_callback_type(:after_update)
  end

  def run_mindpin_logic_after_destroy
    run_mindpin_logic_by_callback_type(:after_destroy)
  end

  def run_mindpin_logic_by_callback_type(callback_type)
    MindpinLogicManagement.run_all_logic_by_rules(self, callback_type)
  rescue Exception => ex
    p ex.message
    puts ex.backtrace.join("\n")
  ensure
    return true
  end

  def respond_to_with_mindpin_logic_rule?(method_id)
    if respond_to_without_mindpin_logic_rule?(method_id)
      return true
    else
      return MindpinLogicManagement.has_method?(self,method_id.to_sym)
    end
  end

  def method_missing_with_mindpin_logic_rule(method_id, *args)
    if MindpinLogicManagement.has_method?(self,method_id)
      return MindpinLogicManagement.do_method(self,method_id, *args)
    else
      return method_missing_without_mindpin_logic_rule(method_id, *args)
    end
  end
end
