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

def initialize(*args)
  super
  @action = :create
  @sub_resources = {}
end

actions :create

attribute :id, :kind_of => String, :name_attribute => true
attribute :type, :kind_of => String
attribute :cluster
attr_reader :sub_resources

def method_missing(name, resource_id, &block)
  resource = @sub_resources[[name, resource_id]]
  if !resource
    resource = super("#{type}_#{name}", "#{id}::#{name}::#{resource_id}", &block)
    # Make this a weakref to prevent a cycle between this resource and the sub resources
    resource.cluster WeakRef.new(cluster)
    resource.server WeakRef.new(self)
    @sub_resources[[name, resource_id]] = resource
  end
  resource
end
