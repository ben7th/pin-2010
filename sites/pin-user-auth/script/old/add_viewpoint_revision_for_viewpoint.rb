ActiveRecord::Base.transaction do
  viewpoints = Viewpoint.all
  count = viewpoints.length

  viewpoints.each_with_index do |viewpoint,index|
    p "正在处理 #{index+1}/#{count}"

    vr = ViewpointRevision.new(:viewpoint=>viewpoint,:user=>viewpoint.user,
      :content=>viewpoint.memo,:message=>"")

    vr.created_at = viewpoint.created_at
    vr.updated_at = viewpoint.created_at
    vr.save_without_timestamping
  end
end