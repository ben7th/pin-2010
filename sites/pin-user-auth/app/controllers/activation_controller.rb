class ActivationController < ApplicationController
  def services
    return redirect_to '/' if logged_in? && current_user.is_v2_activation_user?
    render :layout=>"anonymous",:template=>"index/services"
  end

  def activation
    return redirect_to '/' if logged_in? && current_user.is_v2_activation_user?
    render :layout=>"anonymous",:template=>"index/activation"
  end

  def do_activation
    if !current_user.is_v2_activation_user?
      ActivationCode.acitvate_user(params[:code],current_user)
    end
    redirect_to "/"
  rescue Exception => ex
    flash[:error] = ex.message
    redirect_to "/activation"
  end

  def apply_form
    render :layout=>"anonymous",:template=>"index/apply_form"
  end

  def do_apply_form
    detail = %`
邮箱：
#{params[:email]}
------------
真实姓名:
#{params[:name]}
------------
个人简介:
#{params[:description]}
    `
    user = User.find(1000001)
    collection_title = "激活码申请"
    collection = user.created_collections_db.find_by_title(collection_title)
    if collection.blank?
      user.create_collection_by_params(collection_title)
      collection = user.created_collections_db.find_by_title(collection_title)
    end
    user.send_feed("激活码申请",detail,
      :collection_ids=>collection.id.to_s,
      :from=>Feed::FROM_WEB)
    redirect_to "/apply_form?apply=success"
  end
end