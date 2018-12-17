Gem::Specification.new do |spec|
  spec.name          = "hyper_sh_resource"
  spec.version       = "0.0.1"
  spec.summary       = "hyper.sh deployment resource for Concourse"
  spec.authors       = ["Bence Monus"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/cromega/hyper-sh-resource"

  spec.files         = Dir.glob("lib/**/*")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "shell_mock", "~> 0.7"
  spec.add_development_dependency "pry-nav", "~> 0.2"
end
