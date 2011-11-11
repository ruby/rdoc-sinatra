begin
  gem "rdoc", "~> 3"
  require "rdoc/parser/sinatra"

rescue Gem::LoadError
  # Meh
end
