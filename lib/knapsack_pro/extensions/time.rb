require 'time'

class Time
  class << self
    alias_method :now_without_mock, :now
  end
end
