#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: mysql
# Resource:: user
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
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

include Chef::Provider::Mysql::Base

action :validate do
  raise "Password required" unless @new_resource.password
  Chef::Log.debug("Pre-validate options #{@new_resource.options.inspect}")
  @new_resource.host ||= '%'
  @new_resource.credentials ||= {
    :user => 'root',
    :password => node['mysql']['server_root_password'],
  }
  Chef::Log.debug("Post-validate options #{@new_resource.options.inspect}")
end

action :create do
  unless exists? && node['roles'].include?(new_resource.database_cluster.master_role)
    begin
      db.query("CREATE USER '#{@new_resource.username}'@'#{@new_resource.host}' IDENTIFIED BY '#{@new_resource.password}'")
      @new_resource.updated_by_last_action(true)
    ensure
      close
    end
  end
end

action :drop do
  if exists? && node['roles'].include?(new_resource.database_cluster.master_role)
    begin
      db.query("DROP USER '#{@new_resource.username}'@'#{@new_resource.host}'")
      @new_resource.updated_by_last_action(true)
    ensure
      close
    end
  end
end

action :grant do
  unless node['roles'].include?(new_resource.database_cluster.master_role)
    begin
      @new_resource.grant.each do |priv, target|
        grant_statement = "GRANT #{priv} ON #{@new_resource.target || "*"} TO '#{@new_resource.username}'@'#{@new_resource.host}' IDENTIFIED BY '#{@new_resource.password}'"
        Chef::Log.info("#{@new_resource}: granting access with statement [#{grant_statement}]")
        db.query(grant_statement)
        @new_resource.updated_by_last_action(true)
      end
    ensure
      close
    end
  end
end

private
def exists?
  db.query("SELECT User,host from mysql.user WHERE User='#{@new_resource.username}' AND host = '#{@new_resource.host}'").num_rows != 0
end
