module ApplicationMethods
  def to_logged_in_page
    if current_user && current_user.need_change_name?
      return redirect_to "/account/change_name"
    end
    redirect_back_or_default(root_url)
  end
end
