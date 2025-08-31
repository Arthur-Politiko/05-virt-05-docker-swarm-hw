# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1gguv60gg3mvfac0ql6"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gmp7i07ne1k03in65s"
}

# resource "yandex_compute_disk" "boot-disk" {
#   name     = "<имя_диска>"
#   type     = "<тип_диска>"
#   zone     = "<зона_доступности>"
#   size     = "<размер_диска>"
#   image_id = "<идентификатор_пользовательского_образа>"
# }

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "ubuntu_2204_lts" {
  #default = "fd8ljvsrm3l1q2tgqji9"
  default = "fd82abdnih25lkaasna1"
}

variable "key_path" {
  default = "~/.ssh/id_ed25519.pub"
}
