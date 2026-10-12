# Azure Landing Zone for Students

English / 日本語

This repository provisions a small Azure landing zone for student or lab environments using Terraform. It is organized into separate modules for network, compute, data services, and bastion access.

このリポジトリは、Terraform を使って学生向けまたはラボ環境用の小規模な Azure Landing Zone を構築します。ネットワーク、計算、データサービス、Bastion アクセスを分離したモジュール構成で管理しています。

## 1. Project overview / プロジェクト概要

The solution creates a secure network topology with:
- a hub VNet in East US 2
- private endpoints for PostgreSQL and Blob Storage
- a Linux app service with VNet integration in Central US
- a Linux worker VM placed in the hub subnet
- Azure Bastion for inbound administrative access

ソリューションは以下を含む安全なネットワーク構成を作成します。
- East US 2 に配置されたハブ VNet
- PostgreSQL と Blob Storage の Private Endpoint
- Central US に配置された VNet Integration を持つ Linux App Service
- ハブ サブネット内に配置された Linux Worker VM
- 管理アクセス用の Azure Bastion

## 2. Repository structure / リポジトリ構成

- [network/](./network) — hub network, subnets, NSGs, Bastion, VNet peering configuration
- [compute/](./compute) — App Service plan, web app, worker VM, VNet integration
- [data/](./data) — PostgreSQL Flexible Server, storage account, private endpoints, DNS links
- [bastion/](./bastion) — Bastion host deployment

## 3. Architecture / アーキテクチャ

### English

The topology is intentionally split across regions:
- `network` hosts the main hub network in `eastus2`
- `compute` creates an additional app VNet in `centralus` and peers it with the hub
- `data` deploys PostgreSQL and storage behind private endpoints
- `bastion` exposes a public Bastion endpoint while restricting ingress through the required Azure Bastion subnet

This design is useful for Azure for Students limits, because it keeps resources close to the supported quotas while still enabling private networking and secure app connectivity.

### 日本語

トポロジーはリージョンを分けて構成されています。
- `network` は `eastus2` のメインのハブ VNet を保持
- `compute` は `centralus` にアプリ用の追加 VNet を作成し、ハブとピアリング
- `data` は Private Endpoint を介した PostgreSQL とストレージをデプロイ
- `bastion` は Azure Bastion の公開エンドポイントを提供しつつ、必要な AzureBastionSubnet 経由のインバウンドのみを許可

この設計は Azure for Students の制約に適しており、サポート対象のクォータ内で資産を配置しながら、プライベート ネットワークと安全なアプリ接続を実現します。

## 4. Prerequisites / 前提条件

### English

Before running Terraform:
- Azure CLI installed and logged in
- valid Azure subscription
- Terraform 1.x installed
- permissions to create resource groups, network, storage, and App Service resources
- a public SSH key for the worker VM

Example login:

```bash
az login
az account set --subscription "<subscription-id>"
```

### 日本語

Terraform を実行する前に以下が必要です。
- Azure CLI がインストール済みでサインイン済み
- 有効な Azure サブスクリプション
- Terraform 1.x がインストール済み
- Resource Group、ネットワーク、ストレージ、App Service リソース作成権限
- Worker VM 用の SSH 公開鍵

ログイン例:

```bash
az login
az account set --subscription "<subscription-id>"
```

## 5. Configuration / 設定

Each module expects subscription and naming inputs. The `network` module contains a sample variable file:

各モジュールはサブスクリプションと命名に関する入力を必要とします。`network` モジュールにはサンプルの変数ファイルがあります。

```hcl
# network/terraform.tfvars
subscription_id = "<your-subscription-id>"
location        = "eastus2"
prefix          = "lz"
```

You will usually provide per-module values such as:
- subscription ID
- location
- prefix
- SSH public key
- Entra admin principal for PostgreSQL

通常、以下のようなモジュールごとの値を入力します。
- サブスクリプション ID
- リージョン
- プレフィックス
- SSH 公開鍵
- PostgreSQL 用の Entra 管理者主体

## 6. Typical deployment flow / 一般的なデプロイ手順

### English

```bash
cd network
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

cd ../data
terraform init
terraform plan -var-file="../network/terraform.tfvars"
terraform apply -var-file="../network/terraform.tfvars"

cd ../compute
terraform init
terraform plan -var-file="../network/terraform.tfvars"
terraform apply -var-file="../network/terraform.tfvars"

cd ../bastion
terraform init
terraform plan -var-file="../network/terraform.tfvars"
terraform apply -var-file="../network/terraform.tfvars"
```

Because each module reads the local Terraform state produced by the previous modules, the deployment order matters.

### 日本語

```bash
cd network
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

cd ../data
terraform init
terraform plan -var-file="../network/terraform.tfvars"
terraform apply -var-file="../network/terraform.tfvars"

cd ../compute
terraform init
terraform plan -var-file="../network/terraform.tfvars"
terraform apply -var-file="../network/terraform.tfvars"

cd ../bastion
terraform init
terraform plan -var-file="../network/terraform.tfvars"
terraform apply -var-file="../network/terraform.tfvars"
```

各モジュールは前段のモジュールが生成した local Terraform state を参照するため、デプロイ順序が重要です。

## 7. Key resources / 主要リソース

### English

- Resource Group for the landing zone
- VNet and subnets with NSG rules
- Private DNS links for Postgres and Blob
- PostgreSQL Flexible Server with private access only
- Storage Account with private Blob container
- App Service Linux web app using VNet Integration
- Linux worker VM in the secure internal subnet
- Azure Bastion host with public IP

### 日本語

- Landing Zone 用の Resource Group
- NSG を含む VNet とサブネット
- PostgreSQL と Blob 用の Private DNS Link
- Private access のみを許可する PostgreSQL Flexible Server
- Private Blob container を持つ Storage Account
- VNet Integration を利用する Linux Web App
- セキュアな内部サブネット上の Linux Worker VM
- パブリック IP を持つ Azure Bastion

## 8. Notes / 補足

### English

- The project assumes a learning or lab environment, not production-grade multi-region disaster recovery.
- Some values are intentionally set with student-friendly defaults, such as small SKUs and low-capacity resources.
- Review all CIDR ranges and Azure quotas before running in a real subscription.
- Private endpoints require correct DNS resolution for application connectivity.

### 日本語

- このプロジェクトは本番向けのマルチリージョン DR ではなく、学習・ラボ環境向けを想定しています。
- 小さな SKU や低容量のリソースを採用し、学生向けの制約に合わせています。
- 実サブスクリプションで利用する前に、CIDR 範囲と Azure クォータを必ず確認してください。
- Private Endpoint を利用する場合は、アプリケーション接続に必要な DNS 解決が正しく動作している必要があります。

## 9. Recommended next steps / 推奨される次のステップ

- Add a root `terraform.tfvars` file if you want a single deployment entry point
- Add backend configuration for remote state storage
- Add CI/CD automation for validation and deployment
- Add application-level secrets management using Key Vault
- Add monitoring, diagnostics, and alerting

- 単一のデプロイ入口にしたい場合は、ルートの `terraform.tfvars` を追加
- リモート状態保存のための backend 設定を追加
- バリデーションとデプロイのための CI/CD を導入
- Key Vault を使ったアプリケーション秘密情報管理を追加
- 監視、診断、アラートを追加

## 10. License / ライセンス

This project is provided as a sample infrastructure template for learning and experimentation.

このプロジェクトは、学習および実験用途のためのサンプル インフラ テンプレートとして提供されます。
