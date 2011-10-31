# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "spree_aprova_facil/version"

Gem::Specification.new do |s|
  s.name        = "spree_aprova_facil"
  s.version     = SpreeAprovaFacil::VERSION
  s.authors     = ["Raphael Costa"]
  s.email       = ["raphael@experia.com.br"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "spree_aprova_facil"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "spree_core", '>= 0.60.1'
  s.add_runtime_dependency "aprova_facil", '>= 1.2.0'
end
