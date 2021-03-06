# -*- encoding: utf-8 -*-
require File.expand_path('../lib/last-resort/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ian Ha", "Victor Mota", "Scott Hyndman"]
  gem.email         = ["ianha0@gmail.com", "vimota@gmail.com", "scotty.hyndman@gmail.com"]
  gem.summary       = "Calls your phone when critical emails arrive"
  gem.description   = "Last Resort is a Ruby gem for monitoring email sent by automated services (monit, logging packages, external ping services, etc.) and calling your phone to tell you about the important ones. Using free and trial tiers available from context.io, twilio and heroku, Last Resort can be deployed in a reliable environment and perform up to 1500 emergency calls for free."
  gem.homepage      = "https://github.com/ianha/LastResort"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "last-resort"
  gem.require_paths = ["lib"]
  gem.version       = LastResort::VERSION

  gem.add_dependency "sinatra", "~> 1.3"
  gem.add_dependency "twilio-ruby", "~> 3.6"
  gem.add_dependency "oauth", "~> 0.4"
  gem.add_dependency "gli", "~> 1.6"
  gem.add_dependency "colored"
  gem.add_dependency "launchy", "~> 2.1"
  gem.add_development_dependency 'rspec', '~> 2.9.0'
  gem.add_development_dependency 'webmock', '~> 1.8.5'
  gem.add_development_dependency "awesome_print"
  gem.add_development_dependency "rack"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "nokogiri"
end
