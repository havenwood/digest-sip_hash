# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.prepend(lib) unless $LOAD_PATH.include?(lib)

require 'digest/sip_hash'
require 'minitest/autorun'
require 'minitest/hell'
require 'minitest/pride'

# In tests, verify native extension actually works if loaded
if Digest::SipHash.native?
  # Smoke test to ensure FFI is working correctly
  result = Digest::SipHash13.hexdigest('test')
  expected = 'e0969da9b8fb378d'

  abort "Native extension loaded but produced wrong result: #{result} != #{expected}" unless result == expected
end
