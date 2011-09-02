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
  @new_resource.host ||= '%'
  @new_resource.credentials ||= {
    :user => 'root',
    :password => node['mysql']['server_root_password'],
  }
end

action :create do
  unless exists?
    begin
      create_statement = "CREATE USER '#{::Mysql.quote(@new_resource.username)}'@'#{::Mysql.quote(@new_resource.host)}'"
      create_statement += " IDENTIFIED BY '#{::Mysql.quote(@new_resource.password)}'" if @new_resource.password
      db.query(create_statement)
      @new_resource.updated_by_last_action(true)
    ensure
      close
    end
  end
end

action :drop do
  if exists?
    begin
      db.query("DROP USER '#{::Mysql.quote(@new_resource.username)}'@'#{::Mysql.quote(@new_resource.host)}'")
      @new_resource.updated_by_last_action(true)
    ensure
      close
    end
  end
end

action :grant do
  begin
    @new_resource.grant.each do |priv, target|
      target ||= '*.*'
      target += '.*' unless target.include?('.')
      grant_statement = "GRANT #{priv} ON #{target} TO '#{::Mysql.quote(@new_resource.username)}'@'#{::Mysql.quote(@new_resource.host)}'"
      grant_statement += " IDENTIFIED BY '#{::Mysql.quote(@new_resource.password)}'" if @new_resource.password
      Chef::Log.info("#{@new_resource}: granting access with statement [#{grant_statement}]")
      db.query(grant_statement)
      @new_resource.updated_by_last_action(true)
    end
  ensure
    close
  end
end

private
def exists?
  db.query("SELECT User,host from mysql.user WHERE User='#{::Mysql.quote(@new_resource.username)}' AND host = '#{::Mysql.quote(@new_resource.host)}'").num_rows != 0
end
