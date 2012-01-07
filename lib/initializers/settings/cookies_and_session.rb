# cookie_verification_secret
Rails.application.config.secret_token = '9f1e67be4945ad700daef99307e8b46313a3c781368e85e3d6ef8fd9142577c22ec4fb0e60f4671ba6939fed090a8bcdf1ebe1a0588120f327fa5e5e110940f6'

# session
case Rails.env
  when 'production'
    Rails.application.config.session_store :cookie_store, {
      :domain => 'mindpin.com',
      :key    => '_mindpin_session',
      :secret => '883abe7844502ee307e376fa4d0509253d7f9e55fc8be69a934735cd470cc8671af39e27482885960f3364fa8af420b5519571193e22987c3e9e4f9da29f15fb'
    }
  when 'development'
    Rails.application.config.session_store :cookie_store, {
      :domain => 'mindpin.com',
      :key    => '_mindpin_session_devel',
      :secret => '883abe7844502ee307e376fa4d0509253d7f9e55fc8be69a934735cd470cc8671af39e27482885960f3364fa8af420b5519571193e22987c3e9e4f9da29f15fb'
    }
end

# flash_cookie_session_fix
# 放在这里以保证config能取到值，否则由于加载顺序问题，取值可能为nil

class FlashCookieSessionMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      req = Rack::Request.new(env)

      session_key   = Rails.application.config.session_options[:key]
      session_value = req.params[session_key]
      
      Rails.logger.debug("flash cookie session key   : #{session_key}")
      Rails.logger.debug("flash cookie session value : #{session_value}")
      
      http_accept   = req.params['_http_accept']

      env['HTTP_COOKIE'] = [session_key, session_value].join('=').freeze if !session_value.blank?
      env['HTTP_ACCEPT'] = http_accept.freeze if !http_accept.blank?
    end
    @app.call(env)
  end
end

Rails.application.middleware.insert_before(
  Rails.application.config.session_store,
  FlashCookieSessionMiddleware
)