Description
===========

Installs a Java. Uses OpenJDK by default but supports installation of the Oracle's Java.

---
Requirements
============

Platform
--------

* Debian, Ubuntu
* CentOS, Red Hat, Fedora

Cookbooks
---------

* java

---
Attributes
==========

* `node["java"]["install_flavor"]` - Flavor of JVM you would like installed (`oracle` or `openjdk`), default `openjdk`.
* `node['java']['java_home']`
* `node['java']['tarball']` - name of the tarball to retrieve from your corporate repository default `jdk1.6.0_29_i386.tar.gz`
* `node['java']['tarball_checksum']` - checksum for the tarball, if you use a different tarball, you also need to create a new sha256 checksum


---
Recipes
=======

default
-------

Include the default recipe in a run list, to get `java`.  By default the `openjdk` flavor of Java is installed, but this can be changed by using the `install_flavor` attribute.

openjdk
-------

This recipe installs the `openjdk` flavor of Java.

oracle
---

This recipe installs the `oracle` flavor of Java. This recipe does not
use distribution packages as Oracle changed the licensing terms with
JDK 1.6u27 and prohibited the practice for both the debian and EL worlds.

For both debian and centos/rhel, this recipe pulls the binary
distribution from the Oracle website, and installs it in the default
JAVA_HOME for each distribution. For debian/ubuntu, this is
/usr/lib/jvm. For Centos/RHEL, this is /usr/java/

After putting the binaries in place, the oracle recipe updates
/usr/bin/java to point to the installed JDK using the update-alternatives script

oracle-i386
-----------

This recipe installs the 32-bit Java virtual machine without setting it as the default. This can be useful if you have applications on the same machine that require different versions of the JVM.

This recipe will look for the tarball at node['repo']['corp']['url']

---
Usage
=====

Simply include the `java` recipe where ever you would like Java installed.  

To install Oracle flavored Java on Debian or Ubuntu override the `node['java']['install_flavor']` attribute with in role:

    name "java"
    description "Install Oracle Java on Ubuntu"
    override_attributes(
      "java" => {
        "install_flavor" => "oracle"
      }
    )
    run_list(
      "recipe[java]"
    )

On RedHat flavored Linux be sure to set the `rpm_url` and `rpm_checksum` attributes if you placed the `rpm` file on a remote server:

    name "java"
    description "Install Oracle Java on CentOS"
    override_attributes(
      "java" => {
        "install_flavor" => "oracle",
        "version" => "6u25",
        "rpm_url" => "https://mycompany.s3.amazonaws.com/oracle_jdk",
        "rpm_checksum" => "c473e3026f991e617710bad98f926435959303fe084a5a31140ad5ad75d7bf13"
      }
    )
    run_list(
      "recipe[java]"
    )

License and Author
==================

Author:: Seth Chisamore (<schisamo@opscode.com>)
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
