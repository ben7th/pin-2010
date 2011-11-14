require "csv"

def parse_in_week(str)
  res = []
  str.strip.gsub(/周|上/,"").split(/,|，/).each do |s|
    arr = s.strip.split("-")
    if arr.count == 1
      res.push(arr[0].to_i)
    else
      arr[0].to_i.upto(arr[1].to_i){|a|res.push(a)}
    end
  end
  res.sort*","
end

def parse_other_info(item)
  # 其它信息
  other_info = {}
  # 选课人数
  other_info.merge!("选课人数"=>item[5].strip.to_i)
  # 余量
  other_info.merge!("余量"=>item[6].strip.to_i)
  # 总学时
  other_info.merge!("总学时"=>item[7].strip.to_i)
  # 学分
  other_info.merge!("学分"=>item[8].strip.to_i)
  # 教师号2
  unless item[16].blank?
    other_info.merge!("教师号2"=>item[16].strip)
  end
  # 教师名2
  unless item[17].blank?
    other_info.merge!("教师名2"=>item[17].strip)
  end
  # 面向学生
  unless item[18].blank?
    other_info.merge!("面向学生"=>item[18].strip)
  end
  other_info
end

csv_path = "#{RAILS_ROOT}/lib/bjtu.csv"

items = CSV.open(csv_path,'r').to_a

#>> items[0]
#=> ["课程\345\217\267", "课序\345\217\267", "课程\345\220\215", "开课系\346\211\200", "容\351\207\217", "选课人\346\225\260", "余\351\207\217", "总学\346\227\266", "学\345\210\206", "星\346\234\237", "节\346\254\241", "持续节\346\254\241", "上课地\347\202\271", "上课周\346\254\241", "教师号1", "教师名1", "教师号2", "教师名2", "面向学\347\224\237"]
item0 = items.shift
bjtu = University.find_or_create_by_name(:name=>"北京交通大学")

University.transaction do
  count = items.count
  items.each_with_index do |item,index|
    p "正在导入 #{index+1}/#{count}"
    # 创建校系
    department_name = item[3].strip
    department = Department.find_by_name(department_name)
    if department.blank?
      department = Department.create!(:name=>department_name,:university=>bjtu)
    end

    # 课程信息
    course_name = item[2].strip
    cid = item[0].strip
    course = Course.find_by_cid(cid)
    if course.blank?
      course = Course.create!(:name=>course_name,:cid=>cid,
        :department=>department,:university=>bjtu)
    end

    # 地点
    location_name = item[12].strip
    location = Location.find_by_name(location_name)
    if location.blank?
      location = Location.create!(:name=>location_name,:university=>bjtu)
    end

    # 教师
    teacher_name = item[15].strip
    tid = item[14].strip
    teacher = Teacher.find_by_tid(tid)
    if teacher.blank?
      teacher = Teacher.create!(:name=>teacher_name,:tid=>tid,:university=>bjtu)
    end

    # 课程项
    week_day = item[9].strip.to_i
    order_num = item[10].strip.to_i
    period = item[11].strip.to_i
    load = item[4].strip.to_i
    # 需要解析
    in_week = parse_in_week(item[13])
    # 其它信息
    other_info = parse_other_info(item).to_json

    CourseItem.create!(
      :week_day=>week_day,:order_num=>order_num,:period=>period,
      :load=>load,:in_week=>in_week,:other_info=>other_info,
      :location=>location,:teacher=>teacher,:course=>course
    )
  end

end


