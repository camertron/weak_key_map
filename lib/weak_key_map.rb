# frozen_string_literal: true

if !ObjectSpace.const_defined?(:WeakKeyMap, false)
  require_relative "weak_key_map/impl"
end
