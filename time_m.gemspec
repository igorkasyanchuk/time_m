# frozen_string_literal: true

require_relative "lib/time_m/version"

Gem::Specification.new do |spec|
  spec.name = "time_m"
  spec.version = TimeM::VERSION
  spec.authors = ["Igor Kasyanchuk"]
  spec.email = ["igorkasyanchuk@gmail.com"]

  spec.summary = "Measure time in your code"
  spec.description = "Measure time in your code"
  spec.homepage = "https://github.com/igorkasyanchuk/time_m"
  spec.license = "MIT"
  spec.metadata["homepage_uri"] = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "colorize"

  spec.add_development_dependency "debug"
end
