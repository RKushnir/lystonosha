$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lystonosha/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lystonosha"
  s.version     = Lystonosha::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Lystonosha."
  s.description = "TODO: Description of Lystonosha."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.3"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl"
end
