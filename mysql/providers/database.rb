#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: mysql
# Provider:: database
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
  @new_resource.credentials ||= {
    :user => 'root',
    :password => node['mysql']['server_root_password'],
  }
end

action :create do
  unless exists?
    begin
      Chef::Log.debug("#{@new_resource}: Creating database #{new_resource.name}")
      db.query("create database #{new_resource.name}")
      @new_resource.updated_by_last_action(true)
    ensure
      close
    end
  end
end

action :drop do
  if exists?
    begin
      Chef::Log.debug("#{@new_resource}: Dropping database #{new_resource.name}")
      db.query("drop database #{new_resource.name}")
      @new_resource.updated_by_last_action(true)
    ensure
      close
    end
  end
end

action :query do
  if exists?
    begin
      db.select_db(@new_resource.name) if @new_resource.name
      Chef::Log.debug("#{@new_resource}: Performing query [#{new_resource.sql}]")
      db.query(@new_resource.sql)
      @new_resource.updated_by_last_action(true)
    ensure
      close
    end
  end
end

private
def exists?
  db.list_dbs.include?(@new_resource.name)
end
