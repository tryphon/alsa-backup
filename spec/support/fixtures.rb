def test_directory
  directory = File.dirname(__FILE__) + '/../../tmp'
  Dir.mkdir(directory) unless File.exists?(directory)
  directory
end

def test_file(name = 'test.wav')
  File.join(test_directory, name)
end

def fixture_file(name)
  File.dirname(__FILE__) + '/../fixtures/' + name
end
