class Enhance::Enhancer
  
  Geometry =  /^(?<geometry>(?<width>\d+)?x?(?<height>\d+)?([\>\<\@\%^!])?)(?<filter>sample)?$/
  
  def initialize app = nil
    @app = app
    @config = Enhance::Config.new
    yield @config if block_given?
  end
  
  def call env
    matches = path_info(env).match regex
    if matches && !matches['filename'].include?("..")
      dup._call env, matches
    else
      _next env
    end
  end
  
  def _call env, matches
    folder = @config.routes[matches[:folder]] || Dir.pwd
    
    request   = File.join(folder, matches['filename'])
    destname  = File.join(*[matches['folder'], matches['filename']].select(&:present?).compact)
    
    if request && File.exists?(request) && (filename = convert(request, destname, CGI.unescape(matches['geometry'])))
      filename.gsub!(@config.cache, '')
      env["PATH_INFO"] = filename
      @config.server.call env
    else
      _next env
    end
  end
  
  def _next(env)
    if @app
      @app.call env
    else
      content = "Not Found"
      [404, {'Content-Type' => 'text/html', 'Content-Length' => content.length.to_s}, [content]]
    end
  end
  
  def path_info(env)
    # Matches for Rails using no config
    if @config.routes.empty? && (info = env["action_dispatch.request.path_parameters"])
      [info[:path], info[:format]].compact.join(".")
    else
      env['PATH_INFO']
    end
  end
  
  def regex
    folders = @config.routes.keys
    /^\/?(?<folder>#{folders.join('|')})\/?(?<filename>.*\.(#{@config.extensions.join('|')}))\/(?<geometry>.*)/i
  end
  
  # Finds the image and resizes it if needs be
  def convert path, filename, geometry
    # Extract the width and height
    if sizes = geometry.match(Geometry)
      w, h = sizes['width'], sizes['height']
      ow, oh = original_size path
      
      # Resize if needed
      if (w.nil? || w.to_i <= @config.max_side) && (h.nil? || h.to_i <= @config.max_side) && (ow != w || oh != h)
        new_name = File.join(@config.cache, filename, geometry) + File.extname(filename)
        resize path, new_name, geometry
      end
    end
  end
  
  # Creates the path and resizes the images
  def resize source, destination, geometry
    FileUtils.mkdir_p File.dirname(destination)
    
    match = geometry.match Geometry

    method = match['filter'] || 'resize'
    unless File.exists?(destination) && File.mtime(destination) > File.mtime(source)
      command = "#{@config.command_path}convert \"#{source}\" -#{method} \"#{match['geometry']}\" -quality #{@config.quality} \"#{destination}\""
      puts command
      `#{command}`
    end
    destination
  end
  
  # Finds the size of the original image
  def original_size filename
    `#{@config.command_path}identify -format '%w %h' #{filename}`.split(/\s/)
  end

end