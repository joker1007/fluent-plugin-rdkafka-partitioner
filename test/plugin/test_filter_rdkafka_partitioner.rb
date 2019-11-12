require "helper"
require "fluent/plugin/filter_rdkafka_partitioner.rb"

class RdkafkaPartitionerFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    @time = Fluent::EventTime.now
  end

  test "murmur2 partition" do
    d = create_driver(<<~CONF)
      partition_key key
      default_partition_count 100
      partitioner murmur2
    CONF

    d.run do
      d.feed("filter.test", @time, {"key" => "hoge"})
      d.feed("filter.test", @time, {"key" => "hoge", "partition_count" => 8})
      d.feed("filter.test", @time, {"key" => "fuga"})
      d.feed("filter.test", @time, {"key" => "fuga", "partition_count" => 8})
    end

    output0 = d.filtered_records[0]
    output1 = d.filtered_records[1]
    output2 = d.filtered_records[2]
    output3 = d.filtered_records[3]

    assert { output0["partition"] == 72 }
    assert { output1["partition"] == 0 }
    assert { output2["partition"] == 37 }
    assert { output3["partition"] == 5 }
  end

  test "consistent partition" do
    d = create_driver(<<~CONF)
      partition_key key
      default_partition_count 100
      partitioner consistent
    CONF

    d.run do
      d.feed("filter.test", @time, {"key" => "hoge"})
      d.feed("filter.test", @time, {"key" => "hoge", "partition_count" => 8})
      d.feed("filter.test", @time, {"key" => "fuga"})
      d.feed("filter.test", @time, {"key" => "fuga", "partition_count" => 8})
    end

    output0 = d.filtered_records[0]
    output1 = d.filtered_records[1]
    output2 = d.filtered_records[2]
    output3 = d.filtered_records[3]

    assert { output0["partition"] == 34 }
    assert { output1["partition"] == 2 }
    assert { output2["partition"] == 30 }
    assert { output3["partition"] == 6 }
  end

  test "remove keys" do
    d = create_driver(<<~CONF)
      partition_key key
      default_partition_count 100
      partitioner murmur2
      remove_partition_key
      remove_partition_count_key
    CONF

    d.run do
      d.feed("filter.test", @time, {"key" => "hoge"})
      d.feed("filter.test", @time, {"key" => "hoge", "partition_count" => 8})
    end

    output0 = d.filtered_records[0]
    output1 = d.filtered_records[1]

    assert { output0.keys == ["partition"] }
    assert { output1.keys == ["partition"] }
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::RdkafkaPartitionerFilter).configure(conf)
  end
end
