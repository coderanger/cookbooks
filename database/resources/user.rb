#
# Cookbook Name:: database
# Resource:: user
#
# Copyright:: 2008-2011, Opscode, Inc <legal@opscode.com>
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

include Chef::Resource::Database::OptionsCollector

actions :create, :drop, :grant

attribute :id, :name_attribute => true
attribute :username, :kind_of => String
attribute :database_cluster
attribute :database_server

def initialize(*args)
  super
  @action = [:create, :grant]
end

class GrantOptions
  include Chef::Resource::Database::OptionsCollector
  # Ruby built-in conflicts with a common SQL perm name, lets special case it
  def select(*args, &block)
    method_missing(:select, *args, &block)
  end
end

def grant(grant_hash=nil, &block)
  grant_options = options[:grant] ||= {}
  if block
    go = GrantOptions.new
    go.instance_eval(&block)
    grant_options.update(go.options)
  end
  grant_options.update(grant_hash) if grant_hash
  grant_options
end
