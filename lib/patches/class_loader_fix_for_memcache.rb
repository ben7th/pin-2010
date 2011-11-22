=begin
  增加时间 2011年 3月 5日 by 李飞
  在开发模式下 因为 rails 加载类的方式 和纯ruby 环境不太一样
  导致 memcached-client 根据需要加载类时，找不到对应的类
  以下代码解决这个问题
=end
class << Marshal
  def load_with_rails_classloader(*args)
    begin
      load_without_rails_classloader(*args)
    rescue ArgumentError, NameError => e
      if e.message =~ %r(undefined class/module)
        const = e.message.split(' ').last
        const.constantize
        retry
      else
        raise(e)
      end
    end
  end
  alias_method_chain :load, :rails_classloader
end