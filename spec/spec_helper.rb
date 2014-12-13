RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  # config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  # config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  config.before do
    allow(ENV).to receive(:[]) do |key|
      fail "stub me: ENV[#{key.inspect}]"
    end

    allow(ENV).to receive(:[]=) do |key, value|
      fail "stub me: ENV[#{key.inspect}] = #{value.inspect}"
    end
  end

  config.after do
    begin
      Nenv.method(:reset).call
    rescue NameError
    end
  end
end
