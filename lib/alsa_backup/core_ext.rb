class Time

  def floor(attribute, modulo)
    actual = self.send(attribute)
    self.change(attribute => actual - actual%modulo)
  end

  # FIXME cloned by waiting correct require 'active_support/..' for active_support > 3
  def change(options)
    ::Time.send(
                self.utc? ? :utc : :local, 
                options[:year]  || self.year, 
                options[:month] || self.month, 
                options[:mday]  || self.mday, 
                options[:hour]  || self.hour, 
                options[:min]   || (options[:hour] ? 0 : self.min),
                options[:sec]   || ((options[:hour] || options[:min]) ? 0 : self.sec),
                options[:usec]  || ((options[:hour] || options[:min] || options[:sec]) ? 0 : self.usec)
                )
  end
  
end

class File

  def self.suffix_basename(file, suffix)
    dirname = File.dirname(file)
    
    dirname = 
      case dirname
      when "/": "/"
      when ".": ""
      else
        dirname + "/"
      end

    extension = File.extname(file)
    dirname +
      File.basename(file, extension) +
      suffix +
      extension
  end

  def self.write(file, content)
    File.open(file, "w") { |f| f.puts content }
  end

end
