class AnotherDummyOutput
  class << self
    attr_accessor :count
  end
end

namespace :another_dummy do
  task do_something_once: :environment do
    AnotherDummyOutput.count ||= 0
    AnotherDummyOutput.count += 1
    puts "Count: #{AnotherDummyOutput.count}"
  end
end
