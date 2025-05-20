FROM cgr.dev/chainguard/ruby:latest-dev AS builder

WORKDIR /build
RUN <<RUN
cat <<GEMFILE > Gemfile
source "https://rubygems.org"
GEMFILE

gem install bundler
bundle config set --local path vendor/bundle
bundle install
RUN

RUN <<RUN
cat <<RAKEFILE > Rakefile
RAKEFILE

mkdir bin
cat <<CI > bin/ci
ENV['PATH'] =+ "#{Gem.user_dir}/bin"
require 'bundler/setup'

def check_result(cmd, result)
  puts "Command: #{cmd}"

  if result
    puts 'It works!'
  else
    raise 'The command failed!'
  end

  puts
end

# it works
cmd = 'bundle --version'
result = Kernel.system({ 'RAILS_ENV' => 'test' }, cmd)
check_result(cmd, result)

# the redirection operator does not work
cmd = 'bundle --version 2>/dev/null'
result = Kernel.system({ 'RAILS_ENV' => 'test' }, cmd)
check_result(cmd, result)

CI
RUN

FROM cgr.dev/chainguard/ruby:latest

WORKDIR /app
COPY --from=builder /home/nonroot/.local /home/nonroot/.local
COPY --from=builder /build /app
CMD ["bin/ci"]
