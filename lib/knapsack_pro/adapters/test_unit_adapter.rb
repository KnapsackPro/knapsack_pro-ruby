module KnapsackPro
  module Adapters
    class TestUnitAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'test/**{,/*/**}/*_test.rb'
      @@parent_of_test_dir = nil

      def self.test_path(obj)
        first_test = obj.tests.first
        method = first_test.method_name
        full_test_path = first_test.method(method).source_location.first
        parent_of_test_dir_regexp = Regexp.new("^#{@@parent_of_test_dir}")
        test_path = full_test_path.gsub(parent_of_test_dir_regexp, '.')
        # test_path will look like ./test/dir/unit_test.rb
        test_path
      end

      # Overrides the method from unit-test gem
      # https://github.com/test-unit/test-unit/blob/master/lib/test/unit/testsuite.rb
      module BindTimeTrackerTestUnitPlugin
        def run_startup(result)
          return if @test_case.nil?
          KnapsackPro.tracker.current_test_path = KnapsackPro::Adapters::TestUnitAdapter.test_path(self)
          KnapsackPro.tracker.start_timer
          return if !@test_case.respond_to?(:startup)
          begin
            @test_case.startup
          rescue Exception
            raise unless handle_exception($!, result)
          end
        end

        def run_shutdown(result)
          return if @test_case.nil?
          KnapsackPro.tracker.stop_timer
          return if !@test_case.respond_to?(:shutdown)
          begin
            @test_case.shutdown
          rescue Exception
            raise unless handle_exception($!, result)
          end
        end
      end

      def bind_time_tracker
        Test::Unit::TestSuite.send(:prepend, BindTimeTrackerTestUnitPlugin)

        add_post_run_callback do
          KnapsackPro.logger.debug(KnapsackPro::Presenter.global_time)
        end
      end

      def bind_save_report
        add_post_run_callback do
          KnapsackPro::Report.save
        end
      end

      def set_test_helper_path(file_path)
        test_dir_path = File.dirname(file_path)
        @@parent_of_test_dir = File.expand_path('../', test_dir_path)
      end

      private

      def add_post_run_callback(&block)
        Test::Unit.at_exit do
          block.call
        end
      end
    end
  end
end
