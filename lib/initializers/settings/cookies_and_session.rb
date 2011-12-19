# cookie_verification_secret
ActionController::Base.cookie_verifier_secret = '9f1e67be4945ad700daef99307e8b46313a3c781368e85e3d6ef8fd9142577c22ec4fb0e60f4671ba6939fed090a8bcdf1ebe1a0588120f327fa5e5e110940f6'

# session
case RAILS_ENV
  when 'production'
    ActionController::Base.session = {
      :domain => 'mindpin.com',
      :key    => '_mindpin_session',
      :secret => '883abe7844502ee307e376fa4d0509253d7f9e55fc8be69a934735cd470cc8671af39e27482885960f3364fa8af420b5519571193e22987c3e9e4f9da29f15fb'
    }
  else
    ActionController::Base.session = {
      :domain => 'mindpin.com',
      :key    => '_mindpin_session_devel',
      :secret => '883abe7844502ee307e376fa4d0509253d7f9e55fc8be69a934735cd470cc8671af39e27482885960f3364fa8af420b5519571193e22987c3e9e4f9da29f15fb'
    }
end
