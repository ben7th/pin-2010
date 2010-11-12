module ContactHelper
  def contact_each_other_icon(user1,user2)
    if user1.contact_each_other?(user2)
      "<div class='contacts marginr5' title='互相关注'></div>"
    end
  end

  def follow_link(target_user)
    if !current_user.follow?(target_user)
      %~
      <div>
        #{link_to_remote "＋关注",
      :url=>"/contactings?contact_id=#{target_user.id}&tab=contacter",
      :method=>:post}
      </div>
      ~
    end
  end

  def cancel_follow_link(target_user)
    if current_user.follow?(target_user)
      contacting = current_user.contactings.find_by_contact_id(target_user)
      %~
      <div>
        #{link_to_remote "取消关注",
      :url=>contacting,
      :method=>:delete,
      :confirm=>"取消对 #{target_user.name} 的关注，确认吗？"}
      </div>
      ~
    end
  end

  def remove_fans_link(target_user)
    if target_user.follow?(current_user)
      contacting = target_user.contactings.find_by_contact_id(current_user)
      %~
      <div>
        #{link_to_remote "移除关注",
      :url=>contacting,
      :method=>:delete,
      :confirm=>"移除 #{target_user.name} 对你的关注，确认吗？"}
      </div>
      ~
    end
  end

  def setting_contacting_show_share(contacting)
    no_show_name = contacting.show_share ? "hide" : ''
    show_name = contacting.show_share ? "" : 'hide'
    %~
      <div class='margint5 whether_show_share'>
        <div>显示分享</div>
        <span class="#{show_name} show_share_span">
          <b>是</b> | #{link_to_remote "否",:url=>polymorphic_path(contacting,:show_share=>"false"),:method=>:put}
        </span>
        <span class="#{no_show_name} not_show_share_span">
          #{link_to_remote "是",:url=>polymorphic_path(contacting,:show_share=>"true"),:method=>:put} | <b>否</b>
        </span>
      </div>
    ~
  end

  def follow_info_in_other_user_page(target_user)
    render :partial=>"contactings/parts/list_follow_action",:locals=>{:user=>target_user}
  end

  def contacting_user_not_found(contacting)
    %~
      <div>该用户不存在，可能已被删除</div>
      #{link_to_remote "删除关注记录",:url=>contacting,:method=>:delete}
    ~
  end
end
