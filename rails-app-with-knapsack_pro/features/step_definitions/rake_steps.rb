Given('I rake_require {string}') do |path|
  Rake.application.rake_require(path)
  Rake::Task.define_task(:environment)
end

When('I invoke the {string} task') do |task|
  Rake::Task[task].invoke
end

Then('the count on {string} equals {int}') do |klass, int|
  expect(Object.const_get(klass).count).to eq(int)
end

Given('I reenable the {string} task') do |task|
  Rake::Task[task].reenable
end

Given('I reset the count on {string} to {int}') do |klass, int|
  Object.const_get(klass).count = int
end

Given('I load_rakefile {string}') do |path|
  Rake.load_rakefile(path)
  Rake::Task.define_task(:environment)
end
