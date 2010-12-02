if(typeof(Mindpin)=='undefined'){Mindpin = {}}
Mindpin.LOGIN_URL = "http://2010.mindpin.com/login_by_extension"
Mindpin.LOGOUT_URL = "http://2010.mindpin.com/logout"

Mindpin.WEB_SITE_INFOS_URL = "http://website.2010.mindpin.com/sidebar/web_site_infos"

Mindpin.WEB_SITE_COMMENTS_URL = "http://website.2010.mindpin.com/sidebar/comments"

Mindpin.BROWSE_HISTORIES_URL = "http://website.2010.mindpin.com/sidebar/browse_histories_infos"


Mindpin.SUBMIT_BROWSE_HISTORIES_URL = "http://website.2010.mindpin.com/browse_histories"

Mindpin.CURRENT_PAGE_CONTENT_URL = "http://website.2010.mindpin.com/sidebar/one_browse_histories_infos"

Mindpin.SUBMIT_SHARE_URL = "http://share.2010.mindpin.com/add_on_shares" 

Mindpin.REGISTER_URL = "http://2010.mindpin.com/signup"

Mindpin.PRODUCE_MINDMAP_URL = "http://app-adapter.2010.mindpin.com/app/mindmap_editor/creare_mindmap_from_html"

Mindpin.MINDMAP_LIST_URL = "http://app-adapter.2010.mindpin.com/app/mindmap_editor"

Mindpin.DISCUSSION_DOMAIN_URL = "http://discuss.2010.mindpin.com"

Mindpin.WORKSPACE_LIST_URL = "http://workspace.2010.mindpin.com/workspaces.json"

Mindpin.SUBMIT_DISCUSSION_URL = "http://discuss.2010.mindpin.com/add_on_create_discussion"
	
Mindpin.SHARE_LIST_URL = "http://share.2010.mindpin.com/"

Mindpin.NEW_WORKSPACE_URL = "http://workspace.2010.mindpin.com/workspaces/new"

Mindpin.user_mindmaps_url = function(user_id){
  return "http://mindmap-editor.mindpin.com/users/" + user_id + "/mindmaps.json";
};

Mindpin.edit_mindmap_url = function(mindmap_id){
  return "http://mindmap-editor.mindpin.com/mindmaps/" + mindmap_id + "/edit";
};

Mindpin.CREATE_MINDMAP_URL = "http://mindmap-editor.mindpin.com/mindmaps/create_base64.json"

Mindpin.IMPORT_MINDMAP_URL = "http://mindmap-editor.mindpin.com/mindmaps/import_base64.json"

Mindpin.CONCATS_URL = "http://www.mindpin.com/concats.json"

Mindpin.ADD_CONCAT_URL = "http://www.mindpin.com/concats/create_for_plugin"

Mindpin.DESTROY_CONCAT_URL = "http://www.mindpin.com/concats/destroy_for_plugin"