require 'utilities'
require 'fileutils'

module Enhance
  %w( Enhancer ).each do |class_name|
    autoload class_name.to_sym, File.join(File.dirname(__FILE__), "enhance/#{class_name.downcase}")
  end
  
end