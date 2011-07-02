require "rubygems"
require "juggernaut"
Juggernaut.subscribe do |event, data|
  p event
  p data
end