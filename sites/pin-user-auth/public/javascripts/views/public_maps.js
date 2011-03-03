/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
pie.load(function(){
  $$(".cache_mindmap_image").each(function(dom){
    var gmt = new GetMindmapImage(dom.id,pie.pin_url_for("pin-mindmap-image-cache"));
    gmt.get_mindmap_image();
  });
});


