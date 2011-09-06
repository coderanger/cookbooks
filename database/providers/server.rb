#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: database
# Provider:: server
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

action :create do
  if new_resource.database_cluster.is_master?
    (new_resource.users + new_resource.databases).each do |res|
      res.run_action(:validate)
      actions = res.original_action
      actions = [actions] unless actions.is_a? Enumerable
      actions.each do |action|
        res.run_action(action)
      end
    end
  end
end
