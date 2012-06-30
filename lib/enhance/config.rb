class Enhance::Config
  
  attr_reader :cache, :quality, :max_side, :command_path, :extensions, :routes, :server
  
  def initialize
    @routes       = {}
    @quality      = 100
    @max_side     = 1024
    @command_path = "#{Paperclip.options[:command_path] if defined?(Paperclip)}"
    @extensions   = %w( jpg png jpeg gif )
    
    self.cache    = File.join('tmp', 'enhance')
  end
  
  def match(route, path)
    @routes[route] = path
  end
  
  def cache=(path)
    FileUtils.mkdir_p(path)
    path = File.realpath(path)
    @cache = path
    @server = Rack::File.new(@cache)
  end
  
  def quality=(q)
    @quality = q
  end
  
  def max_side=(m)
    @max_side = m
  end
  
  def command_path=(path)
    @command_path = path
    @command_path += "/" unless @command_path.empty?
  end
  
  def extensions=(*extensions)
    @extensions = extensions
  end
end