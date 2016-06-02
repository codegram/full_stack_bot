use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :doctorprats, Doctorprats.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :doctorprats, :facebook,
  access_token: System.get_env("FACEBOOK_ACCESS_TOKEN")
