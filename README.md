Enhance!
========

> "Enhance!" - Horatio Caine, CSI

[Watch this, it's awesome](http://www.youtube.com/watch?v=Vxq9yj2pVWk)

Enhance! is a Rack middleware that resizes your images on-the-fly using ImageMagick.

    gem install enhance

Rails
-----

In your Gemfile

    gem 'enhance', '~> 0.1.0'

In your application.rb file

    config.middleware.use "Enhance::Enhancer" do |config|
      config.match "images", "app/assets/images"
      config.match "attachments", "app/public/attachments"
      config.quality = 80
    end
    
In your views:

    image_tag enhance!("/images/toto.jpg", "200x200")

Usage
-----

Enhance! will match URIs based on the config parameters. To the normal image URI, you will need to add the format. The format looks like ImageMagick's parameters.

Here are a few examples:

* 200 or 200x, x200 or 200x200: resizes the image up to 200 pixels wide or high, keeping proportions and never upscaling the image
* adding "<", ex: 200<: allows upscaling the image
* 200x200!: disables proportions and resizes the image
* adding "sample", ex: 200x200sample: resizes the image using nearest-neighbor filter

Example of matched URI:

    http://my_application.com/images/toto.jpg/200x200sample


Config Options
--------------

    Enhance::Enhancer.new next_in_chain do |config|
      # ...
    end
    
* next_in_chain: Next Rack Application to use

Config methods
-------

* match(route, path): Match the route and look in path for the images | "", "./"
* extensions=: list of supported extensions | [jpg, png, jpeg, gif]
* quality=: quality of output images | 100
* command_path=: path for imagemagick if not in PATH | Paperclip config if available
* cache=: folder in which to cache enhanced images | "./tmp/enhanced"
* max_side=: maximum size of the enhanced image | 1024
