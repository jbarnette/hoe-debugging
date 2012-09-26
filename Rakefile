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
  self.readme_file      = "README.rdoc"

  extra_dev_deps << ["rspec", "~> 2.0"]
  extra_dev_deps << ["hoe-git",     ">= 0"]
  extra_dev_deps << ["hoe-gemspec", ">= 0"]
  extra_dev_deps << ["hoe-bundler", ">= 0"]
end
