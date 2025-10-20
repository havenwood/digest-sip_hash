# frozen_string_literal: true

lib = File.expand_path '../lib', __dir__
$LOAD_PATH.prepend lib unless $LOAD_PATH.include? lib

require 'benchmark/ips'
require 'digest/sip_hash'
