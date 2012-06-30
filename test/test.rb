require 'rack/test'
require 'test/unit'

require File.expand_path('../../lib/enhance.rb', __FILE__)

class FourOhFourApp
  
  def call env
    [404, [], ["Not found"]]
  end
  
end

class EnhanceTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Enhance::Enhancer.new FourOhFourApp.new do |config|
    end
  end
  
  def test_404
    get "/images/unknown.jpeg"
    assert last_response.not_found?
  end
  
  def test_image_width_unconstrained
    get "/images/test.jpg/200x"
    assert_size 200, nil
  end
  
  def test_image_height_unconstrained
    get "/images/test.jpg/x200"
    assert_size nil, 200
  end
  
  def test_image_force_square
    get "/images/test.jpg/200x200!"
    assert_size 200, 200
  end
  
  def test_image_larger_than_nature
    get "/images/test.jpg/1000"
    assert_size 1000, nil
  end
  
  def test_image_larger_constrained
    get "/images/test.jpg/1000%3E" #1000<
    assert_size 800, nil
  end
  
  def test_image_oversize
    get "/images/test.jpg/2000"
    assert last_response.not_found?
  end
  
  def assert_size width, height, comparator = :==
    dump = File.join(File.dirname(__FILE__), "results", "dump.jpg")
    File.open(dump, "wb") do |f|
      f.write last_response.body
    end
    identify = `identify #{dump}`.match /\s(?<width>[0-9]+)x(?<height>[0-9]+)/
    assert identify[:width].to_i.send(comparator, width) if width
    assert identify[:height].to_i.send(comparator, height) if height
  end
  
end