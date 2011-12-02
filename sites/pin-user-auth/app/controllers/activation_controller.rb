class ActivationController < ApplicationController

  def apply
    @is_applied = params[:r] == 'success'
    render :layout=>"anonymous", :template=>"index/activation/apply"
  end

  def apply_submit
    detail = %~
邮箱：
#{params[:email]}
------------
真实姓名:
#{params[:name]}
------------
个人简介:
#{params[:description]}
~
    agent_user = User.find(1000001) # 山涧风笛
    collection = _find_or_create_apply_collection(agent_user)
    
    agent_user.send_feed(
      :title  => "激活码申请",
      :detail => detail,
      :collection_ids => collection.id.to_s,
      :from   => Feed::FROM_WEB
    )
    redirect_to "/apply?r=success"
  end

  def _find_or_create_apply_collection(agent_user)
    collection_title = "激活码申请"
    collection = agent_user.created_collections_db.find_by_title(collection_title)
    if collection.blank?
      agent_user.create_collection_by_params(collection_title)
      collection = agent_user.created_collections_db.find_by_title(collection_title)
    end
    return collection
  end

  def activation
    return redirect_to '/' if logged_in? && current_user.is_v2_activation_user?
    render :layout=>"anonymous",:template=>"index/activation"
  end

  def activation_submit
    if !current_user.is_v2_activation_user?
      ActivationCode.acitvate_user(params[:code],current_user)
    end
    redirect_to "/"
  rescue Exception => ex
    flash[:error] = ex.message
    redirect_to "/activation"
  end
  
end