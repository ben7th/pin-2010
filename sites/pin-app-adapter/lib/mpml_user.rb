module MpmlUser
  def parse_mpml_user_tags
    parse_user_card
    parse_user_name
  end

  def parse_user_card
    doc.css('mp|user-card').each do |uc|
      user = User.find(uc['userid'])
      site = pin_url_for("pin-share","/users/#{user.id}")
      uc.after %~
        <div class='clearfix mp-user-card'>
          <div class="fleft">
            <div><a href='#{site}'>#{logo user}</a></div>
          </div>
          <div class='fleft marginl5' style='width:120px;'>
            <div><a class='username' href='#{site}'>#{user.name}</a></div>
            <div class='quiet'>#{created_at user} 加入</div>
          </div>
        </div>
      ~
      uc.remove
    end
  end

  def parse_user_name
    doc.css('mp|user-name').each do |uc|
      user = User.find_by_id(uc['userid'])
      name = user.blank? ? '[已删除]' : user.name
      uc.after name
      uc.remove
    end
  end

  include ImagesHelper
  include LinkHelper
  include ActionController::RecordIdentifier
  include DatetimeHelper
end
