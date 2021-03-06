
# ELB SG
resource "aws_security_group" "elbsg" {
  name        = "elb-sg"
  vpc_id      = aws_vpc.trimble_main.id
  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 80 from anywhere for redirection"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
  security_groups = [aws_security_group.webtier.id]
  }
}

# Security group for Web
resource "aws_security_group" "webtier" {
  name        = "webtier"
  vpc_id      = aws_vpc.trimble_main.id
  
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [aws_security_group.elbsg.id]
  }  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["On-Premise Private Network"]
  }
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.rdssg.id]
  }
}