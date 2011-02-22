class SinaWeibo
  SETTINGS = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)
  CALLBACK_URL = SETTINGS["sina_callback_url"]
  API_KEY = SETTINGS["sina_api_key"]
  API_SECRET = SETTINGS["sina_api_secret"]

end