module MindpinDatetimeHelper
  # 获取当前时区的时间日期的友好形式
  def qdatetime(time)
    time=time.localtime
    "<span class='date'>#{time.nil? ? '未知' : "#{time.month}月#{time.day}日 #{time.hour}:#{time.min<10 ? "0#{time.min}" : time.min}"}</span>"
  end
  
  # 获取当前时区的日期的友好形式
  def qdate(time)
    time=time.localtime
    timestr="#{time.year}年#{time.month}月#{time.day}日"
    "<span class='date'>#{time.nil? ? '未知' : timestr}</span>"
  end
  
  def qtime(time)
    time=time.localtime
    "<span class='date'>#{time.nil? ? '未知' : "#{time.hour}:#{time.min<10 ? "0#{time.min}" : time.min}"}</span>"
  end
  
  # 记录创建至今
  def created_from(record)
    str=record.created_at.nil? ? '未知' : get_period_str(Time.now-record.created_at)
    "<span class='date'>#{str}</span>"
  end
  
  # 记录更新至今
  def updated_from(record)
    str=record.updated_at.nil? ? '未知' : get_period_str(Time.now-record.updated_at)
    "<span class='date'>#{str}</span>"
  end
  
  # 记录创建至今
  def created_from_str(record)
    str=record.created_at.nil? ? '未知' : get_period_str(Time.now-record.created_at)
    "<span class='date'>#{str}</span><span class='quiet'>创建</span>"
  end
  
  # 记录更新至今
  def updated_from_str(record)
    str=record.updated_at.nil? ? '未知' : get_period_str(Time.now-record.updated_at)
    "<span class='date'>#{str}</span><span class='quiet'>编辑</span>"
  end
  
  def show_time_by_order_type(order,record)
    if order=='UPDATED_TIME'
      updated_from_str record
    else
      created_from_str record
    end
  end
  
  def created_at(object)
    str=object.created_at.nil? ? '未知' : object.created_at.to_date
    "<span class='date'>#{str}</span>"
  end
  
  # 获取一个时间段的描述字符串
  def get_period_str(period)
    case period
      when 0..1.minutes then '片刻前'
      when 1.minutes..2.hours then "#{Integer period/1.minutes}分钟前"
      when 2.hours..2.days then "#{Integer period/1.hours}小时前"
      when 2.days..1.months then "#{Integer period/1.days}天前"
      when 1.months..1.years then "#{Integer period/1.months}月前"
      when 1.years..100.years then "#{Integer period/1.years}年前"
    end
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
end