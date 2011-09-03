module PieUi
  module DatetimeHelper
    # 获取当前时区的时间日期的友好形式
    def qdatetime(time)
      return "<span class='date'>未知</span>" if time.nil?
      "<span class='date'>#{time.localtime.strftime("%m月%d日 %H:%M")}</span>"
    end

    # 获取当前时区的日期的友好形式(年月日时分秒)
    def qdatetimefull(time)
      return "<span class='date'>未知</span>" if time.nil?
      "<span class='date'>#{time.localtime.strftime("%Y年%m月%d日 %H:%M:%S")}</span>"
    end

    # 获取当前时区的日期的友好形式
    def qdate(time)
      return "<span class='date'>未知</span>" if time.nil?
      "<span class='date'>#{time.localtime.strftime("%Y年%m月%d日")}</span>"
    end

    def qtime(time)
      return "<span class='date'>未知</span>" if time.nil?
      "<span class='date'>#{time.localtime.strftime("%H:%M")}</span>"
    end

    def jtime(time)
      _jtime_span(time)
    end

    def _jtime_span(time)
      local_time = time.localtime
      if local_time.nil?
        return "<span class='date'>未知</span>"
      end
      "<span class='date' data-date='#{local_time.to_i}'>#{friendly_relative_time(local_time)}</span>"
    end

    # 根据当前时间与time的间隔距离，返回时间的显示格式
    # 李飞编写，仿新浪微博
    def friendly_relative_time(time)
      current_time = Time.now
      relative_second = current_time.to_i - time.to_i
      if relative_second < 60
        return "#{relative_second}秒前"
      end
      if relative_second < 3600
        return "#{relative_second/60}分钟前"
      end
      if relative_second < 86400 && current_time.day==time.day
        return "今天 #{time.hour}点#{time.min}分"
      end
      if time.year == time.year
        return "#{time.month}月#{time.day}日 #{time.hour}点#{time.min}分"
      end
      "#{time.year}年 #{time.month}月#{time.day}日 #{time.hour}点#{time.min}分"
    end

    def time_tz(time)
      time.strftime("%Y-%m-%dT%H:%M:%SZ")
    end
  end
end