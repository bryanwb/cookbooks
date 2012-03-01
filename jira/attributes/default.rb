#
# Cookbook Name::       jira
# Description::         installs jira
# Attributes::              default
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
default['jira']['war_url'] = "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-5.0-war.zip"
default['jira']['jars_url'] = "http://www.atlassian.com/software/jira/downloads/binary/jira-jars-tomcat-distribution-4.4-tomcat-6x.zip"
default['jira']['balsamiq_url'] = 'http://builds.balsamiq.com/b/2.1/mockups-jira-4x/mockupsJIRA4x-2.1.13.jar'
