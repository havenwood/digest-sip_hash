# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.prepend(lib) unless $LOAD_PATH.include?(lib)
require 'digest/sip_hash/version'

Gem::Specification.new do |spec|
  spec.name          = 'digest-sip_hash'
  spec.version       = Digest::SipHash::VERSION
  spec.authors       = ['Shannon Skipper']
  spec.email         = %w[shannonskipper@gmail.com]
  spec.description   = 'SipHash 1-3, 2-4, and other rounds implemented in Ruby with an optional Rust native extension.'
  spec.summary       = 'SipHash with an optional Rust native extension.'
  spec.homepage      = 'https://github.com/havenwood/digest-sip_hash'
  spec.licenses      = %w[MIT]
  spec.required_ruby_version = '>= 3.0'
  spec.files         = %w[Gemfile LICENSE Rakefile README.md] +
                       Dir['{lib,spec}/**/*.rb', 'bin/*'] +
                       Dir['ext/**/*.{rb,rs,toml}'].select { |file| File.exist?(file) }
  spec.require_paths = %w[lib]
  spec.executables   = %w[siphash]
  spec.extensions = ['ext/digest_sip_hash_native/extconf.rb'] unless RUBY_ENGINE == 'jruby'
  spec.add_dependency 'rb_sys', '~> 0.9'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
