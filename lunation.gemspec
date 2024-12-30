# frozen_string_literal: true

require_relative "lib/lunation/version"

Gem::Specification.new do |spec|
  spec.name = "lunation"
  spec.version = Lunation::VERSION
  spec.authors = ["Ivo Kalverboer"]
  spec.email = ["ivokalver@gmail.com"]

  spec.summary = "Astronomical Algorithms in Ruby"
  spec.description = "Lunation offers a Ruby implementation of Meeus's Astronomical Algorithms."
  spec.homepage = "https://www.github.com/valerius/lunation"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://www.github.com/valerius/lunation/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(
          "bin/",
          "test/",
          "spec/",
          "features/",
          ".git",
          ".github",
          "appveyor",
          "Gemfile"
        )
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "config"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end
