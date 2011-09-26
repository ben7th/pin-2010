class ActivationController < ApplicationController
  def services
    render :layout=>"anonymous",:template=>"index/services"
  end

  def activation
    render :layout=>"anonymous",:template=>"index/activation"
  end

  def do_activation
    ActivationCode.acitvate_user(params[:code],current_user)
    redirect_to "/"
  rescue Exception => ex
    flash[:error] = ex.message
    redirect_to "/activation"
  end

  def apply
    render :layout=>"anonymous",:template=>"index/apply"
  end

  def do_apply
    ActivationApply.create(:email=>params[:email],
      :name=>params[:name],:description=>params[:description],
      :homepage=>params[:homepage]
    )
    redirect_to "/apply"
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
    coll_title = "激活码申请"
    coll = user.created_collections_db.find_by_title(coll_title)
    if coll.blank?
      user.create_collection_by_params(coll_title)
      coll = user.created_collections_db.find_by_title(coll_title)
    end
    user.send_feed("",detail,
      :collection_ids=>coll.id,
      :from=>Feed::FROM_WEB)
    redirect_to "/apply_form"
  end
end