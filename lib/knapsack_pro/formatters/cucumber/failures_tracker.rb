# frozen_string_literal: true

module KnapsackPro
  module Formatters
    module Cucumber
      class FailuresTracker
        def initialize(config)
          failed_locations = {}

          config.on_event :test_case_finished do |event|
            location = event.test_case.location
            id_path = "#{location.file}:#{location.line}"

            ok =
              if config.respond_to?(:strict)
                event.result.ok?(strict: config.strict)
              else
                event.result.ok?
              end

            if ok
              failed_locations.delete(id_path)
            else
              failed_locations[id_path] = location
            end
          end

          config.on_event :test_run_finished do |_event|
            paths = failed_locations.map do |id_path, location|
              # TODO: Tracker currently only tracks by file_path. Track id_path and use the following:
              # KnapsackPro::Config::Env.test_files_encrypted? ? location.file : id_path
              location.file
            end

            paths.uniq.each do |path|
              KnapsackPro.tracker.mark_failed(path)
            end
          end
        end
      end
    end
  end
end
