# aws-vpn

One-command VLESS+Reality proxy on AWS EC2. Terraform provisions the instance, user_data installs Xray-core and configures the Reality inbound, the client link is returned as an artifact via GitHub Actions or saved locally via script.

## Why Xray-core + Reality

- No owned domain or certificate needed — Reality borrows the real TLS handshake of a legitimate site (e.g. `www.microsoft.com`) as camouflage, so DPI sees a valid TLS session to a real server instead of a suspicious VPN endpoint.
- Runs over plain TCP on port 443, indistinguishable from ordinary HTTPS traffic on the wire.
- Currently the most resistant option to active DPI probing.
- Clients on every platform: v2rayN / v2rayNG / NekoRay / Xray, all with QR-code import for mobile.

## How it works

1. Terraform creates an EC2 instance (t2.micro, eu-central-1 by default), a security group (TCP 443), and an IAM role with SSM access.
2. User data installs the latest Xray-core release, generates a UUID, an X25519 keypair, and a short ID, then writes `/usr/local/etc/xray/config.json` with a VLESS+Reality inbound and starts it as a systemd service.
3. The client link (`vless://...`) is pushed to SSM Parameter Store as a SecureString, then fetched and returned as a downloadable artifact (GitHub Actions, alongside a QR PNG) or saved to `xray-client.txt` (local script).

## Usage

### Via GitHub Actions (recommended)

1. Fork or clone the repo
2. Set repository secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
3. Run **Deploy Infra** workflow manually — downloads `xray-config` artifact containing `xray-client.txt` (the link) and `xray-client.png` (QR code) when done
4. Run **Destroy Infra** to tear everything down when you're done

### Local

Requirements: `terraform`, `aws` CLI (configured)

```bash
git clone git@github.com:Tsuyakashi/aws-vpn.git
cd aws-vpn
./scripts/quick-setup.sh   # deploy + fetch link, prints a QR if qrencode is installed
./scripts/destroy.sh       # tear down
```

### Connecting

Copy the `vless://...` link from `xray-client.txt` (or scan the QR) and import it into:

- **v2rayN / v2rayNG** (Windows / Android) — "Import from clipboard"
- **NekoRay** (Windows / Linux / macOS) — "Add profile from clipboard"
- **Xray / Xray-knife** — any client with native VLESS+Reality support

No client-side config file editing is needed — the link carries the UUID, Reality public key, short ID, and SNI.

## Configuration

| Variable        | Default              | Notes                                                                 |
|-----------------|-----------------------|------------------------------------------------------------------------|
| `xray_port`     | `443`                 | Keep on 443 to blend with normal HTTPS traffic.                       |
| `reality_dest`  | `www.microsoft.com`   | Masquerade target. Must serve TLS 1.3 + HTTP/2 and sit behind no CDN. |
| `client_name`   | `user-cfg`            | Label embedded in the client link.                                   |
| `instance_type` | `t2.micro`            |                                                                        |
| `region`        | `eu-central-1`        |                                                                        |

If you change `reality_dest`, verify the candidate domain still qualifies (TLS 1.3, HTTP/2, no CDN/redirect, `serverName` reachable directly) before deploying — a bad choice will make the handshake fail or look suspicious to DPI.

## IAM permissions required

The AWS user needs EC2 read/write, IAM role management (scoped to `vpn-ssm-role-*`), and SSM PutParameter/GetParameter/DeleteParameter on `/vpn/*`. See the policy JSON in the repo wiki or set it up manually following the inline comments in `main.tf`.

## Migrating from the WireGuard version

This replaces the previous WireGuard-based setup. If you have an old deployment running, destroy it first (`./scripts/destroy.sh` or the **Destroy Infra** workflow) before applying this version — the security group and instance resources changed shape (UDP random port → TCP 443) and Terraform will otherwise want to replace them anyway.
