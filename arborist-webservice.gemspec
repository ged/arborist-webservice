# -*- encoding: utf-8 -*-
# stub: arborist-webservice 0.0.1.pre20161005112659 ruby lib

Gem::Specification.new do |s|
  s.name = "arborist-webservice"
  s.version = "0.0.1.pre20161005112659"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Granger"]
  s.cert_chain = ["certs/ged.pem"]
  s.date = "2016-10-05"
  s.description = "This is a collection of webservice monitoring tools for the Arborist monitoring toolkit (http://arbori.st/).\n\nIt can be used to describe and monitor HTTP services in more detail than a simple port check."
  s.email = ["ged@FaerieMUD.org"]
  s.extra_rdoc_files = ["History.md", "Manifest.txt", "README.md", "History.md", "README.md"]
  s.files = [".document", ".editorconfig", ".rdoc_options", ".simplecov", "ChangeLog", "History.md", "Manifest.txt", "README.md", "Rakefile", "lib/arborist/monitor/webservice.rb", "lib/arborist/node/webservice.rb", "lib/arborist/webservice.rb", "spec/arborist/node/webservice_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://deveiate.org/projects/arborist-webservice"
  s.licenses = ["BSD-3-Clause"]
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.5.1"
  s.summary = "This is a collection of webservice monitoring tools for the Arborist monitoring toolkit (http://arbori.st/)"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<arborist>, ["~> 0"])
      s.add_runtime_dependency(%q<loggability>, ["~> 0.11"])
      s.add_runtime_dependency(%q<httpclient>, ["~> 2.7"])
      s.add_development_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>, ["~> 0.8"])
      s.add_development_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>, ["~> 0.1"])
      s.add_development_dependency(%q<hoe>, ["~> 3.15"])
    else
      s.add_dependency(%q<arborist>, ["~> 0"])
      s.add_dependency(%q<loggability>, ["~> 0.11"])
      s.add_dependency(%q<httpclient>, ["~> 2.7"])
      s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>, ["~> 0.8"])
      s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-fivefish>, ["~> 0.1"])
      s.add_dependency(%q<hoe>, ["~> 3.15"])
    end
  else
    s.add_dependency(%q<arborist>, ["~> 0"])
    s.add_dependency(%q<loggability>, ["~> 0.11"])
    s.add_dependency(%q<httpclient>, ["~> 2.7"])
    s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>, ["~> 0.8"])
    s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>, ["~> 0.1"])
    s.add_dependency(%q<hoe>, ["~> 3.15"])
  end
end
