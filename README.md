# AWS-WireGuard-VPN
## Descriptions (Что это такое)
### Инфроструктура для персонального vpn сервера на базе aws ec2 
Запуская `quickstart.sh` по необходимости создаются rsa ключи, с помощью Terraform создается инфраструктура из ЕС2, групп безопасности и ключа (по которому можно подключится через ssh), затем с помощью Ansible скачивается и настраивается сервер WireGuard, возвращается конфиг для использования клиентом
## Usage
### 1. Clone repo
  ```bash
  git clone git@github.com:Tsuyakashi/aws-vpn.git
  ```
### 2. Run quickstart script
  ```bash
  cd aws-vpn && ./quickstart
  ```
### 3. Take client conf:
- For ubuntu 
    ```bash
    sudo apt install wireguard -y
    ```
    - `cp`/`mv` `client.conf` to `/var/wireguard/` as `wg0.conf`
    - Run:
    ```bash
    sudo wg-quick up wg0
    ```
- For IPhone
    - Get [WireGuard at App Store](https://apps.apple.com/ru/app/wireguard/id1441195209)
    - Import conf in app
## Needs:
- Terraform
- AWS cli (logged)
- Ansible core
## May be needed:
### Yandex mirror
Using:
```bash
nano ~/.terraformrc
```
Add/replace:
```bash
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```
## To-do list:
- Add building from tg bot request
- Rewrite creating keys with [hashicorp/tls](https://dev.to/bansikah/deploying-an-aws-ec2-instance-with-terraform-and-ssh-access-d09#:~:text=your%20local%20machine:-,Terraform,key%20parameters%20for%20the%20deployment)
- Rewrite .tf as modules
