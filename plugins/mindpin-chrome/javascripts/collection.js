var BG = BG || chrome.extension.getBackgroundPage();

Collection = {
  // 给空间列表选择框填充值
  get_workspaces_to_select: function(){
    
    $.ajax({
      url: BG.Mindpin.WORKSPACE_LIST_URL,
      type: "get",
      dataType: "json",
      success: function(arr){
        if(arr.length == 0){
          // 给新建工作空间链接增加地址
          $("#new_workspace").attr("href",BG.Mindpin.NEW_WORKSPACE_URL)
          $("#create_workspace_tip").css("visibility","visible");
          $("#send_btn").attr("disabled",true)
          return;
        }
        var options = ""
        $(arr).each(function(){
          var workspace = this.workspace
          var id = workspace.id
          var name = workspace.name
          options += "<option value='"+ id +"'>"+ name +"</option>"
        });
        $("#workspaces").append(options);
        $("#send_btn").attr("disabled",false)
      }
    })
  }

}