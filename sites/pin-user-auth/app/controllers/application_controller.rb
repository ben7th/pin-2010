# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all

  protect_from_forgery

  # 通过插件开启gzip压缩
  after_filter OutputCompressionFilter
end