#
# Cookbook Name::       jira
# Description::         installs jira
# Attributes::          default
# Author::              Bryan W. Berry
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

default['jira']['user'] = "jira"
default['jira']['jvm_opts'] = [
                               "-Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true",
                               "-Dmail.mime.decodeparameters=true",
                               "-Xms128m", "-Xmx512m", "-XX:MaxPermSize=256m"
                              ]

default['jira']['war_url'] = "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-5.0-war.tar.gz"
default['jira']['war_checksum'] = "231f05a72fdcd2889376b1af442f37d0e284e7fd2619b4d876c5036a966aa07b"
default['jira']['jars_url'] = "http://www.atlassian.com/software/jira/downloads/binary/jira-jars-tomcat-distribution-4.4-tomcat-6x.zip"
default['jira']['jars_checksum'] = "ff93d08d4ec91347730dc641662020f904c6eef3e57cb5d4c7c34159e2422fd7"
default['jira']['balsamiq_url'] = 'http://builds.balsamiq.com/b/2.1/mockups-jira-4x/mockupsJIRA4x-2.1.13.jar'
default['jira']['balsamiq_checksum'] = "46f368c82069a400eb2bdaaaa24e1480fa816cda47a6534a398f9c5ac4c606da"

default['jira']['jdbc']['username'] = "jira"
default['jira']['jdbc']['type'] = "mysql"
default['jira']['jdbc']['driver'] = "com.mysql.jdbc.Driver"
default['jira']['jdbc']['server'] = "db.example.com"
default['jira']['jdbc']['port'] = "3330"
default['jira']['jdbc']['schema'] = "jira"
default['jira']['jdbc']['params'] = [ "useUnicode=true", "characterEncoding=UTF8", "sessionVariables=storage_engine=InnoDB" ]
