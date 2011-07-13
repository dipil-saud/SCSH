# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{twitter4r}
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Susan Potter"]
  s.autorequire = %q{twitter}
  s.date = %q{2011-07-11}
  s.email = %q{twitter4r-users@googlegroups.com}
  s.executables = ["t4rsh", "t4r-oauth-access"]
  s.files = ["bin/t4rsh", "bin/t4r-oauth-access"]
  s.homepage = %q{http://twitter4r.rubyforge.org}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.requirements = ["Ruby 1.8.6+", "json gem, version 0.4.3 or higher", "jcode (for unicode support)"]
  s.rubyforge_project = %q{twitter4r}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A clean Twitter client API in pure Ruby. Will include Twitter add-ons also in Ruby.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 1.1.1"])
      s.add_runtime_dependency(%q<oauth>, [">= 0.4.1"])
    else
      s.add_dependency(%q<json>, [">= 1.1.1"])
      s.add_dependency(%q<oauth>, [">= 0.4.1"])
    end
  else
    s.add_dependency(%q<json>, [">= 1.1.1"])
    s.add_dependency(%q<oauth>, [">= 0.4.1"])
  end
end
