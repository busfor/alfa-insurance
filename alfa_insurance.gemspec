# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alfa_insurance/version'

Gem::Specification.new do |spec|
  spec.name          = "alfa_insurance"
  spec.version       = AlfaInsurance::VERSION
  spec.authors       = ["Alexander Sviridov"]
  spec.email         = ["alexander.sviridov@gmail.com"]

  spec.summary       = %q{Ruby wrapper for ALfaInsurance SOAP API}
  spec.homepage      = "https://github.com/busfor/alfa-insurance/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.1"
  spec.add_dependency "nokogiri", "~> 1"
  spec.add_dependency "money", "~> 6.7"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
end
