class DummyOutput
  class << self
    attr_accessor :count
  end
end

namespace :dummy do
  task do_something_once: :environment do
    DummyOutput.count ||= 0
    DummyOutput.count += 1
    puts "Count: #{DummyOutput.count}"
  end
end
