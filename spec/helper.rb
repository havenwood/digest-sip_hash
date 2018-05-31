# frozen_string_literal: true

lib = File.expand_path '../../lib', __FILE__
$LOAD_PATH.prepend lib unless $LOAD_PATH.include? lib

require 'digest/sip_hash'
require 'minitest/autorun'
require 'minitest/pride'
