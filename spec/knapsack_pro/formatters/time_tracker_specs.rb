# Named _specs.rb on purpose because it hangs if run as part of `bundle exec rspec`.
# Use `bundle exec ruby spec/knapsack_pro/formatters/time_tracker_specs.rb` instead.

require 'rspec/core'
require 'knapsack_pro'
require 'stringio'
require 'tempfile'
require_relative '../../../lib/knapsack_pro/formatters/time_tracker'

class TestTimeTracker
  def test_single_example
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        it do
          sleep 0.1
          expect(1).to eq 1
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 1
      raise unless times[0]["path"] == spec_paths.first
      raise unless times[0]["time_execution"] > 0.10
      raise unless times[0]["time_execution"] < 0.15
    end
  end

  def test_two_files
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec_1 = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker 1" do
        it do
          sleep 0.1
          expect(1).to eq 1
        end
      end
    SPEC

    spec_2 = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker 2" do
        it do
          sleep 0.2
          expect(1).to eq 1
        end
      end
    SPEC

    run_specs([spec_1, spec_2]) do |spec_paths, times|
      raise unless times.size == 2
      raise unless times.first["path"] == spec_paths.first
      raise unless times.first["time_execution"] > 0.10
      raise unless times.first["time_execution"] < 0.15
      raise unless times.last["path"] == spec_paths.last
      raise unless times.last["time_execution"] > 0.20
      raise unless times.last["time_execution"] < 0.25
    end
  end

  def test_failing_example
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        it do
          sleep 0.1
          expect(1).to eq 2
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 1
      raise unless times[0]["path"] == spec_paths.first
      raise unless times[0]["time_execution"] > 0.10
      raise unless times[0]["time_execution"] < 0.15
    end
  end

  def test_pending_example
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        xit do
          sleep 0.1
          expect(1).to eq 2
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 1
      raise unless times[0]["path"] == spec_paths.first
      raise unless times[0]["time_execution"] == 0.0
    end
  end

  def test_multiple_top_level_groups
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker 1" do
        it do
          sleep 0.1
          expect(1).to eq 1
        end
      end

      describe "KnapsackPro::Formatters::TimeTracker 2" do
        it do
          sleep 0.2
          expect(1).to eq 1
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 1
      raise unless times[0]["path"] == spec_paths.first
      raise unless times[0]["time_execution"] > 0.30
      raise unless times[0]["time_execution"] < 0.35
    end
  end

  def test_rspec_split_by_test_example
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      true
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker 1" do
        it do
          expect(1).to eq 1
        end

        it do
          sleep 0.1
          expect(1).to eq 1
        end
      end

      describe "KnapsackPro::Formatters::TimeTracker 2" do
        it do
          sleep 0.2
          expect(1).to eq 1
        end

        it do
          sleep 0.3
          expect(1).to eq 1
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 4
      spec_path = spec_paths.first
      raise unless times.find { |time| time["path"] == "#{spec_path}[1:1]" }["time_execution"] < 0.05
      raise unless times.find { |time| time["path"] == "#{spec_path}[1:2]" }["time_execution"] > 0.10
      raise unless times.find { |time| time["path"] == "#{spec_path}[1:2]" }["time_execution"] < 0.15
      raise unless times.find { |time| time["path"] == "#{spec_path}[2:1]" }["time_execution"] > 0.20
      raise unless times.find { |time| time["path"] == "#{spec_path}[2:1]" }["time_execution"] < 0.25
      raise unless times.find { |time| time["path"] == "#{spec_path}[2:2]" }["time_execution"] > 0.30
      raise unless times.find { |time| time["path"] == "#{spec_path}[2:2]" }["time_execution"] < 0.35
    end
  end

  def test_hooks
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        before(:all) do
          sleep 0.1
        end

        before(:each) do
          sleep 0.1
        end

        after(:each) do
          sleep 0.1
        end

        it do
          expect(1).to eq 1
        end

        it do
          expect(1).to eq 1
        end

        after(:all) do
          sleep 0.1
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 1
      raise unless times[0]["path"] == spec_paths.first
      raise unless times[0]["time_execution"] > 0.60
      raise unless times[0]["time_execution"] < 0.65
    end
  end

  def test_hooks_with_rspec_split_by_test_example
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      true
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        before(:all) do
          sleep 0.1
        end

        before(:each) do
          sleep 0.1
        end

        after(:each) do
          sleep 0.1
        end

        it do
          expect(1).to eq 1
        end

        it do
          expect(1).to eq 1
        end

        after(:all) do
          sleep 0.1
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 2
      spec_path = spec_paths.first
      raise unless times.find { |time| time["path"] == "#{spec_path}[1:1]" }["time_execution"] > 0.40
      raise unless times.find { |time| time["path"] == "#{spec_path}[1:1]" }["time_execution"] < 0.45
      raise unless times.find { |time| time["path"] == "#{spec_path}[1:2]" }["time_execution"] > 0.40
      raise unless times.find { |time| time["path"] == "#{spec_path}[1:2]" }["time_execution"] < 0.45
    end
  end

  def test_unknown_path
    KnapsackPro::Formatters::TimeTracker.class_eval do
      alias_method :original_file_path_for, :file_path_for

      define_method(:file_path_for) do |_example|
        ""
      end
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        it do
          expect(1).to eq 1
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 1
      raise unless times[0]["path"] == spec_paths.first
      raise unless times[0]["time_execution"] == 0.0
    end

  ensure
    KnapsackPro::Formatters::TimeTracker.class_eval do
      undef :file_path_for
      alias_method :file_path_for, :original_file_path_for
    end
  end

  def test_empty_group
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
      end
    SPEC

    run_specs(spec) do |spec_paths, times|
      raise unless times.size == 1
      raise unless times[0]["path"] == spec_paths.first
      raise unless times[0]["time_execution"] == 0.0
    end
  end

  def test_duration
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        it do
          expect(1).to eq 1
        end
      end
    SPEC

    run_specs(spec) do |_, _, time_tracker|
      raise unless time_tracker.duration > 0.0
    end
  end

  def test_unexecuted_test_files
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        xit do
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, _, time_tracker|
      unexecuted_test_files = ["foo_spec.rb", "bar_spec.rb"]
      # Need to filter because RSpec keeps accumulating state.
      files = time_tracker
        .unexecuted_test_files(spec_paths + unexecuted_test_files)
        .filter { |file| spec_paths.include?(file) || unexecuted_test_files.include?(file) }

      raise unless files.size == 3
    end
  end

  def test_subset
    KnapsackPro::Formatters::TimeTracker.define_method(:rspec_split_by_test_example?) do |_file|
      false
    end

    spec = <<~SPEC
      describe "KnapsackPro::Formatters::TimeTracker" do
        it "works" do
          sleep 0.1
          expect(1).to eq 1
        end
      end
    SPEC

    run_specs(spec) do |spec_paths, times, time_tracker|
      # Need to filter because RSpec keeps accumulating state.
      files = time_tracker
        .batch
        .filter { |file| spec_paths.include?(file["path"]) }

      raise unless files.size == 1
      raise unless files[0]["path"] == spec_paths.first
      raise unless files[0]["time_execution"] > 0.10
      raise unless files[0]["time_execution"] < 0.15
    end
  end

  private

  def run_specs(specs)
    files = Array(specs).map.with_index do |spec, i|
      file = Tempfile.new(["tmp_time_tracker_#{i}", "_spec.rb"], "./spec/knapsack_pro/formatters/")
      file.write(spec)
      file.rewind
      file
    end

    paths = files.map(&:path).map { _1.sub("./", "") }

    options = ::RSpec::Core::ConfigurationOptions.new([
      "--format", KnapsackPro::Formatters::TimeTracker.to_s,
      *paths,
    ])
    runner = ::RSpec::Core::Runner.new(options)
    runner.run(StringIO.new, StringIO.new)

    time_tracker = runner.configuration.formatters.find { |f| f.class.to_s == KnapsackPro::Formatters::TimeTracker.to_s }
    # Need to filter because RSpec keeps accumulating state.
    times = time_tracker
      .queue(paths)
      .sort_by { |time| time["path"] }
      .filter do |time|
        paths.any? { |path| time["path"].start_with?(path) }
      end
    yield(paths, times, time_tracker)

  ensure
    # Need to reset because RSpec keeps reusing the same instance.
    time_tracker.instance_variable_set(:@queue, {}) if time_tracker
    time_tracker.instance_variable_set(:@started, time_tracker.send(:now)) if time_tracker
  end
end

TestTimeTracker
  .instance_methods
  .filter { |method| method.to_s.start_with?("test_") }
  .shuffle
  .each do |method|
    puts method
    TestTimeTracker.new.public_send(method)
  end
