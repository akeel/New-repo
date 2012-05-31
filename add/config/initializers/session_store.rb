# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_add_session',
  :secret      => '471e1d4503436a2b61752c7caebd90e0859b6e7b7de3ec5b34dab2b26797d33397dd076d44ec7d4f8e90407a7bfc5b19da3aa4712f74b80cc9bacc1bb3055232'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
