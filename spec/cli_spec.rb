# frozen_string_literal: true

require_relative 'helper'
require 'open3'
require 'tempfile'

describe 'bin/siphash CLI' do
  let(:cli_path) { File.expand_path('../bin/siphash', __dir__) }

  def run_cli(*, stdin: nil)
    lib_path = File.expand_path('../lib', __dir__)
    env = {'RUBYLIB' => lib_path}
    out, err, status = Open3.capture3(env, *, stdin_data: stdin, chdir: File.dirname(__dir__))
    [out, err, status]
  end

  it 'hashes stdin with defaults' do
    out, err, status = run_cli(cli_path, stdin: 'test')
    assert_equal true, status.success?
    assert_equal '', err
    hash, path = out.strip.split
    assert_equal 'e0969da9b8fb378d', hash
    assert_equal '-', path
  end

  it 'hashes a file' do
    Tempfile.create(['test', '.txt']) do |file|
      file.write('siphash')
      file.flush

      out, err, status = run_cli(cli_path, file.path)
      assert_equal true, status.success?
      assert_equal '', err
      hash, path = out.strip.split
      assert_equal '8264ceeccb16bcbe', hash
      assert_equal file.path, path
    end
  end

  it 'accepts custom c rounds' do
    out, _err, status = run_cli(cli_path, '-c', '2', stdin: 'test')
    assert_equal true, status.success?
    hash = out.strip.split.first
    assert_equal '48444f3a39c6b029', hash
  end

  it 'accepts custom d rounds' do
    out, _err, status = run_cli(cli_path, '-d', '4', stdin: 'test')
    assert_equal true, status.success?
    hash = out.strip.split.first
    assert_equal '669f789fa9b11cab', hash
  end

  it 'accepts custom key' do
    key = '000102030405060708090a0b0c0d0e0f'
    out, _err, status = run_cli(cli_path, '--key', key, stdin: 'test')
    assert_equal true, status.success?
    hash = out.strip.split.first
    assert_equal '19a863ed6bb62af7', hash
  end

  it 'accepts all options together' do
    key = '000102030405060708090a0b0c0d0e0f'
    out, _err, status = run_cli(cli_path, '-c', '2', '-d', '4', '--key', key, stdin: 'test')
    assert_equal true, status.success?
    hash = out.strip.split.first
    assert_equal '26765e525c56729a', hash
  end

  it 'shows version' do
    out, _err, status = run_cli(cli_path, '--version')
    assert_equal true, status.success?
    assert_match(/\d+\.\d+\.\d+/, out)
  end

  it 'shows help' do
    out, _err, status = run_cli(cli_path, '--help')
    assert_equal true, status.success?
    assert_match(/Usage:/, out)
    assert_match(/-c/, out)
    assert_match(/-d/, out)
    assert_match(/--key/, out)
  end

  it 'rejects invalid key length' do
    _out, err, status = run_cli(cli_path, '--key=0011', stdin: 'test')
    assert_equal false, status.success?
    assert_match(/invalid argument/, err)
  end

  it 'rejects invalid c rounds' do
    _out, err, status = run_cli(cli_path, '-c', 'abc', stdin: 'test')
    assert_equal false, status.success?
    assert_match(/invalid argument/, err)
  end

  it 'rejects invalid d rounds' do
    _out, err, status = run_cli(cli_path, '-d', '-1', stdin: 'test')
    assert_equal false, status.success?
    assert_match(/invalid argument/, err)
  end

  it 'handles empty input' do
    out, _err, status = run_cli(cli_path, stdin: '')
    assert_equal true, status.success?
    hash = out.strip.split.first
    assert_equal 'd1fba762150c532c', hash
  end

  it 'handles binary data' do
    binary_data = (0..255).map(&:chr).join
    out, _err, status = run_cli(cli_path, stdin: binary_data)
    assert_equal true, status.success?
    hash = out.strip.split.first
    assert_equal '31ae646afba70308', hash
  end
end
