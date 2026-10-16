require 'securerandom'

COMMANDS = {
  # RSpec
  './bin/knapsack_pro_queue_rspec' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_encrypted' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_log_dir' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_above_threshold' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_measure_individual_examples' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_spec_opts' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_test_example_detector_prefix' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_test_dir' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_test_file_exclude_pattern' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_test_file_list' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_rspec_test_file_list_source_file' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_turnip' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_rspec' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_rspec_encrypted' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_rspec_fallback_mode' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_rspec_junit' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_rspec_test_dir' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_rspec_test_file_exclude_pattern' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],

  # Cucumber
  './bin/knapsack_pro_cucumber' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_cucumber_junit' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_cucumber' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_cucumber_junit' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_cucumber_prefix' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],

  # Minitest
  './bin/knapsack_pro_minitest' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
  './bin/knapsack_pro_queue_minitest' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],

  # Test::Unit
  './bin/knapsack_pro_test_unit' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],

  # Spinach
  './bin/knapsack_pro_spinach' => ['0 2 TEST_QUEUE_ID', '1 2 TEST_QUEUE_ID'],
}

failed_commands = []
commands_count = COMMANDS.keys.size

COMMANDS.each_with_index do |(command, args), command_index|
  uuid = SecureRandom.uuid

  args
    .map { _1.sub('TEST_QUEUE_ID', uuid) }
    .each do |arg|
      cmd = [command, arg].join(' ')
      puts "="*50
      puts "EXECUTING (#{command_index+1} of #{commands_count}): #{cmd}"
      puts
      system(cmd)

      (failed_commands << command) if $?.exitstatus != 0
  end
end

puts
puts '=' * 20
puts
if failed_commands.empty?
  puts 'All tests pass with success!'
else
  puts 'Something failed! You can retry those commands:'
  puts failed_commands
end
