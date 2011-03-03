class ContactsSettingController < ApplicationController
  before_filter :login_required
  def contacts
    @contacts = current_user.contacts
  end
  def invite;end
  # 团队首页
  def organizations; end

end
