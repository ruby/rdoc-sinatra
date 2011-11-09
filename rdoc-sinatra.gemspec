# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name          = "rdoc-sinatra"
  s.version       = `git log --pretty=oneline | wc -l`.chomp.to_i + 1

  s.platform      = Gem::Platform::RUBY

  s.authors       = %w{Eero Saynatkari}
  s.email         = %w{projects@kittensoft.org}
  s.homepage      = "http://github.com/rdoc/rdoc-sinatra"

  s.summary       = %q{TODO: Write a gem summary}
  s.description   = %q{TODO: Write a gem description}

  s.files         = `git ls-files`.split "\n"
  s.test_files    = `git ls-files -- test/*`.split "\n"

  s.require_paths = %w{lib}

  s.add_runtime_dependency "rdoc", "~> 3.0"

  s.add_development_dependency "minitest"
end

