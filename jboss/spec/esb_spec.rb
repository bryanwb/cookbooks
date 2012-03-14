require 'chefspec'

describe 'jboss::esb' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'jboss::esb' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
