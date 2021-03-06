# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{alsa-backup}
  s.version = "0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alban Peignier"]
  s.date = %q{2010-10-14}
  s.default_executable = %q{alsa-backup}
  s.description = %q{ALSA client to perform continuous recording}
  s.email = ["alban@tryphon.eu"]
  s.executables = ["alsa-backup"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = [".autotest", "COPYING", "COPYRIGHT", "History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "TODO", "alsa-backup.gemspec", "bin/alsa-backup", "config.sample", "lib/alsa_backup.rb", "lib/alsa_backup/cli.rb", "lib/alsa_backup/core_ext.rb", "lib/alsa_backup/length_controller.rb", "lib/alsa_backup/recorder.rb", "lib/alsa_backup/writer.rb", "lib/sndfile.rb", "lib/syslog_logger.rb", "script/console", "script/destroy", "script/generate", "setup.rb", "spec/alsa_backup/cli_spec.rb", "spec/alsa_backup/core_ext_spec.rb", "spec/alsa_backup/length_recorder_spec.rb", "spec/alsa_backup/recorder_spec.rb", "spec/alsa_backup/writer_spec.rb", "spec/fixtures/config_test.rb", "spec/sndfile/info_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.homepage = %q{http://projects.tryphon.eu/alsa-backup}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{alsa-backup}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{ALSA client to perform continuous recording}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, [">= 0.3.5"])
      s.add_runtime_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_runtime_dependency(%q<daemons>, [">= 1.0.10"])
      s.add_development_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.2"])
    else
      s.add_dependency(%q<ffi>, [">= 0.3.5"])
      s.add_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_dependency(%q<daemons>, [">= 1.0.10"])
      s.add_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_dependency(%q<hoe>, [">= 2.6.2"])
    end
  else
    s.add_dependency(%q<ffi>, [">= 0.3.5"])
    s.add_dependency(%q<newgem>, [">= 1.5.3"])
    s.add_dependency(%q<daemons>, [">= 1.0.10"])
    s.add_dependency(%q<newgem>, [">= 1.5.3"])
    s.add_dependency(%q<hoe>, [">= 2.6.2"])
  end
end
