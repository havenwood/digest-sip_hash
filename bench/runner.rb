# frozen_string_literal: true

require_relative 'helper'

MESSAGES = {
  'short' => 'x' * 8,
  'large' => 'x' * 4096
}.freeze

puts "SipHash-1-3 Performance (#{Digest::SipHash.native? ? 'Rust native' : 'Pure Ruby'})"
puts '=' * 70
puts

Benchmark.ips do |bench|
  MESSAGES.each do |name, message|
    bench.report("  #{name.capitalize} (#{message.bytesize} bytes)") do
      Digest::SipHash13.hexdigest(message)
    end
  end
  bench.compare!
end
