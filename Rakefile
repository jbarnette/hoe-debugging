require "rubygems"
require "hoe"

Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :bundler

Hoe.spec "hoe-debugging" do
  developer "John Barnette", "jbarnette@rubyforge.org"
  developer "Mike Dalessio", "mike.dalessio@gmail.com"

  self.extra_rdoc_files = FileList["*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.md"

  license "MIT"

  extra_dev_deps << ["bundler",       ">= 0"]
  extra_dev_deps << ["hoe",           "~> 3.1"]
  extra_dev_deps << ["hoe-bundler",   ">= 0"]
  extra_dev_deps << ["hoe-gemspec",   ">= 0"]
  extra_dev_deps << ["hoe-git",       ">= 0"]
  extra_dev_deps << ["rake-compiler", ">= 0"]
  extra_dev_deps << ["rspec",         "~> 3.5.0"]
end

task "spec" => ["bundler:gemfile", "gem:spec"] # so the integration tests work
