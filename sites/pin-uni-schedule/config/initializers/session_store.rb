# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pin-uni-schedule_session',
  :secret      => '471fbf10dda81c7d7d82f28e532436f4b3877bd780345eaf7d097a5b1c1e2a769e71683a25957503410fb83db867a9df625112364bb6fff7b9dff0309174821e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
