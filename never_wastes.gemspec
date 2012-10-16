# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "never_wastes/version"

Gem::Specification.new do |s|
  s.name        = "never_wastes"
  s.version     = NeverWastes::VERSION
  s.authors     = ["nay3"]
  s.email       = ["y.ohba@everyleaf.com"]
  s.homepage    = ""
  s.summary     = %q{simple soft delete for ActiveRecord}
  s.description = %q{It changes ActiveRecord::Base#destroy to support soft delete. Kind of simple acts_as_paranoid.}

  s.rubyforge_project = "never_wastes"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  %w{ activesupport activerecord }.each do |gem|
    s.add_dependency gem, ['>= 3.0.0']
  end

  s.add_development_dependency 'bundler', ['>= 1.0.0']
  s.add_development_dependency 'sqlite3', ['>= 0']
  s.add_development_dependency 'rspec', ['>= 0']
  s.add_development_dependency 'factory_girl', ['< 3']
  s.add_development_dependency 'database_cleaner', ['>= 0']
end
