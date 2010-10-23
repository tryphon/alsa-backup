log_dir = File.dirname(__FILE__) + '/../log/'
Dir.mkdir(log_dir) unless File.exists?(log_dir)

ALSA::logger = AlsaBackup.logger = 
  Logger.new(File.join(log_dir,'test.log'))
