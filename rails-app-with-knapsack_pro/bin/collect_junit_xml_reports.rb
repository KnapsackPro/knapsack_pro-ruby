# How to use it:
# ruby bin/collect_junit_xml_reports.rb > tmp/junit_test_cases_summary.txt && cat tmp/junit_test_cases_summary.txt
# ruby bin/collect_junit_xml_reports.rb > tmp/junit_test_cases_summary2.txt && cat tmp/junit_test_cases_summary2.txt
#
# Show a diff:
# git diff --no-index tmp/junit_test_cases_summary.txt tmp/junit_test_cases_summary2.txt
# or
# diff tmp/junit_test_cases_summary.txt tmp/junit_test_cases_summary2.txt

require 'juniter'

report_directory = 'tmp/test-reports/rspec/queue_mode'
xml_files = Dir.glob("#{report_directory}/rspec_final_results_*.xml")
tests = []

xml_files.each do |file_name|
  xml = Juniter.from_file(file_name)

  xml.test_suites.test_suites.each do |test_suite|
    test_suite.test_cases.each do |test_case|
      class_name = test_case.class_name
      name = test_case.name
      test = "#{class_name}, #{name}"
      tests << test
    end
  end
end

tests.sort!

puts tests
puts
puts "Test cases: #{tests.size}"
