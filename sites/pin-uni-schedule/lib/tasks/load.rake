# load tasks
Dir[
  File.join(RAILS_ROOT, "../../lib/tasks", "**", "*.rb")
].sort.each { |patch|
  require(patch)
}