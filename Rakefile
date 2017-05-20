require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'fileutils'
include FileUtils

class String
  def first_line
    first = ''
    each_line { |line| first = line; break }
    first
  end
end

NAME = "aalib-ruby"
VERS = `darcs list tags`.first_line.chomp
PKG = "#{NAME}-#{VERS}"
RDOC_OPTS = ['--quiet', '--title', 'AA-lib for Ruby', '--main', 'README', '--inline-source']
PKG_FILES = `darcs list files`.split("\n")
GEMSPEC =
  Gem::Specification.new do |s|
    s.name = NAME
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.has_rdoc = true
    s.rdoc_options += RDOC_OPTS
    s.extra_rdoc_files = ["README", "ChangeLog", "COPYING"]
    s.summary = 'a graphics context and input library for text terminals'
    s.description = s.summary
    s.author = 'Patrick Mahoney'
    s.email = 'pat@polycrystal.org'
    s.homepage = 'http://aalib-ruby.rubyforge.org/'
    s.files = PKG_FILES
  end

desc "Run the tests"
task :default => [:test]

desc "Generates tar.gz and gem packages"
task :package

task :test => [:spec]

desc "Runs all tests"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*spec.rb']
end

desc "Compile documentation with RDoc"
task :doc => [:rdoc]

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/'
    rdoc.options += RDOC_OPTS
    rdoc.main = "README"
    rdoc.rdoc_files.add ['README', 'ChangeLog', 'COPYING', 'lib/**/*.rb']
end

Rake::GemPackageTask.new(GEMSPEC) do |p|
    p.need_tar = true
    p.gem_spec = GEMSPEC
end

task "lib" do
  directory "lib"
end

task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VERS}}
end

task :uninstall do
  sh %{sudo gem uninstall #{NAME}}
end
