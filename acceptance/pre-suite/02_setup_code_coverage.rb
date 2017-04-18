if ENV["BEAKER_COVERAGE"]
  require 'beaker/hosts'
  extend Beaker::Hosts
  test_name 'setup simplecov' do
    on(sut, "yum install -y ruby-devel")
    on(sut, "gem install simplecov --force")
    sut.add_env_var('BEAKER_COVERAGE', 'true')
  end
end
