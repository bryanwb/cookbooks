Description
===========

Installs and configures the Tomcat, Java servlet engine and webserver.

Requirements
============

Platform: 

* CentOS, Red Hat, Fedora (OpenJDK)

The following Opscode cookbooks are dependencies:

* java


Attributes
==========

* prefix_dir - /usr/local/, /var/lib/, etc.
* catalina_home - prefix_dir/tomcat${version}
* http_port
* https_port
* ajp_port
* shutdown_port


Recipes
==========

The ROOT and manager webapps are removed in both recipes.

default
-------

This recipe is for use with the tomcat_war and tomcat_webapp lwrps. It
creates an installation of tomcat to prefix_dir and adds an init
script to /etc/init.d/

By default it uses the tomcat 7 by including tomcat7 recipe

tomcat6, tomcat7
----------------

installs tomcat6 or tomcat7

tomcat6_base, tomcat7_base
--------------------------

These recipes are for use with the tomcat lwrp. This recipe only
installs those files that will be share among multiple tomcat instances.

Use the tomcat lwrp with this recipe

Resources/Providers
===================

tomcat

# Actions

- :install: 
- :remove:
- :update:


# Attribute Parameters

- http_port: port_num or true/false, default to true
- ajp_port:  port_num or true/false, default to true
- https_port: port_num or true/false, default to true
- shutdown_port: port_num or true/false, default to true
- host_name: name for Host element, defaults to localhost
- webapp_dir: defaults to webapps
- unpack_wars: defaults to true
- auto_deploy: defaults to true
- version: 6 or 7 
- webapps_url: url to tarball or to a single .war file. The tarball
  may hold multiple war files

tomcat_war

# Actions

- :install: 
- :remove:
- :update:


# Attribute Parameters

- version: 6 or 7
- url: url to a single .war file. .war file can be compressed
  as .tar, .tar.gz

# Examples

    tomcat "pentaho" do
      http_port  false
      https_port "8443"
      version    "7"
      webapps_url "http://download.example.com/pentaho_wars.tar.gz"
    end

    tomcat_war "foobar" do
      version   "6"
      url       "http://download.example.com/foobar_war.tar.gz"
    end

Usage
=====


TODO
====


License and Author
==================

Author:: Bryan W. Berry (<bryan.berry@gmail.com>)

Copyright:: 2012, Bryan W. Berry

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
