# frozen_string_literal: true

lib = File.expand_path '../../lib', __FILE__
$LOAD_PATH.prepend lib unless $LOAD_PATH.include? lib

unless String.public_method_defined? :unpack1
  class String
    def unpack1 s
      unpack(s).first
    end
  end
end

require 'benchmark/ips'
require 'digest/sip_hash'
