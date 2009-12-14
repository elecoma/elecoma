# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ec_session',
  :secret      => '693ba966d5bf6db54a4329609a738a93b756debdf61bdd4b959dbdf1c98df7f994d5a95a11758dc8358fb1eeb0ae4944f5f14f502b5767799730c903f77e2888'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
 ActionController::Base.session_store = :active_record_store
