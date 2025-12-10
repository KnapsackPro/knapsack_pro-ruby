require 'securerandom'

COMMANDS = {
  './bin/knapsack_pro_a_few_commands' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],

  # RSpec
  './bin/knapsack_pro_rspec' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_rspec_user_seat' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_rspec_cache_read_attempt' => ['0 2', '1 2'],
  './bin/knapsack_pro_rspec_junit' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_rspec_only_partial_nodes' => ['0 3 BUILD_ID', '1 3 BUILD_ID'],
  './bin/knapsack_pro_rspec_encrypted' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_rspec_disabled' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_rspec_fallback_mode' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_rspec_test_dir' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_rspec_test_file_exclude_pattern' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_rspec_split_by_test_examples' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_test_file_list' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_test_file_list_source_file' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_user_seat' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_record_first_run' => ['0 2', '1 2'],
  './bin/knapsack_pro_queue_rspec_record_first_run_junit' => ['0 2 COMMIT_HASH BUILD_ID', '1 2 COMMIT_HASH BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_above_threshold' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_measure_individual_examples' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_spec_opts' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_test_example_detector_prefix' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_split_by_test_examples_unique_build' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_tags' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_default_formatter' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_profile_formatter' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_junit' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_junit_with_rspec_custom_options' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_log_dir' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_json' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_test_dir' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_test_file_exclude_pattern' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_frequently_changing_test_files' => [''],
  './bin/knapsack_pro_queue_rspec_initialized_once' => ['0 2', '1 2'],
  './bin/knapsack_pro_queue_rspec_only_failures' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_order_defined' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_order_rand' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_order_rand_with_custom_seed' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_order_random' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_order_random_defined_in_config' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_fixed_queue_rspec_queue_consumed_at_least_once_with_ci_build_id' => [''],
  './bin/knapsack_pro_fixed_queue_split_rspec' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_fixed_queue_split_rspec_custom_branch_commit' => ['0 2 branch-name BUILD_ID', '1 2 branch-name BUILD_ID'],
  './bin/knapsack_pro_queue_rspec_encrypted' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_fixed_queue_split_rspec_encrypted' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/parallel_tests_knapsack_pro_queue_rspec' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/parallel_tests_knapsack_pro_queue_rspec_handle_signals' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/parallel_tests_knapsack_pro_single_machine_run BUILD_ID' => [''],
  './bin/bin_knapsack_pro_rspec' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/bin_knapsack_pro_queue_rspec' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_turnip' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],

  # inside of this bash scripts we run 2 parallel nodes
  './bin/knapsack_pro_split_by_test_cases_rspec' => [''],
  './bin/knapsack_pro_split_by_test_cases_queue_rspec' => [''],

  # Cucumber
  './bin/knapsack_pro_cucumber' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_cucumber_junit' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_cucumber' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_cucumber_junit' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_cucumber_prefix' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],

  # Minitest
  './bin/knapsack_pro_minitest' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_queue_minitest' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
  './bin/knapsack_pro_fixed_queue_split_minitest_custom_branch_commit' => ['0 2 branch-name BUILD_ID', '1 2 branch-name BUILD_ID'],
  './bin/bin_knapsack_pro_queue_minitest' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],

  # Test::Unit
  './bin/knapsack_pro_test_unit' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],

  # Spinach
  './bin/knapsack_pro_spinach' => ['0 2 BUILD_ID', '1 2 BUILD_ID'],
}

failed_commands = []
commands_count = COMMANDS.keys.size

COMMANDS.each_with_index do |(command, args), command_index|
  uuid = SecureRandom.uuid
  commit_hash = SecureRandom.hex

  args
    .map { _1.sub('BUILD_ID', uuid) }
    .map { _1.sub('COMMIT_HASH', commit_hash) }
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
