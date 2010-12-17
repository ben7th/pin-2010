RAILS_ROOT ||= ENV["RAILS_ROOT"]

namespace :bundle do
  task :js do
    closure_path = RAILS_ROOT + '/../pin-v4-web-ui/lib/closure_compiler.jar'
    
    files = [
      'pie_dragdrop.js',
      'pie_mindmap_node_dragdrop.js',
      'pie_map_menu.js',
      'pie_mindmap_node_editor.js',
      'pie_opfactory.js',
      'pie_mindmap_node.js',
      'pie_mindmap_json_loader.js',
      'pie_mindmap_canvas_draw_module.js',
      'pie_mindmap_menu_module.js',
      'pie_mindmap_save_module.js',
      'pie_mindmap.js'
    ].map{|x| RAILS_ROOT + '/public/javascripts/pie/mindmap/' + x}
    # 顺序是固定的！！

    puts files
    target = RAILS_ROOT + "/public/javascripts/mindmap_packed.js"

    `java -jar #{closure_path} --js #{files.join(" --js ")} --js_output_file #{target} 2> /dev/null`

    puts "=> bundled js at #{target}"
  end

  require 'find'
  def recursive_file_list(basedir, ext)
    files = []
    Find.find(basedir) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?. # Skip dot directories
          Find.prune
        else
          next
        end
      end
      files << path if File.extname(path) == ext
    end
    files.sort
  end
end