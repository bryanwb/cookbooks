require 'chefspec'

describe 'jboss::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'jboss::default' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
