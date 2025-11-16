# 課題

URL: https://github.com/tomitahisaki/rails_tech_assignment
時間: 15~21 時間

# 起動方法

## 1. 依存関係のインストール

```bash
bundle install
```

## 2. データベースのセットアップ

```bash
bin/rails db:prepare
bin/rails db:seed
```

## 3. Rails サーバーの起動

```bash
bin/rails server
```

## 4. ログイン確認

ブラウザで `http://localhost:3000` にアクセスし、以下の情報でログインできることを確認：

- Email: test@example.com
- Password: password
