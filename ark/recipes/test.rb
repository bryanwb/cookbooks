ark_put 'java' do
  url 'http://download.oracle.com/otn-pub/java/jdk/7u2-b13/jdk-7u2-linux-x64.tar.gz'
  checksum '411a204122c5e45876d6edae1a031b718c01e6175833740b406e8aafc37bc82d'
  path '/usr/local'
  owner 'root'
  has_binaries [ '/bin/javaws' ]
end

ark_dump "liferay_client_dependencies" do
  url "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-client-6.1.0-ce-ga1-20120106155615760.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329490764&use_mirror=ignum"
  checksum 'd6b7f7801b02dafad318f2fb9a92cb9a7f0fe000f47590cc74d1c28cc17802f6'
  path '/usr/local/foo'
  stop_file 'wsdl4j.jar'
  owner 'hitman'
end

ark_cherry_pick 'mysql-connector-java-5.0.8-bin.jar' do
  url 'http://gd.tuwien.ac.at/db/mysql/Downloads/Connector-J/mysql-connector-java-5.0.8.tar.gz'
  checksum '660a0e2a2c88a5fe65f1c5baadb20535095d367bc3688e7248a622f4e71ad68d'
  path '/usr/local/foo'
  owner 'hitman'
end

ark_cherry_pick 'mysql-connector' do
  url 'http://gd.tuwien.ac.at/db/mysql/Downloads/Connector-J/mysql-connector-java-5.0.8.tar.gz'
  pick "mysql-connector-java-5.0.8-bin.jar"
  checksum '660a0e2a2c88a5fe65f1c5baadb20535095d367bc3688e7248a622f4e71ad68d'
  path '/usr/local/bar'
  owner 'hitman'
end

ark_cherry_pick 'jaxrpc.jar' do
  url "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-client-6.1.0-ce-ga1-20120106155615760.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329490764&use_mirror=ignum"
  checksum 'd6b7f7801b02dafad318f2fb9a92cb9a7f0fe000f47590cc74d1c28cc17802f6'
  path '/usr/local/baz'
  owner 'hitman'
end

ark_cherry_pick 'jaxrpc' do
  url "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-client-6.1.0-ce-ga1-20120106155615760.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329490764&use_mirror=ignum"
  pick "jaxrpc.jar"
  checksum 'd6b7f7801b02dafad318f2fb9a92cb9a7f0fe000f47590cc74d1c28cc17802f6'
  path '/usr/local/foobar'
  owner 'hitman'
end


# ark 'java' do
#   url 'http://download.oracle.com/otn-pub/java/jdk/7u2-b13/jdk-7u2-linux-x64.tar.gz'
#   version '7.2'
#   home_dir "/tmp/jvm"
#   no_symlink  true
#   append_env_path true
#   owner 'hitman'
# end

# ark 'liferay-client' do
#   release_url "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-client-6.1.0-ce-ga1-20120106155615760.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329490764&use_mirror=ignum"
#   version "6.1.0"
#   user "hitman"
#   stop_file "portal-client.jar"
# end


