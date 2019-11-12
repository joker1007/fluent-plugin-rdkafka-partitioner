# fluent-plugin-rdkafka-partitioner

[Fluentd](https://fluentd.org/) filter plugin to add partition id to record by rdkafka gem algorithm

## Installation

### RubyGems

```
$ gem install fluent-plugin-rdkafka-partitioner
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-rdkafka-partitioner"
```

And then execute:

```
$ bundle
```

## Configuration

```
<filter filter.tag>
  @type rdkafka_partitioner

  partition_key id
  partitioner murmur2
  default_partition_count 16
</filter>
```

See also: [Filter Plugin Overview](https://docs.fluentd.org/v/1.0/filter#overview)

### partition_key (string) (required)

Specify field name of the record to calculate partition id

### partition_count_key (string) (optional)

Specify field name of the record to use as partition count

Default value: `partition_count`.

### remove_partition_key (bool) (optional)

When set to true, remove partition_key field from output

### remove_partition_count_key (bool) (optional)

When set to true, remove partition_count_key field from output

### default_partition_count (integer) (optional)

Specify field name of the record to use as partition count

### partitioner (enum) (optional)

Specify partitioner algorithm

Available values: consistent, murmur2

Default value: `murmur2`.

### add_key (string) (optional)

Specify output field name

Default value: `partition`.



## Copyright

* Copyright(c) 2019- joker1007
* License
  * Apache License, Version 2.0
