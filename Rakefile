# frozen_string_literal: true

task default: :test

desc 'Run all tests (library & CLI)'
task :test do
  ruby 'spec/lib_spec.rb'
  ruby 'spec/cli_spec.rb'
end

desc 'Run performance benchmarks'
task :bench do
  ruby 'bench/runner.rb'
end

desc 'Compare Ruby vs Rust performance'
task :compare do
  ruby 'bench/comparison_bench.rb'
end
