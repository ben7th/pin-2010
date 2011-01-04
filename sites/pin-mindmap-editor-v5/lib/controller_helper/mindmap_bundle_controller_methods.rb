# 暂时没用到
module MindmapBundleControllerMethods
  def convert_bundle
    require 'digest/sha1'
    service_token = Digest::SHA1.hexdigest("#{current_user.id}#{SERVICE_KEY}")
    res = Net::HTTP.post_form URI.parse(File.join(DISCUSSION_SITE,'/documents/mindmaps')),
      :mindmap=>@mindmap.struct,:workspace_id=>params[:workspace_id],:req_user_id=>current_user.id,:service_token=>service_token

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      redirect_to [current_user,:mindmaps]
    else
      render :text=>"error",:status=>500
    end
  end
end
