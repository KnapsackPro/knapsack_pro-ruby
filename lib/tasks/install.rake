require 'knapsack_pro'
require 'tty-prompt'

def step_for_rspec(prompt)
  prompt.say "Step for RSpec", color: :red
  prompt.say "Add at the beginning of your spec/spec_helper.rb:"

  prompt.say %{
require 'knapsack_pro'

KnapsackPro::Adapters::RSpecAdapter.bind
  }, color: :bright_red
end

def step_for_minitest(prompt)
  prompt.say "Step for Minitest", color: :red
  prompt.say "Add at the beginning of your test/test_helper.rb:"

  prompt.say %{
require 'knapsack_pro'

knapsack_pro_adapter = KnapsackPro::Adapters::MinitestAdapter.bind
knapsack_pro_adapter.set_test_helper_path(__FILE__)
  }, color: :bright_red
end

def step_for_cucumber(prompt)
  prompt.say "Step for Cucumber", color: :red
  prompt.say "Create file features/support/knapsack_pro.rb and add there:"

  prompt.say %{
require 'knapsack_pro'

KnapsackPro::Adapters::CucumberAdapter.bind
  }, color: :bright_red
end

def step_for_spinach(prompt)
  prompt.say "Step for Spinach", color: :red
  prompt.say "Create file features/support/knapsack_pro.rb and add there:"

  prompt.say %{
require 'knapsack_pro'

KnapsackPro::Adapters::SpinachAdapter.bind
  }, color: :bright_red
end

def step_for_vcr(prompt)
  prompt.say "Step for VCR gem", color: :red
  prompt.say "Add Knapsack Pro API subdomain to ignore hosts"
  prompt.say "in spec/spec_helper.rb or wherever is your VCR configuration"

  prompt.say %{
VCR.configure do |config|
  config.ignore_hosts 'localhost', '127.0.0.1', '0.0.0.0', 'api.knapsackpro.com'
end

WebMock.disable_net_connect!(:allow => 'api.knapsackpro.com') if defined?(WebMock)
  }, color: :bright_red
end

def step_for_ci_circle(prompt, answers)
  prompt.say "Step for https://circleci.com", color: :red
  prompt.say "Update circle.yml in your project:"

  prompt.say %{
machine:
  environment:
    # Tokens should be set in CircleCI settings to avoid expose tokens in build logs
  }, color: :bright_red

  answers[:testing_tools].each do |tool|
    prompt.say %{
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_#{tool.upcase}: #{tool}-token
    }, color: :bright_red
  end

  prompt.say %{
test:
  override:
  }, color: :bright_red

  answers[:testing_tools].each do |tool|
    prompt.say %{
    # Step for #{tool}
    - bundle exec rake knapsack_pro:#{tool}:
        parallel: true # Caution: there are 8 spaces indentation!
    }, color: :bright_red
  end

  puts
  set_api_tokens_on_ci(prompt, answers)
end

def step_for_ci_travis(prompt, answers)
  prompt.say "Step for https://travis-ci.org", color: :red
  prompt.say "You can parallel your builds across virtual machines with travis matrix feature."
  prompt.say "https://docs.travis-ci.com/user/speeding-up-the-build/#Parallelizing-your-builds-across-virtual-machines"
  puts
  prompt.say "Update .travis.yml"

  prompt.say %{
script:
  }, color: :bright_red

  answers[:testing_tools].each do |tool|
    prompt.say %{
  # Step for #{tool}
  - "bundle exec rake knapsack_pro:#{tool}"
    }, color: :bright_red
  end

  prompt.say %{
env:
  global:
    - KNAPSACK_PRO_CI_NODE_TOTAL=2

    # tokens should be set in travis settings in web interface to avoid expose tokens in build logs
  }, color: :bright_red

  answers[:testing_tools].each do |tool|
    prompt.say %{
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_#{tool.upcase}=#{tool}-token
    }, color: :bright_red
  end

  prompt.say %{
  matrix:
    - KNAPSACK_PRO_CI_NODE_INDEX=0
    - KNAPSACK_PRO_CI_NODE_INDEX=1
  }, color: :bright_red

  puts
  prompt.say "If you want more parallel jobs then update accordingly:"
  tip_ci_node_total_and_index(prompt)

  puts
  set_api_tokens_on_ci(prompt, answers)
end

def step_for_ci_buildkite(prompt, answers)
  prompt.say "Step for https://buildkite.com", color: :red
  prompt.say "Please configure the parallelism parameter in your build step and run the appropiate command in your build:"

  answers[:testing_tools].each do |tool|
    prompt.say %{
# Step for #{tool}
bundle exec rake knapsack_pro:#{tool}
    }, color: :bright_red
  end

  puts
  set_api_tokens_on_ci(prompt, answers)
end

def step_for_ci_semaphore(prompt, answers)
  prompt.say "Step for https://semaphoreci.com", color: :red
  prompt.say "Set knapsack pro command for each parallel thread. Here is example:"

  answers[:testing_tools].each do |tool|
    prompt.say %{
# Step for #{tool}

# Thread 1
bundle exec rake knapsack_pro:#{tool}

# Thread 2
bundle exec rake knapsack_pro:#{tool}
    }, color: :bright_red
  end

  puts
  set_api_tokens_on_ci(prompt, answers)
end

def step_for_ci_snap_ci(prompt, answers)
  prompt.say "Step for https://snap-ci.com", color: :red
  prompt.say "Please configure number of workers for your project in configuration settings in order to enable parallelism."
  prompt.say "Next thing is to set below commands to be executed in your stage:"

  answers[:testing_tools].each do |tool|
    prompt.say %{
# Step for #{tool}
bundle exec rake knapsack_pro:#{tool}
    }, color: :bright_red
  end

  puts
  set_api_tokens_on_ci(prompt, answers)
end

def step_for_ci_other(prompt, answers)
  prompt.say "Step for other CI provider", color: :red
  prompt.say "Set below global variables on your CI server."
  puts

  prompt.say "Git installed on the CI server will be used to determine branch name and current commit hash."

  prompt.say %{
KNAPSACK_PRO_REPOSITORY_ADAPTER=git
  }, color: :bright_red
  puts

prompt.say "Path to the project repository on CI server, for instance:"
  prompt.say %{
KNAPSACK_PRO_PROJECT_DIR=/home/ubuntu/my-app-repository
  }, color: :bright_red
  puts

  prompt.say "You can learn more about those variables here:"
  prompt.say "https://github.com/KnapsackPro/knapsack_pro-ruby#when-you-set-global-variable-knapsack_pro_repository_adaptergit-required-when-ci-provider-is-not-supported"
  puts

  set_api_tokens_on_ci(prompt, answers)

  # set test run command on CI server
  prompt.say "Set test run command on CI server", color: :red
  prompt.say "You must set command responsible for running tests for each CI node."
  prompt.say "Let's assume you have 2 CI nodes. Here are commands you need to run for each CI node."

  answers[:testing_tools].each do |tool|
    puts
    prompt.say "Step for #{tool}"
    prompt.say %{
# Command for first CI node
$ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:#{tool}

# Command for second CI node
$ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:#{tool}
    }, color: :bright_red
  end
  puts
  prompt.say "If you have more CI nodes then update accordingly:"
  tip_ci_node_total_and_index(prompt)
end

def tip_ci_node_total_and_index(prompt)
  prompt.say %{
KNAPSACK_PRO_CI_NODE_TOTAL - total number of your CI nodes
KNAPSACK_PRO_CI_NODE_INDEX - starts from 0, it's index of each CI node
  }, color: :bright_red
end

def set_api_tokens_on_ci(prompt, answers)
  prompt.say "Set API token", color: :red
  prompt.say "You must set different API token on your CI server for each test suite you have:"

  answers[:testing_tools].each do |tool|
    prompt.say %{
KNAPSACK_PRO_TEST_SUITE_TOKEN_#{tool.upcase}
    }, color: :bright_red
  end
  puts
  prompt.say "You can generate more API tokens after sign in https://knapsackpro.com"
  puts
end

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
    answers[:testing_tools] = []
    while answers[:testing_tools].empty?
      answers[:testing_tools] = prompt.multi_select("Choose your testing tools:", TESTING_TOOLS_CHOICES)
    end

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

    puts

    # Instructions how to set up the gem

    answers[:testing_tools].each do |tool|
      send("step_for_#{tool}", prompt)
      puts
    end

    step_for_vcr(prompt) if answers[:has_vcr]
    puts

    send("step_for_ci_#{answers[:ci]}", prompt, answers)
    puts

    prompt.say "That's all steps to start using knapsack_pro gem.", color: :green
    prompt.say "You can learn more about custom configuration and other features:"
    prompt.say "https://knapsackpro.com/features"
    prompt.say "https://github.com/KnapsackPro/knapsack_pro-ruby#table-of-contents"
  end
end
