# aws-vpn

One-command WireGuard VPN on AWS EC2. Terraform provisions the instance, user_data configures WireGuard, client config is returned as an artifact via GitHub Actions or saved locally via script.

## How it works

1. Terraform creates an EC2 instance (t2.micro, eu-central-1), security group (UDP 51820), and IAM role with SSM access
2. User data script installs WireGuard, generates server/client keypairs, starts the tunnel, and pushes the client config to SSM Parameter Store as a SecureString
3. The client config is fetched from SSM and returned as a downloadable artifact (GitHub Actions) or saved to `wg0-client.conf` (local script)

## Usage

### Via GitHub Actions (recommended)

1. Fork or clone the repo
2. Set repository secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
3. Run **Deploy Infra** workflow manually — downloads `wg-config` artifact with the client config when done
4. Run **Destroy Infra** to tear everything down when you're done

### Local

Requirements: `terraform`, `aws` CLI (configured)

```bash
git clone git@github.com:Tsuyakashi/aws-vpn.git
cd aws-vpn
./scripts/quick-setup.sh   # deploy + fetch config
./scripts/destroy.sh       # tear down
```

### Connecting

**Linux / macOS**
```bash
sudo wg-quick up ./wg0-client.conf
```

**iOS / Android** — import the config file into the [WireGuard app](https://www.wireguard.com/install/)

## IAM permissions required

The AWS user needs EC2 read/write, IAM role management (scoped to `vpn-ssm-role-*`), and SSM GetParameter/DeleteParameter on `/vpn/*`. See the policy JSON in the repo wiki or set it up manually following the inline comments in `main.tf`.
