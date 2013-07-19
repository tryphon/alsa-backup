namespace :package do
  desc "Build debian source packages"
  task :source do
    mkdir_p "build"
    DebianPackage.new.tap do |package|
      package.build_source
    end
  end

  desc "Build debian lenny/squeeze packages"
  task :binary => :source do
    DebianPackage.new.tap do |package|
      package.build :lenny, :i386
      package.build :squeeze, :i386
    end
  end

  class DebianPackage

    def attributes
      @attributes ||= Hash[`dpkg-parsechangelog --count 1`.scan(/^([^:]+): (.*)$/)]
    end

    def export_source(target)
      tar_file = "build/export.tar"
      sh "git-archive-all #{tar_file}"
      sh "tar -xf #{tar_file} -C #{target}"
      sh "rsync -av debian/ #{target}/debian/"

      ENV['DEV_FILES'].split(' ').each do |file|
        sh "cp #{file} #{target}/#{file}"
      end if ENV['DEV_FILES']
    end

    def build_source
      source_directory = "build/source"

      FileUtils.mkdir_p source_directory
      export_source source_directory

      Dir.chdir(source_directory) do
        sh "dpkg-buildpackage -S"
      end
    end

    def changes_file
      @changes_file ||= "build/#{attributes['Source']}_#{attributes['Version']}_source.changes"
    end

    def source_files
      @@source_files ||=
        if IO.read(changes_file) =~ /^Files:/
          $'.scan(/^ [a-z0-9]+ .* ([^ \n]+)$/).collect do |file|
            File.expand_path(file.to_s, changes_file + "/..")
          end
        end
    end

    def dsc_file
      @dsc_file ||= source_files.find { |f| f.match /\.dsc$/ }
    end

    def build(distribution, arch)
      sh "sudo sh -c 'DIST=#{distribution} ARCH=#{arch} cowbuilder --build --distribution #{distribution} --basepath /var/cache/pbuilder/base-#{distribution}-#{arch}.cow #{dsc_file}'"
    end

  end
end
