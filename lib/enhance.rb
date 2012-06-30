require 'utilities'
require 'fileutils'
require 'cgi'

module Enhance; end

%w( urlhelper enhancer config ).each do |file|
  require File.join(File.dirname(__FILE__), "enhance/#{file}")
end