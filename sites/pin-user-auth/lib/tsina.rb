class Tsina
  SETTINGS = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)
  CALLBACK_URL = SETTINGS["tsina_callback_url"]
  API_KEY = SETTINGS["tsina_api_key"]
  API_SECRET = SETTINGS["tsina_api_secret"]

end