# -*- encoding: utf-8 -*-
PKG_NAME      = 'contact_parser'
PKG_VERSION   = '1.0.0'
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

GEM_SPEC = spec = Gem::Specification.new do |s| 
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.author = "Matt Lightner"
  s.email = "mlightner@gmail.com"
  s.homepage = "http://github.com/mlightner/contact_parser/tree/master"
  s.platform = Gem::Platform::RUBY
  s.date = %q{2009-09-14}
  s.description = %q{Parses contact text blobs and optionally puts them into Highrise}
  s.files = ["README", "contact_parser.rb", "lib/phone_number.rb", "lib/contact_parser.rb"]
  s.has_rdoc = false
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Parses contact data and puts it into highrise}
  s.add_dependency('validatable', '>= 1.6.0')
  s.add_dependency('tapajos-highrise', '>= 0.8.0')
  s.add_dependency('curb', '>= 0.5.1.0')
  s.add_dependency('hpricot', '>= 0.8.1')
end
