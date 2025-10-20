# frozen_string_literal: true

require 'mkmf'
require 'rb_sys/mkmf'

def rust? = system('cargo --version > /dev/null 2>&1')
def jruby? = RUBY_ENGINE == 'jruby'

if jruby?
  puts 'Skipping native extension on JRuby'
  puts 'digest-sip_hash will use pure Ruby implementation'
  File.write('Makefile', "all:\n\t@echo 'Skipping'\ninstall:\n\t@echo 'Skipping'\n")
  exit 0
end

unless rust?
  warn 'WARNING: Cargo not found!'
  warn 'digest-sip_hash will fall back to pure Ruby implementation'
  File.write('Makefile', "all:\n\t@echo 'Skipping'\ninstall:\n\t@echo 'Skipping'\n")
  exit 0
end

create_rust_makefile('digest_sip_hash_native/digest_sip_hash_native') do |r|
  r.ext_dir = 'ffi'
  r.profile = ENV.fetch('RB_SYS_CARGO_PROFILE', :release).to_sym
end
