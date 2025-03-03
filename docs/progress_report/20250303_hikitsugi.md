# GCPデプロイメント計画 (2025-03-02)

## プロジェクト概要
- **目的**: Railsアプリケーションを Google Cloud Platform (GCP) にデプロイ
- **インスタンスタイプ**: f1-micro (vCPU 1個, メモリ 566MB)
- **ゾーン**: us-central1-c
- **OS**: Debian

## 前提条件
1. ローカル環境:
   - macOS環境
   - Google Cloud SDK がインストール済み
   - Git がインストール済み

2. GCP環境:
   - GCPプロジェクトが作成済み
   - Compute Engine APIが有効化済み
   - 課金が有効化済み

3. アプリケーション:
   - Ruby on Rails アプリケーション
   - GitHubでソース管理されている
   - PostgreSQLをデータベースとして使用

## 実行済みコマンド一覧

### 1. GCPインスタンス接続設定
```bash
# gcloudの初期設定
gcloud init

# SSHの設定をリセット
gcloud compute config-ssh --remove
gcloud compute config-ssh

# 再接続
gcloud compute ssh instance-20250302-191218 --zone=us-central1-c
```

### 2. システムアップデートとパッケージインストール
```bash
# システムアップデート
sudo apt update
sudo apt upgrade -y

# 必要なパッケージのインストール
sudo apt install -y nginx postgresql postgresql-contrib ruby ruby-dev
sudo apt install -y git
```

### 3. SSHセキュリティ設定
```bash
# SSHの設定ファイル編集
sudo nano /etc/ssh/sshd_config

# SSHサービスの再起動
sudo systemctl daemon-reload
sudo systemctl restart ssh
```

### 4. アプリケーション用ディレクトリ設定
```bash
# ディレクトリ作成と権限設定
sudo mkdir -p /var/www/bookmarkly
sudo chown -R $USER:$USER /var/www/bookmarkly
```

### 5. GitHubアクセス設定
```bash
# SSHキーの生成
ssh-keygen -t ed25519 -C "あなたのメールアドレス"

# 公開鍵の表示（GitHubに登録用）
cat ~/.ssh/id_ed25519.pub

# GitHubへの接続テスト
ssh -T git@github.com
```

## 現在の状態
- [x] GCPインスタンス接続完了
- [x] システムパッケージ更新完了
- [x] SSHセキュリティ設定完了
- [x] アプリケーションディレクトリ作成完了
- [x] GitHubのSSH鍵設定完了
- [ ] アプリケーションのクローン（次のステップ）

## 次のステップ
1. GitHubからアプリケーションコードのクローン
2. 環境変数の設定
   - DATABASE_URL
   - RAILS_ENV
   - SECRET_KEY_BASE
3. データベースのセットアップ
   - PostgreSQLの初期設定
   - データベース作成
   - マイグレーション実行

## 技術スタック
- Webサーバー: Nginx
- アプリケーションサーバー: Rails (Puma)
- データベース: PostgreSQL
- Ruby: [バージョンを指定]
- Rails: [バージョンを指定]

## 注意点
- メモリ制限（566MB）を考慮した運用
  - Pumaのワーカー数制限が必要
  - アセットプリコンパイルは本番環境で注意
- セキュリティ設定の維持
  - SSHアクセス制限
  - ファイアウォール設定
- 定期的なバックアップの検討
  - データベースバックアップ
  - アプリケーションログ

## トラブルシューティング
- SSHアクセスできない場合: `gcloud compute ssh` コマンドを使用
- パッケージインストールでロックがかかる場合: プロセス終了を待つか、ロックファイル削除
- メモリ不足の場合: スワップファイルの設定を検討

## ビルドログの確認
```bash
# 新しいSSHセッションを開く
gcloud compute ssh instance-20250302-191218 --zone=us-central1-c

# ビルドログを確認
tail -f /tmp/ruby-build.*.log
```



