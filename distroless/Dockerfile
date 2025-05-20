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

cmd = '123'
result = Kernel.system({ 'RAILS_ENV' => 'test' }, cmd)
if result
  puts "It works!"
else
  raise 'The command failed!'
end
CI
RUN

FROM cgr.dev/chainguard/ruby:latest

WORKDIR /app
COPY --from=builder /home/nonroot/.local /home/nonroot/.local
COPY --from=builder /build /app
CMD ["bin/ci"]
