#
# Copyright 2019- joker1007
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

require "fluent/plugin/filter"
require "fluent/plugin/rdkafka_partitioner"

module Fluent
  module Plugin
    class RdkafkaPartitionerFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("rdkafka_partitioner", self)

      desc 'Specify field name of the record to calculate partition id'
      config_param :partition_key, :string

      desc 'Specify field name of the record to use as partition count'
      config_param :partition_count_key, :string, default: "partition_count"

      desc 'When set to true, remove partition_key field from output'
      config_param :remove_partition_key, :bool, default: false

      desc 'When set to true, remove partition_count_key field from output'
      config_param :remove_partition_count_key, :bool, default: false

      desc 'Specify field name of the record to use as partition count'
      config_param :default_partition_count, :integer, default: nil

      desc 'Specify partitioner algorithm'
      config_param :partitioner, :enum, list: [:consistent, :murmur2], default: :murmur2

      desc 'Specify output field name'
      config_param :add_key, :string, default: "partition"

      def filter(tag, time, record)
        key = @remove_partition_key ? record.delete(@partition_key) : record[@partition_key]
        partition_count = @remove_partition_count_key ? record.delete(@partition_count_key) : record[@partition_count_key]
        partition_count ||= @default_partition_count

        unless key
          raise "partition_key field is nil, ignore this record."
        end

        unless partition_count
          raise "partition_count is nil, ignore this record."
        end

        partition =
          case @partitioner
          when :murmur2
            RdKafkaPartitioner.murmur2_partitioner(key, partition_count)
          when :consistent
            RdKafkaPartitioner.consistent_partitioner(key, partition_count)
          else
            raise "unknown partitioner"
          end

        record[@add_key] = partition

        record
      end
    end
  end
end
