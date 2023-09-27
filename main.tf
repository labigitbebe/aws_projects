resource "aws_vpc" "main-net-vpc" {
  cidr_block           = "10.11.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "dev"
  }
}

resource "aws_subnet" "main-vpc-public-subnet" {
  vpc_id                  = aws_vpc.main-net-vpc.id
  cidr_block              = "10.11.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"

  tags = {
    name = "dev-public"
  }

}

resource "aws_internet_gateway" "main-net-igw" {
  vpc_id = aws_vpc.main-net-vpc.id

  tags = {
    name = "dev-igw"
  }
}

resource "aws_route_table" "main-net-rt" {
  vpc_id = aws_vpc.main-net-vpc.id

  tags = {
    name = "dev-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.main-net-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-net-igw.id
}

resource "aws_route_table_association" "main-net-rt-assocation" {
  subnet_id      = aws_subnet.main-vpc-public-subnet.id
  route_table_id = aws_route_table.main-net-rt.id
}

resource "aws_security_group" "main-net-sg" {
  name        = "dev-sg"
  description = "dev security group"
  vpc_id      = aws_vpc.main-net-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
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

  tags = {
    Name = "allow_tls-ssh"
  }

}

resource "aws_key_pair" "main-ssh_key" {
  key_name   = "dev-ssh-key"
  public_key = file("~/.ssh/sshkey.pub")

}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu22_ami.id
  key_name               = aws_key_pair.main-ssh_key.id
  vpc_security_group_ids = [aws_security_group.main-net-sg.id]
  subnet_id              = aws_subnet.main-vpc-public-subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    name = "dev-node"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/sshkey"

    })
    interpreter = var.host_os == "Windows" ? ["Powershell", "Command" ] :["bash", "-c"]
  }
}
