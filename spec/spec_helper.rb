require 'simplecov'
SimpleCov.start do
    add_filter "spec/"
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include ValidateDate
end

def fail_fast_translations
  around :each do |ex|
    old_handler = I18n.exception_handler
    begin
      I18n.exception_handler = FailFastTranslationExceptionHandler.new
      ex.run
    ensure
      I18n.exception_handler = old_handler
    end
  end
end

# the origional will fail for many reasons other than what you are interested in ... en.menu.Quick Entries.title for example.
# by passing in a block, it will only throw exceptions for trasnalations you are testing
def fail_fast_translations_for_block(&block)
  old_handler = I18n.exception_handler
  begin
    I18n.exception_handler = FailFastTranslationExceptionHandler.new
    yield
  ensure
    I18n.exception_handler = old_handler
  end
end
