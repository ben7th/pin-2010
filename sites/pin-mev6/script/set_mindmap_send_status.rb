mindmaps = Mindmap.find(:all,:select=>"id",:order=>"id asc")
count = mindmaps.length

def Mindmap.record_timestamps
  false
end

mindmaps.each_with_index do |mindmap,index|
  p "正在处理 mindmap_#{mindmap.id} #{index+1}/#{count}"
  
  m = Mindmap.find(mindmap.id)
  begin
    bool_private = !!m.attributes["private"]

    if bool_private
      m.send_status = Mindmap::SendStatus::PRIVATE
    else
      m.send_status = Mindmap::SendStatus::PUBLIC
    end

    def m.record_timestamps
      false
    end

    m.instance_variable_set(:@skip_hook,"skip")
    m.save
  rescue Exception => ex
    File.open("/tmp/set_mindmap_send_status_error_mindmaps","a"){|f|f<< "#{m.id}\n"}
  end

end

