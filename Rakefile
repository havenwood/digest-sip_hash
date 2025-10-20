# frozen_string_literal: true

require 'fileutils'

task default: :test

desc 'Compile native extension'
task :compile do
  Dir.chdir('ext/digest_sip_hash_native') do
    ruby 'extconf.rb'
    sh 'make'

    FileUtils.mkdir_p '../../lib/digest/sip_hash'
    ext = RUBY_PLATFORM.include?('darwin') ? 'bundle' : 'so'
    FileUtils.cp "digest_sip_hash_native.#{ext}",
                 "../../lib/digest/sip_hash/digest_sip_hash_native.#{ext}"
  end
end

desc 'Run all tests (library & CLI) without native extension'
task :test do
  ruby 'spec/lib_spec.rb'
  ruby 'spec/cli_spec.rb'
end

desc 'Run all tests with native extension'
task test_native: :compile do
  ruby 'spec/lib_spec.rb'
  ruby 'spec/cli_spec.rb'
  ruby 'spec/native_spec.rb'
end

desc 'Run performance benchmarks'
task :bench do
  ruby 'bench/runner.rb'
end

desc 'Compare Ruby vs Rust performance'
task :compare do
  ruby 'bench/comparison_bench.rb'
end
