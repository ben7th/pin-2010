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
  
  # 记录创建至今
  def created_from(record)
    _jtime_span(record.created_at)
  end
  
  # 记录更新至今
  def updated_from(record)
    _jtime_span(record.updated_at)
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
  
  def show_time_by_order_type(order,record)
    if order==1
      updated_from_str record
    else
      created_from_str record
    end
  end
  
  def created_at(object)
    str=object.created_at.nil? ? '未知' : object.created_at.to_date
    "<span class='date'>#{str}</span>"
  end
  
  # 获取时间段
  def get_period(hour)
    hour=hour + 8
    case hour
    when 7..12 then "上午"
    when 13..18 then "下午"
    when 3..7 then "凌晨"
    when 23..1 then "子夜"
    end
  end

  def format_in_activity(datetime)
    datetime.strftime("%Y-%m-%d %H:%M")
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

  # 根据当前时间与time的间隔距离，返回时间的显示格式
  # 一年之前显示 ：--年
  # 本年之内显示 ：--月--日
  # 本天之内显示 ：--点--分
  def time_str_by_distance_of_now(time)
    if time.today?
      str = time.strftime("%H:%M")
    elsif time.year < Time.now.year
      str = "#{time.year}年"
    else
      str = "#{time.month}月#{time.day}日"
    end
    return "<span class='date'>#{str}</span>"
  end

  # 以今天 今年 为时间分割线
  # 今天的时间显示为：“今天 02:04”
  # 其他的时间显示为：“5月20日 13:51”
  # 非今年时间显示为：“2009年5月20日 13:51”
  def time_str_by_today(time)
    if time.today?
      str = "今天 #{time.strftime("%H:%M")}"
    elsif time.year < Time.now.year
      str = "#{time.year}年#{time.month}月#{time.day}日 #{time.strftime("%H:%M")}"
    else
      str = "#{time.month}月#{time.day}日 #{time.strftime("%H:%M")}"
    end
    return "<span class='date'>#{str}</span>"
  end

  def time_tz(time)
    time.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
end