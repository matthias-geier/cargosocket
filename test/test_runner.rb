gem 'minitest'
require 'minitest/autorun'
require 'cargosocket/test_helper'

path = File.dirname(__FILE__)
Dir["#{path}/*spec*.rb"].each{ |f| load f }
