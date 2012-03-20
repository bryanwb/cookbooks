ark_put 'java' do
  url 'http://download.oracle.com/otn-pub/java/jdk/7u2-b13/jdk-7u2-linux-x64.tar.gz'
  checksum '411a204122c5e45876d6edae1a031b718c01e6175833740b406e8aafc37bc82d'
  owner 'root'
  has_binaries [ '/bin/javaws' ]
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


# ruby_block "playing w/ chef values" do
#   block do
#     puts "the recipe name is #{self.recipe_name}"
#     puts "the cookbook_name is #{self.cookbook_name}"
#     puts "the run_context is"
#     puts run_context.resource_collection.lookup('ark[liferay-client]').inspect
# #    puts run_context.node.run_list.run_list_items[1].resources.inspect
# #    run_context.node.run_list.run_list_items.each do |item|
#  #     puts item.name
#   #  end
#   end
# end
