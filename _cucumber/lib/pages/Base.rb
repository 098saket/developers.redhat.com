require 'rspec'

class Base
  include Capybara::DSL
  include RSpec::Matchers

  attr_reader :driver

  BASE_URL = ENV['HOST_TO_TEST'] ||= 'http://docker:32768'

  def initialize(driver)
    @driver = driver
  end

  def loaded?(title)
    if Capybara.current_driver == 'poltergeist'.to_sym
      raise "There was a problem loading the page, expected status code to be 200, but was #{page.status_code}" unless page.status_code.eql?(200)
    end
    raise "Expected page title to be #{title}, but was #{page.title}" unless page.has_title?(title).eql?(true)
    wait_for_ajax
  end

  private

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time ) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

end
