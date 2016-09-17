require 'knapsack_pro'
require 'tty-prompt'

namespace :knapsack_pro do
  task :install do
    prompt = TTY::Prompt.new
    answers = {}

    puts
    prompt.say "Welcome in knapsack_pro gem installer.", color: :cyan
    puts
    prompt.say "If you will need to set more custom configuration"
    prompt.say "or would like to better understand how gem works please take a look:"
    prompt.say "https://github.com/KnapsackPro/knapsack_pro-ruby"
    puts

    TESTING_TOOLS_CHOICES = {
      'RSpec' => :rspec,
      'Minitest' => :minitest,
      'Cucumber' => :cucumber,
      'Spinach' => :spinach,
    }
    answers[:testing_tools] = prompt.multi_select("Choose your testing tools:", TESTING_TOOLS_CHOICES)

    answers[:has_vcr] = prompt.yes?('Do you use VCR gem?')

    CI_PROVIDER_CHOICES = {
      'https://circleci.com' => :circle,
      'https://travis-ci.org' => :travis,
      'https://buildkite.com' => :buildkite,
      'https://semaphoreci.com' => :semaphore,
      'https://snap-ci.com' => :snap_ci,
      'other' => :other,
    }
    answers[:ci] = prompt.select("What is your CI provider?", CI_PROVIDER_CHOICES)


  end
end
