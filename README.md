# README

これはShuのポートフォリオの、Digital Ichibaのバックエンドのリポジトリです。

## 概要
Digital Ichibaは、ハンドメイド作家や衣料品、雑貨、生活用品などの小規模セレクトショップのオーナー向けに、
SNSと直結して5分でオンラインショップを開設できるECプラットフォームです。
シングルページアプリケーション（SPA）によるスムーズな操作性と、Stripeによる信頼性の高い決済機能を搭載。
在庫管理やモバイル最適化も完備し、日常の投稿からそのまま販売につなげられます。
誰でもスムーズに販路を広げ、ブランドの魅力を最大限に発信できる環境を提供します。

## バージョン情報
このリポジトリのバージョン情報です。  
Ruby 3.3.9  
Rails 8.0.2.1  
PostgreSQL 16.10  
Docker 28.4.0  

こちらは同じプロジェクトのフロントエンドのリポジトリです。  
TypeScript 5.9.3  
React 19.1.0  
Next.js 15.5.7  
Auth.js 5.0.0-beta.30  
TailwindCSS 4.1.17  

## ER図
![ER図](docs/digital_ichiba_erd.webp)

## Setup
```bash
docker compose up
```

## 環境変数
開発では、最低限DB接続とJWT検証の設定が必要です（`.env` に入れる想定）。

```bash
# DB（PostgreSQL）
DB_HOST=localhost
DB_NAME=digital_ichiba_development
DB_USER=postgres
DB_PASSWORD=postgres

# Next→Rails API のJWT検証（公開鍵）
# ※Next側の APP_JWT_PRIVATE_KEY とペアになります
APP_JWT_PUBLIC_KEY="-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----\n"
APP_JWT_ISS=digital-ichiba-next
APP_JWT_AUD=digital-ichiba-rails

# Stripe（サーバー側）
STRIPE_SECRET_KEY=sk_test_xxx

# Stripe Webhooks
STRIPE_CHECKOUT_WEBHOOK_SECRET=whsec_xxx
STRIPE_CONNECT_WEBHOOK_SECRET=whsec_xxx

# CORS/リダイレクト等に使用（フロントURL）
NEXT_URL=http://localhost:3001

# 手数料・送料（数値）
PLATFORM_FEE_PERCENT=10
SHIPPING_CENTS=500
```

### ざっくり用途
- **`DB_*`**: DB接続情報（`docker compose` の `db` と合わせる）
- **`APP_JWT_PUBLIC_KEY / APP_JWT_ISS / APP_JWT_AUD`**: Nextから来るJWTの検証用
- **`STRIPE_SECRET_KEY`**: Stripe API呼び出し用の秘密鍵
- **`STRIPE_*_WEBHOOK_SECRET`**: Webhook署名検証用（Checkout / Connect）
- **`NEXT_URL`**: フロントのURL（CORSやStripeのリダイレクトで使用）
- **`PLATFORM_FEE_PERCENT`**: プラットフォーム手数料（%）
- **`SHIPPING_CENTS`**: 送料（セント換算）