# ---------------------------------------------------------------------------------------------------------------------
# Launch Fortigate VM
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_network_interface" "port1_egress" {
  description = "${var.fw_instance_name}-port1-egress"
  subnet_id   = data.aws_subnet.egress_subnet.id

  tags = {
    Name = "${var.fw_instance_name}-port1-egress"
  }
}

resource "aws_network_interface" "port2_lan" {
  description       = "${var.fw_instance_name}-port2-lan"
  subnet_id         = data.aws_subnet.lan_subnet.id
  source_dest_check = false

  tags = {
    Name = "${var.fw_instance_name}-port2-lan"
  }
}

# Port1 Security Group
resource "aws_security_group" "port1_egress_sg" {
  name        = "${var.fw_instance_name}-port1-egress"
  description = "Allow any"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.fw_instance_name}-port1-egress"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

# Port2 Security Group
resource "aws_security_group" "port2_lan_sg" {
  name        = "${var.fw_instance_name}-port2-lan"
  description = "Allow any"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.fw_instance_name}-port2-lan"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_network_interface_sg_attachment" "egress_sg_attachment" {
  depends_on           = [aws_network_interface.port1_egress]
  security_group_id    = aws_security_group.port1_egress_sg.id
  network_interface_id = aws_network_interface.port1_egress.id
}

resource "aws_network_interface_sg_attachment" "lan_sg_attachment" {
  depends_on           = [aws_network_interface.port2_lan]
  security_group_id    = aws_security_group.port2_lan_sg.id
  network_interface_id = aws_network_interface.port2_lan.id
}

resource "aws_instance" "fortigate_instance" {
  ami               = var.license_type == "byol" ? var.fgt_byol_ami[data.aws_region.current.name] : var.fgt_payg_ami[data.aws_region.current.name]
  instance_type     = var.fw_instance_type
  availability_zone = "${data.aws_region.current.name}${var.az1}"
  key_name          = var.key_name
  user_data         = local.init_conf

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.port1_egress.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.port2_lan.id
    device_index         = 1
  }

  tags = {
    Name = "${var.fw_instance_name}"
  }
}

resource "aws_eip" "egress_eip" {
  depends_on        = [aws_instance.fortigate_instance]
  vpc               = true
  network_interface = aws_network_interface.port1_egress.id

  tags = {
    Name = "FortiGate-EIP@${var.fw_instance_name}"
  }
}

/* data "template_file" "FortiGate" {
  template = file("${var.bootstrap-fgtvm}")
  vars = {
    type         = "${var.license_type}"
    license_file = "${var.license}"
    adminsport   = "${var.adminsport}"
  } 
} */