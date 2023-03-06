resource "aws_security_group" "service" {
  name   = local.project_name
  vpc_id = aws_vpc.main.id

  ingress {
    from_port        = local.container_port
    to_port          = local.container_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}