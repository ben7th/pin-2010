# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_management_session',
  :secret      => '682e50d4e015dc32776d107f5ed98dcf270d2ced82f32627d876245041d841ea4af0f0fff67829f844e8135d0d23a5820eac50d7e3e4b07690728da875dcd97d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
