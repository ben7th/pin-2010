RAILS_ROOT ||= ENV["RAILS_ROOT"]

namespace :bundle do
  task :all => [ :js, :css ]

  task :js do
    closure_path = RAILS_ROOT + '/lib/closure_compiler.jar'
    paths = get_top_level_directories('/public/javascripts')
    all_files = []

    paths.each do |bundle_directory|
      bundle_name = bundle_directory.gsub(RAILS_ROOT + '/public/javascripts/', "")
      files = recursive_file_list(bundle_directory, ".js")
      next if files.empty? || ['dev','lib'].include?(bundle_name)

      all_files += files
    end

    target = RAILS_ROOT + "/public/javascripts/bundle_base.js"
    `java -jar #{closure_path} --js #{all_files.join(" --js ")} --js_output_file #{target} 2> /dev/null`
    puts "=> bundled js at #{target}"
  end

  task :css do
    yuipath = RAILS_ROOT + '/lib/yuicompressor-2.4.2.jar'
    paths = get_top_level_directories('/public/stylesheets')
    all_files = []

    paths.each do |bundle_directory|
      bundle_name = bundle_directory.gsub(RAILS_ROOT + '/public/stylesheets/', "")
      files = recursive_file_list(bundle_directory, ".css")
      next if files.empty? || ['dev','themes','help'].include?(bundle_name)

      all_files += files
    end

    bundle = ''
    all_files.each do |file_path|
      bundle << File.read(file_path) << "\n"
    end

    target = RAILS_ROOT + "/public/stylesheets/bundle_base.css"
    rawpath = "/tmp/bundle_raw.css"
    File.open(rawpath, 'w') { |f| f.write(bundle) }
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