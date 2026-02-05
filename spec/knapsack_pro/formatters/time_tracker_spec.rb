require 'open3'
require 'tmpdir'

describe 'TimeTracker' do
  around(:each) do |example|
    Dir.mktmpdir(nil, 'spec_time_tracker') do |dir|
      @dir = dir
      example.run
    end
  end

  describe '#queue' do
    it 'single example' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
          it do
            sleep 0.1
            expect(1).to eq 1
          end
        end
      SPEC

      run_specs(spec, 'queue') do |spec_paths, queue|
        expect(queue.size).to eq(1)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to be_between(0.1, 0.2).exclusive
      end
    end

    it 'two files' do
      spec0 = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker 1' do
          it do
            sleep 0.1
            expect(1).to eq 1
          end
        end
      SPEC

      spec1 = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker 2' do
          it do
            sleep 0.2
            expect(1).to eq 1
          end
        end
      SPEC

      run_specs([spec0, spec1], 'queue') do |spec_paths, queue|
        expect(queue.size).to eq(2)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to be_between(0.1, 0.2).exclusive
        expect(queue[1]['path']).to eq(spec_paths[1])
        expect(queue[1]['time_execution']).to be_between(0.2, 0.3).exclusive
      end
    end

    it 'failing example' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
          it do
            sleep 0.1
            expect(1).to eq 2
          end
        end
      SPEC

      run_specs(spec, 'queue') do |spec_paths, queue|
        expect(queue.size).to eq(1)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to be_between(0.1, 0.2).exclusive
      end
    end

    it 'pending example' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
          xit do
            sleep 0.1
            expect(1).to eq 2
          end
        end
      SPEC

      run_specs(spec, 'queue') do |spec_paths, queue|
        expect(queue.size).to eq(1)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to eq(0.0)
      end
    end

    it 'multiple top level groups' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker 1' do
          it do
            sleep 0.1
            expect(1).to eq 1
          end
        end

        describe 'KnapsackPro::Formatters::TimeTracker 2' do
          it do
            sleep 0.2
            expect(1).to eq 1
          end
        end
      SPEC

      run_specs(spec, 'queue') do |spec_paths, queue|
        expect(queue.size).to eq(1)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to be_between(0.3, 0.4).exclusive
      end
    end

    it 'rspec split by test example' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker 1' do
          it do
            expect(1).to eq 1
          end

          it do
            sleep 0.1
            expect(1).to eq 1
          end
        end

        describe 'KnapsackPro::Formatters::TimeTracker 2' do
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

      run_specs(spec, 'queue', env: 'TEST__SBTE=1') do |spec_paths, queue|
        expect(queue.size).to eq(4)

        spec_path = spec_paths[0]
        expect(queue.find { |time| time['path'] == "#{spec_path}[1:1]" }['time_execution']).to be_between(0.0, 0.1).exclusive
        expect(queue.find { |time| time['path'] == "#{spec_path}[1:2]" }['time_execution']).to be_between(0.1, 0.2).exclusive
        expect(queue.find { |time| time['path'] == "#{spec_path}[2:1]" }['time_execution']).to be_between(0.2, 0.3).exclusive
        expect(queue.find { |time| time['path'] == "#{spec_path}[2:2]" }['time_execution']).to be_between(0.3, 0.4).exclusive
      end
    end

    it 'hooks' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
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

      run_specs(spec, 'queue') do |spec_paths, queue|
        expect(queue.size).to eq(1)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to be_between(0.6, 0.7).exclusive
      end
    end

    it 'nested hooks' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
          before(:all) do
            sleep 0.1
          end

          after(:all) do
            sleep 0.1
          end

          it do
            expect(1).to eq 1
          end

          describe do
            before(:all) do
              sleep 0.1
            end

            after(:all) do
              sleep 0.1
            end

            it do
              expect(1).to eq 1
            end
          end

          describe do
            before(:all) do
              sleep 0.1
            end

            after(:all) do
              sleep 0.1
            end

            it do
              expect(1).to eq 1
            end
          end
        end
      SPEC

      run_specs(spec, 'queue') do |spec_paths, queue|
        expect(queue.size).to eq(1)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to be_between(0.6, 0.7).exclusive
      end
    end

    it 'hooks with rspec split by test example' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
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

      run_specs(spec, 'queue', env: 'TEST__SBTE=1') do |spec_paths, queue|
        expect(queue.size).to eq(2)

        spec_path = spec_paths[0]
        expect(queue.find { |time| time['path'] == "#{spec_path}[1:1]" }['time_execution']).to be_between(0.4, 0.5).exclusive
        expect(queue.find { |time| time['path'] == "#{spec_path}[1:2]" }['time_execution']).to be_between(0.4, 0.5).exclusive
      end
    end

    it 'nested hooks with rspec split by test example' do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
          before(:all) do
            sleep 0.1
          end

          after(:all) do
            sleep 0.1
          end

          it do
            expect(1).to eq 1
          end

          describe do
            before(:all) do
              sleep 0.1
            end

            after(:all) do
              sleep 0.1
            end

            it do
              expect(1).to eq 1
            end
          end

          describe do
            before(:all) do
              sleep 0.1
            end

            after(:all) do
              sleep 0.1
            end

            it do
              expect(1).to eq 1
            end
          end
        end
      SPEC

      run_specs(spec, 'queue', env: 'TEST__SBTE=1') do |spec_paths, queue|
        expect(queue.size).to eq(3)

        spec_path = spec_paths[0]
        expect(queue.find { |time| time['path'] == "#{spec_path}[1:1]" }['time_execution']).to be_between(0.2, 0.3).exclusive
        expect(queue.find { |time| time['path'] == "#{spec_path}[1:2:1]" }['time_execution']).to be_between(0.4, 0.5).exclusive
        expect(queue.find { |time| time['path'] == "#{spec_path}[1:3:1]" }['time_execution']).to be_between(0.4, 0.5).exclusive
      end
    end

    it 'unknown path' do
      spec = <<~SPEC
        RSpec.configure do |config|
          config.before(:all) do
            time_tracker = ::RSpec.configuration.formatters.find { |f| f.class.to_s == 'TestableTimeTracker' }
            time_tracker.scheduled_paths = ['#{@dir}/0_spec.rb']
          end
        end

        describe 'KnapsackPro::Formatters::TimeTracker' do
          it do
            expect(1).to eq 1
          end
        end
      SPEC

      run_specs(spec, 'queue', env: 'TEST__EMPTY_FILE_PATH=1') do |spec_paths, queue|
        expect(queue.size).to eq(1)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to eq(0.0)
      end
    end

    it 'empty group' do
      spec = <<~SPEC
        RSpec.configure do |config|
          config.before(:suite) do
            time_tracker = ::RSpec.configuration.formatters.find { |f| f.class.to_s == 'TestableTimeTracker' }
            time_tracker.scheduled_paths = ['#{@dir}/0_spec.rb']
          end
        end

        describe 'KnapsackPro::Formatters::TimeTracker' do
        end
      SPEC

      run_specs(spec, 'queue') do |spec_paths, queue|
        expect(queue.size).to eq(1)
        expect(queue[0]['path']).to eq(spec_paths[0])
        expect(queue[0]['time_execution']).to eq(0.0)
      end
    end
  end

  describe '#duration' do
    it do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
          it do
            expect(1).to eq 1
          end
        end
      SPEC

      run_specs(spec, 'duration') do |_, duration|
        expect(duration).to be_between(0.0, 0.1).exclusive
      end
    end
  end

  describe '#unexecuted_test_files' do
    it do
      spec = <<~SPEC
        RSpec.configure do |config|
          config.before(:all) do
            time_tracker = ::RSpec.configuration.formatters.find { |f| f.class.to_s == 'TestableTimeTracker' }
            time_tracker.scheduled_paths = ['#{@dir}/0_spec.rb', 'foo_spec.rb[1:1]']
          end
        end

        describe 'KnapsackPro::Formatters::TimeTracker' do
          xit do
          end
        end
      SPEC

      run_specs(spec, 'unexecuted_test_files') do |spec_paths, unexecuted_test_files|
        expect(unexecuted_test_files).to eq(["#{@dir}/0_spec.rb", 'foo_spec.rb[1:1]'])
      end
    end
  end

  describe '#batch' do
    it do
      spec = <<~SPEC
        describe 'KnapsackPro::Formatters::TimeTracker' do
          it do
            sleep 0.1
            expect(1).to eq 1
          end
        end
      SPEC

      run_specs(spec, 'batch') do |spec_paths, batch|
        expect(batch.size).to eq(1)
        expect(batch[0]['path']).to eq(spec_paths[0])
        expect(batch[0]['time_execution']).to be_between(0.1, 0.2).exclusive
      end
    end
  end

  def run_specs(specs, method, env: '')
    paths = Array(specs).map.with_index do |spec, i|
      path = "#{@dir}/#{i}_spec.rb"
      File.write(path, spec)
      path
    end

    out, err, _status = Open3.capture3("#{env} TEST__METHOD=#{method} bundle exec rspec --default-path spec_time_tracker -f TestableTimeTracker spec_time_tracker")
    puts err if ENV['TEST__DEBUG']
    result = Marshal.load(out.lines.last)

    yield(paths, result)
  end
end
