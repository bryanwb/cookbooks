Overview        
========

An '''ark''' is like an archive but '''Kewler''

Does the fetch-unpack-configure-build-install dance. This is a
modified  verion of Infochimps awesome install_from cookbook
 [http://github.com/infochimps-cookbooks/install_from](http://github.com/infochimps-cookbooks/install_from)

Given a project `pig`, with url `http://apache.org/pig/pig-0.8.0.tar.gz`, and
the default :prefix_root of `/usr/local`, this provider will

* fetch  it to to `/usr/local/src`
* unpack it to :install_dir  (`/usr/local/share/pig-0.8.0`)
* create a symlink for :home_dir (`/usr/local/share/pig`) pointing to :install_dir
* configure the project
* build the project
* install the project

By default, the ark will not run again if the :install_dir is not
empty. You can specify a more granular condition by using :stop_file
whose existence in :install_dir indicates that the ark has already
been unpacked. This is useful when you use several arks to deposit
libraries in a common directory like /usr/local/lib/ or /usr/local/share/tomcat/lib

At this time ark only handles files available from URLs. It does not
handle local files.

Attributes
==========

You can customize the basic attributes to meet your organization's conventions

* default[:ark][:apache_mirror] = 'http://apache.mirrors.tds.net'
* default[:ark][:prefix_root] = "/usr/local"
* default[:ark][:prefix_home] = "share"
* default[:ark][:prefix_install] = "share"
* default[:ark][:prefix_src] = "src"


Resources/Providers
===================

# Actions

- :install: extracts the file and makes a symlink of requested
- :remove: removes the extracted directory and related symlink #TODO

# Attribute Parameters

- release_url: url for tarball, .tar.gz, .bin (oracle-specific), .war, and .zip
  currently supported. Also supports special syntax
  :name:version:apache_mirror: that will auto-magically construct
  download url from the apache mirrors site
- version: software version, required
- checksum: sha256 checksum, used for security 
- prefix_root: prefix_root for installation, defaults to /usr/local/
- mode: file mode for app_home, is an integer
- has_binaries: array of binary commands to symlink to /usr/local/bin/
- add_global_bin_dir: boolean, similar to has_binaries but less granular
  - If true, append the ./bin directory of the extracted directory to
  the PATH environment  variable for all users, does this by placing a file in /etc/profile.d/ which will be read by all users
  be added to the path. The commands are symbolically linked to
  /usr/bin/* . Examples are mvn, java, javac, etc. This option
  provides more granularity than the boolean option
- user: owner of extracted directory, set to "root" by default
- strip_leading_dir: by default, strip the leading directory from the
  extracted archive this can cause unexpected results if there is more
  than one subdirectory in the archive
- junk_paths: The archive's  directory structure is not recreated; all files are
  deposited in the extraction directory. Only applies to zip archives
- stop_file: if you are appending files to a given directory, ark
  needs a condition to test whether the file has already been
  extracted. You can specify a stop_file, a file whose existence
  indicates the ark has previously been extracted and does not need to
  be extracted again

# Examples

    # install Apache Ivy dependency resolution tool
    ark "ivy" do
        release_url 'http://someurl.example.com/ivy.tar.gz'
        version '2.2.0'        
    end
    
This example copies ivy.tar.gz to /usr/local/src/ivy-2.2.0.tar.gz,
unpacks its contents to /usr/local/share/ivy-2.2.0/ -- stripping the
leading directory, and symlinks /usr/local/share/ivy to /usr/local/shary/ivy-2.2.0


ark 'jdk' do
  release_url 'http://download.oracle.com/otn-pub/java/jdk/7u2-b13/jdk-7u2-linux-x64.tar.gz'
  version '7.2'
  home_dir "/usr/local/jvm/default" 
  add_global_bin_dir true
  user 'foobar'
end

This example copies jdk-7u2-linux-x64.tar.gz to /usr/local/src/jdk-7.2.tar.gz,
unpacks its contents to /usr/local/share/jdk-7.2/ -- stripping the
leading directory, symlinks /usr/local/jvm/default to
/usr/local/share/jkd-7.2, and adds /usr/local/share/jdk-7.2/bin/ to
the global PATH for all users. The user 'foobar' is the owner of the
/usr/local/share/jdk-7.2 directory

ark 'liferay-client' do
  release_url "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-client-6.1.0-ce-ga1-20120106155615760.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329490764&use_mirror=ignum"
  version "6.1.0"
  install_dir "/usr/local/share/tomcat/lib"
  home_dir "/usr/local/share/tomcat/lib"
  user "hitman"
  stop_file "portal-client.jar"
end



## License and Author

Author::                Philip (flip) Kromer - Infochimps, Inc (<coders@infochimps.com>)
Author::                Bryan W. Berry (<bryan.berry@gmail.com>)
Copyright::             2011, Philip (flip) Kromer - Infochimps, Inc
copyright::             2012, Bryan W. Berry

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
