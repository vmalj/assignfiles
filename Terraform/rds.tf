resource "aws_db_subnet_group" "rds-subnet" {
  name = "rds-subnet"
  subnet_ids = [aws_subnet.private1.id,aws_subnet.private2.id]
}

resource "aws_security_group" "rdssg" {
  name        = "rds-sg"
  vpc_id      = aws_vpc.trimble_main.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.webtier.id]
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage           = 10
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t2.micro"
  name                        = "dbmysql"
  username                    = "sqladmin"
  password                    = "sqladmin123"
  db_subnet_group_name        = aws_db_subnet_group.rds-subnet.name
  vpc_security_group_ids      = aws_security_group.rdssg.id
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = 35
  multi_az                    = true
  skip_final_snapshot         = true
}