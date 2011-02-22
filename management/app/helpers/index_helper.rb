module IndexHelper
   def qdatetimefull(time)
    return "<span class='date'>未知</span>" if time.nil?
    "<span class='date'>#{time.year}年#{_2(time.month)}月#{_2(time.day)}日 #{_2(time.hour)}:#{_2(time.min)}:#{_2(time.sec)}</span>"
  end

   def _2(num)
    num>9 ? num : "0#{num}"
  end
end
