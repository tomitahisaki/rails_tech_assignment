# 課題

URL: https://github.com/tomitahisaki/rails_tech_assignment

時間: 15~21 時間

# 起動方法

## 1. 依存関係のインストール

```bash
bundle install
```

## 2. 認証情報の設定

認証情報を確認する場合：

```bash
bin/rails credentials:show
```

認証情報を編集する場合：

```bash
bin/rails credentials:edit
```

## 3. データベースのセットアップ

```bash
bin/rails db:prepare
bin/rails db:seed
```

## 4. Rails サーバーの起動

```bash
bin/rails server
```

## 5. ログイン確認

ブラウザで `http://localhost:3000` にアクセスし、以下の情報でログインできることを確認：

- Email: test@example.com
- Password: password
