class Admin::ApplyRecordsController < ApplicationController
  before_filter :login_required

  def index
    @apply_records = ApplyRecord.find(:all,:order=>"id desc").paginate(:per_page=>50,:page=>params[:page]||1)
  end
end
