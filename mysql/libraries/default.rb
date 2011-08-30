#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: mysql
# Library:: default
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

class Chef
  class Provider
    class Mysql
      module Base

        def db
          @db ||= begin
            Gem.clear_paths
            require 'mysql'
            credentials = @new_resource.options[:credentials] || {}
            ::Mysql.new(
              'localhost',
              credentials[:username],
              credentials[:password],
              nil,
              @new_resource.database_server.options[:port] || 3306
            )
          end
        end

        def close
          @db.close rescue nil
          @db = nil
        end

      end
    end
  end
end
