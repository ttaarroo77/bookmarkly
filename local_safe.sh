# ./local_safe.sh

# chmod +x local_safe.sh


#!/bin/bash

# スクリプト名
SCRIPT_NAME="local safe"

# 現在のブランチを取得
CURRENT_BRANCH=$(git branch --show-current)

# コミットメッセージの入力
echo "コミットメッセージを入力してください:"
read COMMIT_MESSAGE

# Git ステータスの確認
echo "Git ステータスを確認しています..."
git status

# 変更をステージング
echo "変更をステージングしています..."
git add .

# コミット
echo "コミットを実行しています..."
git commit -m "$COMMIT_MESSAGE"

# コミットログの表示
echo "直近のコミットログを表示します..."
git log -1

# リモートリポジトリにプッシュ
echo "リモートリポジトリにプッシュしています..."
git push origin $CURRENT_BRANCH

# Heroku にデプロイ
echo "Heroku にデプロイしています..."
git push heroku $CURRENT_BRANCH
# git push heroku $CURRENT_BRANCH:main


# 完了メッセージ
echo "✅ $SCRIPT_NAME が正常に完了しました！"