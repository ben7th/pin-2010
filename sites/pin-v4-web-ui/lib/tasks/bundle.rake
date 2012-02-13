namespace :bundle do
  task :all => [ :js, :css ]

  # javascript 打包
  task :js do
    closure_path = Rails.root.to_s + '/lib/closure_compiler.jar'
    
    all_files = []
    # 顺序不能错！
    ['mindpin', 'common', 'util'].each do |bundle_name|
      bundle_directory = "public/javascripts/#{bundle_name}"
      
      files = recursive_file_list(bundle_directory, ".js")
      next if files.empty?
      all_files += files if !files.blank?
    end

    target = 'public/javascripts/bundle_base.js'
    
    `java -jar #{closure_path} --js #{all_files.join(" --js ")} --js_output_file #{target} 2> /dev/null`
    puts "=> bundled js at #{target}"
  end

  # css 打包
  task :css do
    yuipath = 'lib/yuicompressor-2.4.2.jar'

    rawpath = 'public/stylesheets/all.css'
    target  = 'public/stylesheets/all_packed.css'

    `java -jar #{yuipath} --line-break 0 #{rawpath} -o #{target}`
    puts "=> bundled css at #{target}"
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