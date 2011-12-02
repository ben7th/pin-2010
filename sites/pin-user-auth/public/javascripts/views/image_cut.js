pie.load(function(){
  new Cropper.ImgWithPreview('img_with_preview',{
    previewWrap: 'preview_wrap',
    minWidth : 48,
    minHeight : 48,
    ratioDim : { x:48, y:48 },
    isCenter : true,
    onEndCrop : function(evt,coords, dimensions){
      $("copper_form").down("#x1").value = coords.x1
      $("copper_form").down("#y1").value = coords.y1
      $("copper_form").down("#width").value = dimensions.width
      $("copper_form").down("#height").value = dimensions.height
    }
  });
})