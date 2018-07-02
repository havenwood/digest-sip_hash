# frozen_string_literal: true

lib = File.expand_path '../lib', __dir__
$LOAD_PATH.prepend lib unless $LOAD_PATH.include? lib

require 'digest/sip_hash'
require 'minitest/autorun'
require 'minitest/hell'
require 'minitest/pride'

class Minitest::Test
  prove_it!
end
