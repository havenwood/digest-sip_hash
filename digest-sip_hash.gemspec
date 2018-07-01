# frozen_string_literal: true

lib = File.expand_path '../lib', __FILE__
$LOAD_PATH.prepend lib unless $LOAD_PATH.include? lib
require 'digest/sip_hash/version'

Gem::Specification.new do |spec|
  spec.name          = 'digest-sip_hash'
  spec.version       = Digest::SipHash::VERSION
  spec.authors       = ['Shannon Skipper']
  spec.email         = %w[shannonskipper@gmail.com]
  spec.description   = 'An implementation of SipHash 1-3, 2-4, etc. in pure Ruby.'
  spec.summary       = 'Pure Ruby SipHash 1-3 and 2-4.'
  spec.homepage      = 'https://github.com/havenwood/digest-sip_hash'
  spec.licenses      = %w[MIT]
  spec.files         = %w[Gemfile LICENSE Rakefile README.md] + Dir['{lib,spec}/**/*.rb', 'bin/*']
  spec.require_paths = %w[lib]
  spec.executables   = %w[siphash]

  spec.add_development_dependency 'rake', '~> 12'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'minitest-proveit', '~> 1'
  spec.add_development_dependency 'benchmark-ips', '~> 2'
end
