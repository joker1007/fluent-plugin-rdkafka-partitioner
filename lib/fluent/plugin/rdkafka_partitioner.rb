require 'ffi'

module Fluent::Plugin::RdKafkaPartitioner
  extend FFI::Library

  ffi_lib "librdkafka"
  attach_function :rd_kafka_msg_partitioner_consistent, [:pointer, :pointer, :long, :int, :pointer, :pointer], :int
  attach_function :rd_kafka_msg_partitioner_murmur2, [:pointer, :pointer, :long, :int, :pointer, :pointer], :int

  def self.consistent_partitioner(key, partition_count)
    result = nil
    FFI::MemoryPointer.new(:int, 0) do |dummy|
      result = rd_kafka_msg_partitioner_consistent(dummy, key, key.bytesize, partition_count, dummy, dummy)
    end
    result
  end

  def self.murmur2_partitioner(key, partition_count)
    result = nil
    FFI::MemoryPointer.new(:int, 0) do |dummy|
      result = rd_kafka_msg_partitioner_murmur2(dummy, key, key.bytesize, partition_count, dummy, dummy)
    end
    result
  end
end
