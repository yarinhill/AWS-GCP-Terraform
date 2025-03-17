resource "aws_instance" "windows" {
  provider                    = aws.region-master
  ami                         = data.aws_ami.windowsAmi.id # Use the correct data source and attribute
  instance_type               = var.windows_instance_type
  vpc_security_group_ids      = [aws_security_group.windows-sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.windows-key.key_name 
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
      max_price          = "0.0119"
    }
  }
  tags = {
    Name = "${var.project_name}-windows"
  }
  user_data = <<EOF
<powershell>
# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
</powershell>
EOF

  depends_on = [aws_security_group.windows-sg]
}

resource "aws_security_group" "windows-sg" {
  provider    = aws.region-master
  name        = "${var.project_name}-windows-sg"
  description = "Allow RDP"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "Allow RDP from Your IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.your_public_ip
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-windows-sg"
  }
}

resource "tls_private_key" "windows-private-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "windows-key" {
  key_name   = "${var.project_name}-windows-key"
  public_key = tls_private_key.windows-private-key.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.windows-private-key.private_key_pem}' > ~/.ssh/id_rsa_${var.project_name}.pem"
  }
}

resource "local_file" "windows_rdp" {
  filename = "${path.module}/windows-instance.rdp"
  content  = <<EOF
full address:s:${aws_instance.windows.public_ip}
username:s:Administrator
EOF
}