
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aasm/validation/version"

Gem::Specification.new do |spec|
  spec.name          = "aasm-validation"
  spec.version       = AASM::Validation::VERSION
  spec.authors       = ["khun84"]
  spec.email         = ["khun84@gmail.com"]

  spec.summary       = %q{Human readable validation errors for aasm}
  spec.description   = %q{A gem that would allows you specify guard errors and retrieve them later}
  spec.homepage      = "https://github.com/khun84/aasm-validation"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.3'


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'aasm', '~> 4.12'
  spec.add_dependency 'activemodel', '~> 5.0'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
