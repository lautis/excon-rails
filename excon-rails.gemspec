# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'excon/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "excon-rails"
  spec.version       = Excon::Rails::VERSION
  spec.authors       = ["Ville Lautanala"]
  spec.email         = ["lautis@gmail.com"]
  spec.summary       = %q{Railtie to include Excon HTTP requests in Rails logging.}
  spec.description   = %q{Log HTTP requests made via Excon and their total runtime in Rails request log.}
  spec.homepage      = "https://github.com/lautis/excon-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "excon", ">= 0.18.0"
  spec.add_dependency "activesupport", ">= 3.0"
  spec.add_dependency "sweet_notifications", "~> 0.1"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 1.18"
end
