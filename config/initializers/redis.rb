# TODO We may want to allow this to be configured through VERY advanced system
# configuration options.
$raw_redis = Redis.new(host: 'localhost', port: 6379)

# We want any Redis key access to be properly namespaced by the application
# name, in case we're running multiple apps on the server that access the
# same Redis instance. In addition to that, we include the name of the
# current environment as part of the key prefix, so that doing work under
# development/staging instances does not pollute the production keyspace.
$redis = Redis::Namespace.new("pythy:#{Rails.env}", redis: $raw_redis)
