Overview        
========

An '''ark''' is like an archive but '''Kewler''

Does the fetch-unpack-configure-build-install dance. This is a
modified  verion of Infochimps awesome install_from cookbook
 [http://github.com/infochimps-cookbooks/install_from](http://github.com/infochimps-cookbooks/install_from)

Given a project `pig`, with url `http://apache.org/pig/pig-0.8.0.tar.gz`, and
the default :prefix of `/usr/local`, this provider will

* fetch  it to to `/usr/local/src`
* unpack it to :install_dir  (`/usr/local/pig-0.8.0`)
* create a symlink for :home_dir (`/usr/local/pig`) pointing to :install_dir
* configure the project
* build the project
* install the project


Resources/Providers
===================

# Actions

- :install: extracts the file and makes a symlink of requested
- :remove: removes the extracted directory and related symlink

# Attribute Parameters

- url: url for tarball, .tar.gz, .bin (oracle-specific), .war, and .zip
  currently supported. Also supports special syntax
  :name:version:apache_mirror: that will auto-magically construct
  download url from the apache mirrors site
- version: software version, required
- checksum: sha256 checksum, used for security 
- prefix: prefix for installation, defaults to /usr/local/
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
        url 'http://someurl.example.com/ivy.tar.gz'
        version '2.2.0'        
    end


## License and Author

Author::                Philip (flip) Kromer - Infochimps, Inc (<coders@infochimps.com>)
Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
Copyright::             2011, Philip (flip) Kromer - Infochimps, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
