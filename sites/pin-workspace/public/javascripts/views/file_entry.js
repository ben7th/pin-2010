jQuery("#file_entry_content").bind("change",function(evt){
  jQuery(this).closest("form").submit();
});

jQuery(".add_file").click(function(evt){
  jQuery(this).addClass("hide");
  jQuery(".file_entry_form").removeClass("hide");
  evt.preventDefault();
});
