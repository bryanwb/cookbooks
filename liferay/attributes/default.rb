#
# Cookbook Name:: liferay
# Attributes:: default
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
#
# Copyright 2012, Bryan W. Berry
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['liferay']['user'] = "liferay"
# each hash is name + url
default['liferay']['extra_jars'] = [
                                    {
                                      "jta.jar" => "http://download.java.net/maven/2/javax/transaction/jta/1.0.1B/jta-1.0.1B.jar",
                                      "persistence.jar" => "http://search.maven.org/remotecontent?filepath=org/pojava/persistence/2.8.0/persistence-2.8.0.jar",
                                      "jms.jar" => "http://search.maven.org/remotecontent?filepath=com/sun/messaging/mq/jms/4.4/jms-4.4.jar",
                                      "mysql.jar" => " http://gd.tuwien.ac.at/db/mysql/Downloads/Connector-J/mysql-connector-java-5.0.8.tar.gz"

                                    }
                                   ]
