# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "schedule_atts/version"

Gem::Specification.new do |s|
  s.name        = "schedule_atts"
  s.version     = ScheduleAtts::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mike Nicholaides"]
  s.email       = ["mike@ablegray.com"]
  s.homepage    = "http://ablegray.com"
  s.summary     = %q{Provides form attributes setting a recurring schedule.}
  s.description = %q{Provides form attributes setting a recurring schedule.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'ice_cube', '>= 0.6.4'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rspec', '>= 2.3'
  s.add_development_dependency 'facets'
end
