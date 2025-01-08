#Get Linux AMI ID using SSM Parameter
data "aws_ssm_parameter" "linuxsample-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "linuxsample_profile" {
  name = "linuxsamples_profile"
  role = aws_iam_role.role.name
}

#Create and bootstrap linuxsample
resource "aws_iam_role" "role" {
  name = "linuxsamples_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# Attach the AmazonEC2RoleforSSM policy
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# Attach the AmazonS3FullAccess policy
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_instance" "linuxsample" {
  ami                         = data.aws_ssm_parameter.linuxsample-ami.value
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.private_subnets[0].id
  iam_instance_profile        = aws_iam_instance_profile.linuxsample_profile.name

  user_data = <<EOF
#!/bin/bash
# Update the instance
sudo yum update -y

# Install Apache Web Server
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Install MySQL
sudo yum install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Install PHP
sudo yum install -y php php-mysqlnd
sudo systemctl restart httpd

# Create a sample PHP file
cat <<PHP > /var/www/html/index.php
<?php
phpinfo();
?>
PHP
EOF

  tags = {
    Name = "Linux-${var.environment_name}"
  }
}

output "private_ip_address" {
  value = aws_instance.linuxsample.private_ip
}

#Create SG for allowing TCP/80 & TCP/22
resource "aws_security_group" "sg" {
  name        = "SG-Linux-${var.environment_name}"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow traffic on TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow traffic on TCP/443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
