Dir[File.join(RAILS_ROOT,"../../lib/patches","**","*.rb")].sort.each { |patch| require(patch)}



