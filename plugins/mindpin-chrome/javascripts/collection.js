var BG = BG || chrome.extension.getBackgroundPage();

Collection = {
  // 给空间列表选择框填充值
  get_workspaces_to_select: function(){
    $.ajax({
      url: BG.Mindpin.WORKSPACE_LIST_URL,
      type: "get",
      dataType: "json",
      success: function(arr){
        var options = ""
        $(arr).each(function(){
          var workspace = this.workspace
          var id = workspace.id
          var name = workspace.name
          options += "<option value='"+ id +"'>"+ name +"</option>"
        });
        $("#workspaces").append(options);
      }
    })
  }

}