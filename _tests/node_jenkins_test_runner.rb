require_relative '../_docker/lib/process_runner'

#
# This class wraps a number of calls to _docker/control.rb to allow us to run the acceptance tests with a number of profiles
# and amalgamate the result into a generalised fail or pass
#
class NodeJenkinsTestRunner

  def initialize(host_to_test, control_script_directory, process_runner)
    @host_to_test = host_to_test
    @control_script_directory = control_script_directory
    @process_runner = process_runner
  end

  #
  # Run the tests for each of our test profiles
  #
  def run_tests
    tests_passed = true
    %w(desktop mobile).each do |profile|
      tests_passed &= execute_test(profile)
    end
    tests_passed
  end

  private

  #
  # Execute the tests for the given profile
  #
  def execute_test(profile)
    success = true
    test_execution_command = build_run_tests_command(profile)

    begin
      @process_runner.execute!(test_execution_command)
    rescue
      puts "Run of test profile '#{profile}' failed."
      success = false
    end
    success
  end

  #
  # Reads an environment variable, returning its value or nil if it is not set or empty
  #
  def read_env_variable(variable_name)
    return nil if ENV[variable_name].nil? || ENV[variable_name].empty?
    ENV[variable_name]
  end

  #
  # Builds the command to use to execute the tests, including whether or not we should send updates to GitHub and any Cucumber tags
  # that should be applied
  #
  def build_run_tests_command(profile)
    command = "ruby _tests/run_tests.rb --e2e --use-docker --base-url=#{@host_to_test}"
    github_sha1 = read_env_variable('ghprbActualCommit')
    cucumber_tags = read_env_variable('CUCUMBER_TAGS')
    command += " --update-github-status=#{github_sha1}" if github_sha1
    command += ' --browser=iphone_6' if profile == 'mobile'
    command += " --profile=#{profile}"
    if profile == 'desktop'
      command += ' --cucumber-tags=~@mobile'
    elsif profile == 'desktop' && cucumber_tags
      command += " --cucumber-tags=~@mobile,#{cucumber_tags}"
    elsif profile == 'mobile' && cucumber_tags
      command += " --cucumber-tags=~@desktop,#{cucumber_tags}"
    else
      command += ' --cucumber-tags=~@desktop'
    end
    command
  end

end

#
# Wraps the actual execution of the tests to allow us to unit test that call
#
def execute(jenkins_test_runner)
  tests_passed = jenkins_test_runner.run_tests
  Kernel.exit(tests_passed ? 0 : 1)
end

if $PROGRAM_NAME == __FILE__

  host_to_test = ARGV[0]
  if host_to_test.nil? || host_to_test.empty?
    puts 'Please specify the host to test as the first argument to this script e.g. ruby jenkins_test_runner.rb https://developers.redhat.com'
    Kernel.exit(1)
  end

  jenkins_test_runner = NodeJenkinsTestRunner.new(host_to_test, "#{__dir__}", ProcessRunner.new)
  execute(jenkins_test_runner)
end
