#!/usr/local/env ruby
# $Id: $

require 'test/unit'
require 'fileutils'
require 'lhalib'

puts "start LhaLib(#{LhaLib::VERSION} test"
class TestLhaLib < Test::Unit::TestCase
  include LhaLib
  def setup
    FileUtils.rm_rf ['test.dat', 'testlib.c', 'testh.h', 'tmp']
  end

  def tearDown
  end

  def test_copy_only
    assert_equal(1, x('test.lzh'))
    assert(File.exist?('test.dat'))
    obuff = ' ' * 256
    (0..255).each do |x|
      obuff[x] = x
    end
    nbuff = nil
    File.open('test.dat', 'rb') do |f|
      nbuff = f.read
    end
    assert_equal(obuff, nbuff)
  end

  def test_x
    assert_equal(2, x('test2.lzh'))
    assert(File.exist?('testlib.c'))
    assert(File.exist?('testh.h'))
    check_file('testlib.c')
    check_file('testh.h')
  end

  def test_x_withdir
    assert_equal(4, x('tmpdir.lzh'))
    assert(File.exist?('tmp/testlib.c'))
    assert(File.exist?('tmp/testh.h'))
    check_file('testlib.c', 'tmp')
    check_file('testh.h', 'tmp')
  end

  def test_proc
    i = 0
    name = ['tmp/', 'tmp/test.dat', 'tmp/testh.h', 'tmp/testlib.c']
    size = [0, 256, 9310, 1997]
    # directory = S_IFDIR | 0755, file = S_IFREG + 0644
    perm = [040755, 0100644, 0100644, 0100644]
    cnt = x('tmpdir.lzh') do |info|
      assert_equal(name[i], info[:name])
      assert_equal(size[i], info[:original_size])
      assert_equal(perm[i], info[:permission])
      i += 1
    end
    # normal extract process was done ?
    assert_equal(4, cnt)
    assert_equal(4, i)
    assert(File.exist?('tmp/testlib.c'))
    assert(File.exist?('tmp/testh.h'))
    check_file('testlib.c', 'tmp')
    check_file('testh.h', 'tmp')
  end

  def test_badarchive
    assert_equal(0, x('test.rb'))
  end

  private
  def check_file(name, dir = nil)
    org = nil
    File.open("#{name}.org", 'rb') do |f|
      org = f.read
    end
    ex = nil
    File.open(dir ? "#{dir}/#{name}" : name, 'rb') do |f|
      ex = f.read
    end
    assert_equal(org, ex)
  end
end

