# 运行 Feed.find 找出了 contact 数据库信息
# 为了找出这个BUG，写的代码
# 运行一个月，并没有复现
# 现在先把这些代码注掉，方面以后再次使用
#
#
#module Cash
#  module Query
#    class Abstract
#      def perform(find_options = {}, get_options = {})
#        if cache_config = cacheable?(@options1, @options2, find_options)
#          cache_keys, index = cache_keys(cache_config[0]), cache_config[1]
#          misses, missed_keys, objects = hit_or_miss(cache_keys, index, get_options)
#          obj = format_results(cache_keys, choose_deserialized_objects_if_possible(missed_keys, cache_keys, misses, objects))
#          _lifei_assert_data_valid(obj,@active_record)
#          obj
#        else
#          uncacheable
#        end
#      end
#
#      def _lifei_assert_data_valid(objs,active_record)
#        return if objs.class == Fixnum
#        objs_clone = objs.clone
#        obj = objs_clone
#        obj = obj.first if obj.class == Array
#        return if obj.nil?
#        if obj.class != active_record
#          mup_ap objs_clone
#          raise "#{active_record} 缓存出错"
#        end
#      rescue Exception => ex
#        log_file_path = "/root/mindpin_base/lifei/cache_money_raise_log"
#        File.open(log_file_path,"a") do |f|
#          f << "\n\n\n"
#          f << objs_clone
#          f << active_record
#          f << ex.message
#          f << ex.backtrace.join("\n")
#          f << "\n\n\n"
#        end
#      end
#    end
#  end
#end
