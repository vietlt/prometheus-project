data "aws_subnet" "public_subnet" {
  count = 2
  filter {
    name   = "tag:Name"
    values = ["public_subnet_${count.index}"]
  }
}

data "aws_security_group" "nodes_sg" {
  filter {
    name   = "tag:Name"
    values = ["nodes_sg"]
  }
}
