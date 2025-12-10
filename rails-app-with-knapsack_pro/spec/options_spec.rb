# https://rspec.info/features/3-12/rspec-core/configuration/read-options-from-file/
describe 'RSpec Options' do
  if ENV['RSPEC_CUSTOM_OPTIONS_ENABLED']
    it { expect(RSpec.configuration.color_mode).to eq :off }
  else
    it { expect(RSpec.configuration.color_mode).to eq :automatic }
  end
end
