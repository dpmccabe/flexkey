# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flexkey/version'

Gem::Specification.new do |spec|
  spec.name          = 'flexkey'
  spec.version       = Flexkey::VERSION
  spec.authors       = ['Devin McCabe']
  spec.email         = ['devin.mccabe@gmail.com']
  spec.description   = %q{Flexible product key generation}
  spec.summary       = %q{Use Flexkey to generate random product keys for use in software licenses, invoices, etc.}
  spec.homepage      = 'https://github.com/dpmccabe/flexkey'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
end
