# frozen_string_literal: true

require "weakref"

module ObjectSpace
  class WeakKeyMap
    def initialize
      @map = {}
      @refs = {}
    end

    def [](key)
      hash = key.hash
      ref = @refs[hash]
      return nil unless ref
      return @map[hash] if ref.weakref_alive?

      @map.delete(hash)
      @refs.delete(hash)

      nil
    end

    def []=(key, value)
      case key
      when true, false, nil, Integer, Float, Symbol
        raise ArgumentError, "WeakKeyMap keys must be garbage collectable"
      end

      hash = key.hash
      @refs[hash] = WeakRef.new(key)
      @map[hash] = value
    end

    def inspect
      "#<#{self.class}:0x#{(object_id << 1).to_s(16).rjust(14, '0')} size=#{@map.size}>"
    end

    def clear
      @map.clear
      @refs.clear
      self
    end

    def delete(key, &block)
      hash = key.hash
      retval = nil

      if @refs.key?(hash)
        retval = @map[hash]
      end

      if block_given?
        retval = yield key
      end

      @refs.delete(hash)
      @map.delete(hash)

      retval
    end

    def getkey(key)
      hash = key.hash

      if @refs.key?(hash)
        ref = @refs[hash]

        begin
          return ref.__getobj__
        rescue WeakRef::RefError
          @refs.delete(hash)
          @map.delete(hash)
        end
      end

      nil
    end

    def key?(key)
      hash = key.hash

      if @refs.key?(hash)
        ref = @refs[hash]
        return true if ref.weakref_alive?

        @refs.delete(hash)
        @map.delete(hash)
      end

      false
    end

    def size
      @refs.size
    end

    alias length size
  end
end
