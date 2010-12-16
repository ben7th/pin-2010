module ActivityHelper
  def activity_to_html(activity)
    operator = User.find_by_email(activity.operator)
    case activity.event
    when 'add_org_member'
      %~
        <div class='title'>
          <div class='avatar'>
            #{avatar operator,:tiny}
          </div>
          <div class='fleft'>
            <span class='loud'>#{operator.name}</span>
            在团队
            <span class='loud'>#{activity.location.name}</span>
            添加了成员
            <span class='loud'>#{activity.target.name}</span>
          </div>
        </div>
      ~
    when 'delete_org_member'
      %~
        <div class='title'>
          <div class='avatar'>
            #{avatar operator,:tiny}
          </div>
          <div class='fleft'>
            <span class='loud'>#{operator.name}</span>
            把成员
            <span class='loud'>#{activity.target.name}</span>
            移除出了团队
            <span class='loud'>#{activity.location.name}</span>
          </div>
        </div>
      ~
    end
  end
end
