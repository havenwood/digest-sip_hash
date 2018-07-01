# frozen_string_literal: true

require_relative 'helper'

Benchmark.ips do |x|
  x.report('SipHash13') { Digest::SipHash13.hexdigest 'chunky bacon' }
  x.report('SipHash24') { Digest::SipHash24.hexdigest 'chunky bacon' }
end
