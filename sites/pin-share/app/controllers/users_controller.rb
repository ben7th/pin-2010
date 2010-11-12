class UsersController < ApplicationController
  def show
    @user=User.find(params[:id])
    if logged_in? && @user == current_user
      @user_shares = @user.my_and_contacting_shares.paginate(:page => params[:page] ,:per_page=>30 )
    else
      @user_shares = @user.shares.paginate(:page => params[:page] ,:per_page=>30 )
    end
    respond_to do |format|
      format.html {} # 这一行必须有而且必须在下面这行之前，否则IE里会出问题
      format.xml {render :xml=>@user.to_xml(:only=>[:id,:name,:created_at],:methods=>:logo)}
    end
  end

end