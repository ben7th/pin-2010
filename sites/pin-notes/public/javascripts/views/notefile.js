/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
(function(){

  jQuery(".add_another").click(function(evt){
    var file_names = jQuery(".notefiles .notefile").map(function(){
      return jQuery(this).attr("data-notefile_name")
    }).get();
    file_names = jQuery.grep(file_names, function(file_name,index){
      return /^notefile_[0-9]+$/.test(file_name);
    });
    var ids = jQuery.map(file_names,function(file_name){
      return /notefile_([0-9]+)/.exec(file_name)[1];
    });
    ids.push(0)
    var next_id = Math.max.apply( Math, ids ) + 1
    jQuery.ajax({
      type: "GET",
      url: "/notes/add_another",
      data: {
        "next_id" : next_id
      },
      success: function(dom_str){
        jQuery(".notefiles").append(dom_str)
      }
    });
    evt.preventDefault();
  });

  jQuery(".delete_notefile").click(function(evt){
    if(confirm("确定要删除吗？")){
      var notefile = jQuery(this).closest(".notefile")
      notefile.find(".notefile_form").remove()
      notefile.find(".notefile_delete_tip").removeClass("hide")
      notefile.find(".delete_notefile").addClass("hide")
      hide_delete_notefile()
    }
    evt.preventDefault();
  });

  function hide_delete_notefile(){
    if(jQuery(".notefiles .notefile_form").size() == 1){
      jQuery(".notefiles .notefile").each(function(){
        jQuery(this).find(".delete_notefile").addClass("hide")
      })
    }
  }
})();


