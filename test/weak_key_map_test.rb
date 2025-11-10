# frozen_string_literal: false

require_relative "./test_helper"
require "weak_key_map"

class WeakKeyMapTest < Minitest::Test
  def setup
    @wm = ObjectSpace::WeakKeyMap.new
  end

  def test_map
    x = Object.new
    k = "foo"
    @wm[k] = x
    assert_same(x, @wm[k])
    assert_same(x, @wm["FOO".downcase])
  end

  def test_aset_const
    x = Object.new
    assert_raises(ArgumentError) { @wm[true] = x }
    assert_raises(ArgumentError) { @wm[false] = x }
    assert_raises(ArgumentError) { @wm[nil] = x }
    assert_raises(ArgumentError) { @wm[42] = x }
    assert_raises(ArgumentError) { @wm[2**128] = x }
    assert_raises(ArgumentError) { @wm[1.23] = x }
    assert_raises(ArgumentError) { @wm[:foo] = x }
    assert_raises(ArgumentError) { @wm["foo#{rand}".to_sym] = x }
  end

  def test_getkey
    k = "foo"
    @wm[k] = true
    assert_same(k, @wm.getkey("FOO".downcase))
  end

  def test_key?
    assert_weak_include(:key?, "foo")
    assert !@wm.key?("bar")
  end

  def test_delete
    k1 = "foo"
    x1 = Object.new
    @wm[k1] = x1
    assert_equal x1, @wm[k1]
    assert_equal x1, @wm.delete(k1)
    assert_nil @wm[k1]
    assert_nil @wm.delete(k1)

    fallback = @wm.delete(k1) do |key|
      assert_equal k1, key
      42
    end
    assert_equal 42, fallback
  end

  def test_clear
    k = "foo"
    @wm[k] = true
    assert @wm[k]
    assert_same @wm, @wm.clear
    refute @wm[k]
  end

  def test_inspect
    x = Object.new
    k = Object.new
    @wm[k] = x
    assert_match(/\A\#<#{@wm.class.name}:[\dxa-f]+ size=\d+>\z/, @wm.inspect)

    1000.times do |i|
      @wm[i.to_s] = Object.new
      @wm.inspect
    end
    assert_match(/\A\#<#{@wm.class.name}:[\dxa-f]+ size=\d+>\z/, @wm.inspect)
  end

  def test_no_hash_method
    k = BasicObject.new
    assert_raises NoMethodError do
      @wm[k] = 42
    end
  end

  def test_frozen_object
    o = Object.new.freeze
    @wm[o] = 'foo' # no error raised
    @wm['foo'] = o  # no error raised
  end

  private

  def assert_normal_exit(code, message = nil)
    require "tempfile"

    Tempfile.create(["weak_key_map_test", ".rb"]) do |f|
      f.write(code)
      f.flush

      lib_path = File.expand_path("../lib", __dir__)
      output = `ruby -I#{lib_path} #{f.path} 2>&1`
      status = $?

      assert status.success?,
        "Expected script to exit normally but got exit code #{status.exitstatus}.\n" +
        "Output:\n#{output}" +
        (message ? "\n#{message}" : "")
    end
  end

  def assert_weak_include(m, k, n = 100)
    if n > 0
      return assert_weak_include(m, k, n - 1)
    end
    1.times do
      x = Object.new
      @wm[k] = x
      assert @wm.send(m, k)
      assert @wm.send(m, "FOO".downcase)
      x = Object.new
    end
  end
end
