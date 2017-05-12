require 'time'

class Time
  class << self
    # The alias method .now_without_mock is different than in Timecop gem (timecop uses .now_without_mock_time)
    # to ensure there will be no conflict
    alias_method :now_without_mock, :now
  end
end
