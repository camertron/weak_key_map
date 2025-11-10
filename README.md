## weak_key_map

![Unit Tests](https://github.com/camertron/weak_key_map/actions/workflows/tests.yml/badge.svg?branch=main)

A backport of `ObjectSpace::WeakKeyMap` for Ruby < 3.3

## Introduction

Ruby 3.3 introduced the handy `ObjectSpace::WeakKeyMap` class to complement `ObjectSpace::WeakMap`. The `WeakMap` class holds weak references to both keys _and_ values, meaning if the value for a particular key is garbage collected, the entire key/value pair will be removed from the map. In contrast, the `WeakKeyMap` class only removes values if the _key_ is garbage collected.

This gem is a backport of `WeakKeyMap` for older rubies in the 3.x line.

## Usage

`WeakKeyMap`s work in a very similar fashion to a normal Ruby hash, eg:

```ruby
map = ObjectSpace::WeakKeyMap.new
key = "key"
map[key] = "value"
map["key"]  # => "value"
key = nil
GC.start
map["key"]  # => nil
```

## Running Tests

`bundle exec rake` should do the trick.

## License

Licensed under the MIT license. See LICENSE for details.

## Authors

* Cameron C. Dutro: http://github.com/camertron
