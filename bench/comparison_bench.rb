# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.prepend(lib) unless $LOAD_PATH.include?(lib)

require 'digest/sip_hash'
require 'benchmark/ips'

abort 'Native extension not available. Comparison requires Rust extension.' unless Digest::SipHash.native?

# Bypass native extension to access pure Ruby implementation
module RubyImpl
  def self.hexdigest(message)
    sip = Digest::SipHash::Sip.new(message, 1, 3, Digest::SipHash::DEFAULT_KEY)
    sip.transform
    sip.finalize.unpack1('H*')
  end
end

MESSAGES = {
  'short' => 'x' * 8,
  'large' => 'x' * 4096
}.freeze

puts 'Ruby vs Rust SipHash-1-3 Comparison'
puts '=' * 70
puts "Ruby #{RUBY_VERSION} on #{RUBY_PLATFORM}"
puts '=' * 70
puts

Benchmark.ips do |bench|
  MESSAGES.each do |name, message|
    bench.report("  Ruby #{name} (#{message.bytesize} bytes)") { RubyImpl.hexdigest(message) }
    bench.report("  Rust #{name} (#{message.bytesize} bytes)") { Digest::SipHash13.hexdigest(message) }
  end
  bench.compare!
end
