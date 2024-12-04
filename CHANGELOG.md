## [3.0.0] - 2024-12-04

- Predicate methods now cast the value to a boolean
  ```ruby
  Global.foo.enabled # => "0"
  Global.foo.enabled? # => false
  ```
- Dropped Ruby 2.7 support
