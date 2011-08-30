#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: database
# Resource:: server
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

require 'weakref'

include Chef::Mixin::RecipeDefinitionDSLCore
alias :original_method_missing :method_missing
include Chef::Resource::Database::OptionsCollector

def initialize(*args)
  super
  @action = :create
  @databases = []
  @users = []
end

actions :create

attribute :id, :kind_of => String, :name_attribute => true
attribute :type, :kind_of => String
attribute :cluster
attr_reader :databases, :users

def database(name, options=nil, &block)
  sub_resource(:database, name, options, &block)
end

def user(name, options=nil, &block)
  sub_resource(:user, name, options, &block)
end

private
def sub_resource(resource_type, resource_id, resource_options, &block)
  collection = {:database => @databases, :user => @users}[resource_type]
  resource = collection.select{|res|res.id==resource_id}.first
  if !resource
    resource = original_method_missing("database_#{resource_type}", "#{id}::#{resource_type}::#{resource_id}") do end
    # Make this a weakref to prevent a cycle between this resource and the sub resources
    resource.options.update resource_options if resource_options
    resource.cluster WeakRef.new(cluster)
    resource.server WeakRef.new(self)
    resource.provider "#{type}_#{resource_type}"
    collection << resource
    resource.instance_eval(&block) if block
  end
  resource
end
