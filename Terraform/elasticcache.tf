resource "aws_elasticache_subnet_group" "redissubnetgroup" {
  name        = "redisgroup"
  subnet_ids = [aws_subnet.private1.id,aws_subnet.private2.id]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "app-redis "
  engine               = "redis"
  engine_version       = "3.2.10"
  node_type            = "cache.m4.large"
  num_cache_nodes      = "1"
  parameter_group_name = "default.redis3.2"
  port                 = "6379"
  subnet_group_name    = aws_elasticache_subnet_group.redissubnetgroup.name
}