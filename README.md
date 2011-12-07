Enhance!
========

> "Enhance!" - Horatio Caine, CSI

Enhance! is a Rack middleware that resizes your images on-the-fly using ImageMagick.


Rails
-----

In your application.rb file

    config.middleware.use "Enhance::Enhancer", Rails.root, :routes => [:attachments, :images]
    

Config Options
--------------

    Enhance::Enhancer.new next_in_chain, root, options
    
* next_in_chain: Next Rack Application to use
* root: Where the paths are constructed from
* options: described next

Options
-------

* extensions: list of supported extensions | [jpg, png, jpeg, gif]
* routes: list of matched routes | images
* quality: quality of output images | 100
* folders: list of folders to look in | ["public"]
* command_path: path for imagemagick if not in PATH | Paperclip config if available
* cache: folder in which to cache enhanced images | "#{root}/tmp/enhanced"
* max_side: maximum size of the enhanced image | 1024
* file_root: root of the server if not the same as root | root

