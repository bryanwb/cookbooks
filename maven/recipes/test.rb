
maven "mysql-connector-java" do
  groupId "mysql"
  version "5.1.18"
  dest "/usr/local/foo"
end

maven "cas-client-core" do
  groupId "org.jasig.cas.client"
  version "3.2.1"
  dest "/usr/local/foo"
end

maven "cas integration for jira" do
  artifactId "cas-client-integration-atlassian"
  groupId "org.jasig.cas.client"
  version "3.2.1"
  dest "/usr/local/foo"

  owner "hitman"
end

