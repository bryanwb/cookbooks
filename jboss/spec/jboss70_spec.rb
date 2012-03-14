require 'chefspec'

describe 'jboss::jboss70' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'jboss::jboss70' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
