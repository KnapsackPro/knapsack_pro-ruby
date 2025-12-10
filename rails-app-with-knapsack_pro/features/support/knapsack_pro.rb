require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE
KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  print '-'*10
  print 'Before Queue Hook - run before the test suite'
  print '-'*10
end

KnapsackPro::Hooks::Queue.before_subset_queue do |queue_id, subset_queue_id|
  print '-'*10
  print 'Before Subset Queue Hook - run before the next subset of tests'
  print '-'*10
end

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  print '-'*10
  print 'After Subset Queue Hook - run after the previous subset of tests'
  print '-'*10
end

KnapsackPro::Hooks::Queue.after_queue do |queue_id|
  print '-'*10
  print 'After Queue Hook - run after the test suite'
  print '-'*10
end

KnapsackPro::Adapters::CucumberAdapter.bind
