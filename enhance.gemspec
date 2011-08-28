$:.push File.join(File.dirname(__FILE__), '/lib')

require 'enhance/version'

Gem::Specification.new do |gem|
  gem.name = "enhance"
  gem.authors = ['Guillaume Malette']
  gem.date = %q{2011-08-26}
  gem.description = %q{Middleware to "enhance" and resize images on the fly.}
  gem.summary = "Image resizing on the fly"
  gem.email = 'gmalette@gmail.com'
  gem.homepage = ''
  
  gem.add_runtime_dependency 'rack'
  gem.add_runtime_dependency 'utilities'
  gem.add_development_dependency 'rack-test'
  
  gem.executables   = []
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ['lib']
  gem.version       = Enhance::VERSION
end
