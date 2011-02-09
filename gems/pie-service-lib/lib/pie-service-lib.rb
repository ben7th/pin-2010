begin
  require 'pie-service-lib/base_metal'
  require 'pie-service-lib/handle_get_request'

  require 'pie-service-lib/mindmap_images/methods/mindmap_to_image_param_methods'
  require 'pie-service-lib/mindmap_images/methods/mindmap_to_image_hash_methods'
  require 'pie-service-lib/mindmap_images/methods/mindmap_to_image_paint_methods'
  require 'pie-service-lib/mindmap_images/mindmap_to_image'
  require 'pie-service-lib/mindmap_images/mindmap_image_cache'
rescue Exception => ex
  p ex
end

