# aws-vpn
## Descriptions (Что это такое)
Запуская quickstart.sh по необходимости создаются rsa ключи, с помощью terraform создается простая инфраструктура из ЕС2, групп безопасности и ключа (по которому можно подключится через ssh), затем с помощью ansible скачивается и настраивается сервер wireguard, возвращается конфиг для использования клиентом
## Usage
- clone repo
- run quickstart script
- take client conf
## Needs:
- terraform
- aws cli (logged)
- ansible core
## To-do list:
- rewrite creating keys with [hashicorp/tls](https://dev.to/bansikah/deploying-an-aws-ec2-instance-with-terraform-and-ssh-access-d09#:~:text=your%20local%20machine:-,Terraform,key%20parameters%20for%20the%20deployment)
- rewrite .tf as modules
