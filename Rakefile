require 'rubygems' unless ENV['NO_RUBYGEMS']
%w[rake rake/clean fileutils newgem hoe rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/alsa_backup'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec('alsa-backup') do |p|
  p.version = AlsaBackup::VERSION
  p.readme_file   = 'README.rdoc'
  p.developer('Alban Peignier', 'alban@tryphon.eu')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.rubyforge_name       = p.name # TODO this is default value
  p.extra_deps         = [
    ['ffi','>= 0.3.5'], [ 'newgem', ">= #{::Newgem::VERSION}" ], [ 'daemons', '>= 1.0.10' ]
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  p.url = 'http://projects.tryphon.eu/alsa-backup'
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

desc 'Recreate Manifest.txt to include ALL files'
task :manifest do
  `rake check_manifest | patch -p0 > Manifest.txt`
end

desc "Generate a #{$hoe.name}.gemspec file"
task :gemspec do
  File.open("#{$hoe.name}.gemspec", "w") do |file|
    file.puts $hoe.spec.to_ruby
  end
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

task :default => :spec

namespace :gems do
  task :install do
    gems = %w{active_support ffi rspec daemons}
    sh "sudo gem install #{gems.join(' ')}"
  end
end

require 'debian/build'

include Debian::Build
require 'debian/build/config'

namespace "package" do
  Package.new(:"alsa-backup") do |t|
    t.version = '0.0.8'
    t.debian_increment = 1

    t.source_provider = GitExportProvider.new
  end
end

require 'debian/build/tasks'
