$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lystonosha/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lystonosha"
  s.version     = Lystonosha::VERSION
  s.authors     = ["Roman Kushnir"]
  s.email       = ["broilerster@gmail.com"]
  s.homepage    = "https://github.com/RKushnir/lystonosha"
  s.summary     = "Allows users to send messages to each other."
  s.description = "Lystonosha(Postman) is a gem for internal communication between site users."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.0"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl"
end
