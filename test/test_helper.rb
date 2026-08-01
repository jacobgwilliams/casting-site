ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require_relative "support/test_data"
Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |file| require file }

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    setup do
      ActionMailer::Base.deliveries.clear
    end
  end
end
