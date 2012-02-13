Description
===========

An '''ark''' is like an archive but '''Kewler''

This cookbook provides an LWRP for installing applications from a
compressed file. It will make other changes to a system to make the
application available to other applications.

This is not intended for applications that require any compilation or
build stage. For that purpose, see the tar resource from Nathan Smith https://github.com/cramerdev/cookbooks/tree/master/tar

Resources/Providers
===================

# Actions

- :install: extracts the file and makes a symlink of requested
- :remove: removes the extracted directory and any related symlink

# Attribute Parameters

- url: path to tarball, .tar.gz, .bin (oracle-specific), and .zip
  currently supported
- checksum: sha256 checksum, used for security 
- prefix: 
- mode: file mode for app_home, is an integer
- append_path: boolean or an array. Defaults to true
  - If true, append the ./bin directory of the extracted directory to
  the PATH environment  variable for all users, does this by placing a file in /etc/profile.d/ which will be read by all users
  - If an array, assumes the members of the array are commands in extracted_directory/bin to
  be added to the path. The commands are symbolically linked to
  /usr/bin/* . Examples are mvn, java, javac, etc. This option
  provides more granularity than the boolean option
- friendly_name: String, creates a symlink in '''prefix''' directory
  that points to the extracted directory, use with care
- owner: owner of extracted directory, set to "root" by default

# Examples

    # installs maven2
    ark "maven2" do
        url "http://www.apache.org/dist/maven/binaries/apache-maven-2.2.1-bin.tar.gz"
        prefix "/usr/local"
        append_path true
    end

    # install jdk6 from Oracle
    ark "jdk" do
        url 'http://download.oracle.com/otn-pub/java/jdk/6u29-b11/jdk-6u29-linux-x64.bin'
        checksum  'a8603fa62045ce2164b26f7c04859cd548ffe0e33bfc979d9fa73df42e3b3365'
        prefix '/usr/local/jvm'
        friendly_name "default"
        bin_cmds ["java", "javac"]
        action :install
    end


License and Author
==================


Author:: Bryan W. Berry (<bryan.berry@gmail.com>)

Copyright:: 2008-2011, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
