RAILS_ROOT ||= ENV["RAILS_ROOT"]

namespace :bundle do
  task :all => [ :js, :css ]

  # javascript 打包
  task :js do
    closure_path = RAILS_ROOT + '/lib/closure_compiler.jar'
    paths = get_top_level_directories('/public/javascripts')
    all_files = []

    paths.each do |bundle_directory|
      bundle_name = bundle_directory.gsub(RAILS_ROOT + '/public/javascripts/', "")
      files = recursive_file_list(bundle_directory, ".js")
      next if files.empty? || !['common','mindpin','util'].include?(bundle_name)

      all_files += files
    end

    target = RAILS_ROOT + "/public/javascripts/bundle_base.js"
    `java -jar #{closure_path} --js #{all_files.join(" --js ")} --js_output_file #{target} 2> /dev/null`
    puts "=> bundled js at #{target}"
  end

  # css 打包
  task :css do
    yuipath = RAILS_ROOT + '/lib/yuicompressor-2.4.2.jar'
    paths = get_top_level_directories('/public/stylesheets')

    rawpath = RAILS_ROOT + "/public/stylesheets/all.css"
    target = RAILS_ROOT + "/public/stylesheets/all_packed.css"

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

  def get_top_level_directories(base_path)
    Dir.entries(RAILS_ROOT + base_path).collect do |path|
      path = RAILS_ROOT + "#{base_path}/#{path}"
      File.basename(path)[0] == ?. || !File.directory?(path) ? nil : path # not dot directories or files
    end - [nil]
  end
end