# frozen_string_literal: true

require 'mkmf'
require 'rb_sys/mkmf'

if ENV['DIGEST_SIPHASH_DISABLE_NATIVE']
  warn 'DIGEST_SIPHASH_DISABLE_NATIVE is set'
  warn 'Skipping native extension, using pure Ruby implementation'
  File.write('Makefile', "all:\n\t@echo 'Skipping'\ninstall:\n\t@echo 'Skipping'\n")
  exit
end

unless system('cargo --version > /dev/null 2>&1')
  warn 'WARNING: Cargo not found!'
  warn 'digest-sip_hash will fall back to pure Ruby implementation'
  File.write('Makefile', "all:\n\t@echo 'Skipping'\ninstall:\n\t@echo 'Skipping'\n")
  exit
end

create_rust_makefile('digest_sip_hash_native/digest_sip_hash_native') do |r|
  r.ext_dir = 'ffi'
  r.profile = ENV.fetch('RB_SYS_CARGO_PROFILE', :release).to_sym
end
