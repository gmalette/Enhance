
class Enhance::Enhancer
  
  Geometry =  /^(?<geometry>(?<width>\d+)?x?(?<height>\d+)?([\>\<\@\%^!])?)(?<filter>sample)?$/
  
  def initialize app, root, options = {}
    @app = app
    @extensions = options[:extensions] || %w( jpg png jpeg gif )
    @routes = options[:routes] || %w( images )
    @folders = options[:folders] || [File.join(root, "public")]
    @quality = options[:quality] || 100
    @command_path = options[:convert_path] || "#{Paperclip.options[:command_path] if defined?(Paperclip)}"
    @command_path += "/" unless @command_path.blank?
    @cache = options[:cache] || File.join(root, "tmp")
    @max_side = options[:max_side] || 1024
    @file_root = (options[:file_root] || root).to_s
    @server = Rack::File.new(@file_root)
  end
  
  def call env
    matches = env['PATH_INFO'].match /(?<filename>(#{@routes.join("|")}).*(#{@extensions.join("|")}))\/(?<geometry>.*)/i
    if matches && !matches['filename'].include?("..")
      dup._call env, matches
    else
      @app.call env
    end
  end
  
  def _call env, matches
    request = @folders.collect_first do |f| 
      f = File.join(f, matches['filename'])
      File.exists?(f) ? f : nil
    end
    
    if request && (filename = convert(request, matches['filename'], CGI.unescape(matches['geometry']))) && filename.gsub!(@file_root, '')
      env["PATH_INFO"] = filename
      @server.call env
    else
      @app.call env
    end
  end
  
  # Finds the image and resizes it if needs be
  def convert path, filename, geometry
    # Extract the width and height
    if sizes = geometry.match(Geometry)
      w, h = sizes['width'], sizes['height']
      ow, oh = original_size path
      
      # Resize if needed
      if (w.nil? || w.to_i <= @max_side) && (h.nil? || h.to_i <= @max_side) && (ow != w || oh != h)
        new_name = File.join(@cache, filename, geometry) + File.extname(filename)
        resize path, new_name, geometry
      else
        path
      end
    else
      nil
    end
  end
  
  # Creates the path and resizes the images
  def resize source, destination, geometry  
    FileUtils.mkdir_p File.dirname(destination)
    
    match = geometry.match Geometry
    
    method = match['filter'] || 'resize'
    
    unless File.exists?(destination) && File.mtime(destination) > File.mtime(source)
      command = "#{@command_path}convert \"#{source}\" -#{method} \"#{match['geometry']}\" -quality #{@quality} \"#{destination}\""
      puts command
      `#{command}`
    end
    
    destination
  end
  
  # Finds the size of the original image
  def original_size filename
    `#{@command_path}identify -format '%w %h' #{filename}`.split(/\s/)
  end

end