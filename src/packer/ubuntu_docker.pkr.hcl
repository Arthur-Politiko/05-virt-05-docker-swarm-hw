# Yandex Cloud Toolbox VM Image based on Ubuntu 20.04 LTS
#
# Provisioner docs:
# https://www.packer.io/docs/builders/yandex
#

variable "YC_CLOUD_ID" {
  type = string
  default = env("YC_CLOUD_ID")
}

variable "YC_FOLDER_ID" {
  type = string
  default = env("YC_FOLDER_ID")
}

variable "YC_ZONE" {
  type = string
  default = env("YC_ZONE")
}

variable "YC_SUBNET_ID" {
  type = string
  default = env("YC_SUBNET_ID")
}

variable "SSH_KEY_PATH" {
  type = string
  default = env("SSH_KEY_PATH")
}


source "yandex" "ubuntu-docker" {
  folder_id           = var.YC_FOLDER_ID
  token               = "y0__xC5_7sIGMHdEyCN8_GFFHqeFTeV7gf6WTtJMeMV-5Czd0PD"
  source_image_family = "ubuntu-2004-lts"
  ssh_username        = "ubuntu"
  #ssh_agent_auth      = true
  #ssh_private_key_file = var.SSH_KEY_PATH
  use_ipv4_nat        = true
  image_description   = "Yandex Cloud Ubuntu Toolbox image with Docker"
  image_family        = "netology-images"
  image_name          = "ubuntu-docker"
  subnet_id           = var.YC_SUBNET_ID
  disk_type           = "network-hdd"
  zone                = var.YC_ZONE
}

build {
  sources = ["source.yandex.ubuntu-docker"]

  provisioner "shell" {
    inline = [
      # Global Ubuntu things
      "sudo apt-get update",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get install -y unzip python3-pip python3.8-venv",

      # Yandex Cloud CLI tool
      "curl --silent --remote-name https://storage.yandexcloud.net/yandexcloud-yc/install.sh",
      "chmod u+x install.sh",
      "sudo ./install.sh -a -i /usr/local/ 2>/dev/null",
      "rm -rf install.sh",
      "sudo sed -i '$ a source /usr/local/completion.bash.inc' /etc/profile",
  
      # Docker
      "curl --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce containerd.io",
      "sudo usermod -aG docker $USER",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo useradd -m -s /bin/bash -G docker yc-user",

      # Test - Check versions for installed components
      "echo '=== Tests Start ==='",
      "yc version",
      "docker version",
      "echo '=== Tests End ==='"
    ]
  }
}