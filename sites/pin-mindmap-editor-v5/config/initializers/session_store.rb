case RAILS_ENV
  when 'production'
    ActionController::Base.session = {
      :domain => "mindpin.com",
      :key=>'_mindpin_session',
      :secret=>'883abe7844502ee307e376fa4d0509253d7f9e55fc8be69a934735cd470cc8671af39e27482885960f3364fa8af420b5519571193e22987c3e9e4f9da29f15fb'
    }
  else
    ActionController::Base.session = {
      :domain => "mindpin.com", 
      :key=>'_mindpin_session_devel',
      :secret=>'883abe7844502ee307e376fa4d0509253d7f9e55fc8be69a934735cd470cc8671af39e27482885960f3364fa8af420b5519571193e22987c3e9e4f9da29f15fb'
    }
end

ActionController::Dispatcher.middleware.insert_before(
  ActionController::Base.session_store,
  FlashSessionCookieMiddleware,
  ActionController::Base.session_options[:key]
)
