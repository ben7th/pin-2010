RAILS_ROOT ||= ENV["RAILS_ROOT"]

namespace :bundle do
  task :all => [ :editor, :viewer ]

  task :editor do
    closure_path = RAILS_ROOT + '/../pin-v4-web-ui/lib/closure_compiler.jar'
    
    files = [
      'pie_mpaccordion.js',
      'pie_dragdrop.js',
      'pie_mindmap_node_dragdrop.js',
      'pie_map_menu.js',
      'editors/pie_mindmap_node_title_editor.js',
      'editors/pie_mindmap_node_note_editor.js',
      'editors/pie_mindmap_node_image_editor.js',
      'editors/pie_mindmap_node_color_editor.js',
      'pie_mindmap_operation_record_factory.js',
      'pie_mindmap_node.js',
      'pie_mindmap_canvas_draw_module.js',
      'pie_mindmap_menu_module.js',
      'pie_mindmap_save_module.js',
      'pie_mindmap_cooprate_response_module.js',
      'pie_mindmap_modifying_methods.js',
      'pie_mindmap.js'
    ].map{|x| RAILS_ROOT + '/public/javascripts/pie/mindmap/' + x}
    # 顺序是固定的！！

    puts files
    target = RAILS_ROOT + "/public/javascripts/mindmap_editor_packed.js"

    `java -jar #{closure_path} --js #{files.join(" --js ")} --js_output_file #{target} 2> /dev/null`

    puts "=> bundled js at #{target}"
  end

  task :viewer do
    closure_path = RAILS_ROOT + '/../pin-v4-web-ui/lib/closure_compiler.jar'

    files = [
      'pie_dragdrop.js',
      'pie_mindmap_node.js',
      'pie_mindmap_canvas_draw_module.js',
      'pie_mindmap_modifying_methods.js', # 这个必须加载，里面有节点折叠展开的相关函数
      'pie_mindmap.js'
    ].map{|x| RAILS_ROOT + '/public/javascripts/pie/mindmap/' + x}
    # 顺序是固定的！！

    puts files
    target = RAILS_ROOT + "/public/javascripts/mindmap_viewer_packed.js"

    `java -jar #{closure_path} --js #{files.join(" --js ")} --js_output_file #{target} 2> /dev/null`

    puts "=> bundled js at #{target}"
  end
end