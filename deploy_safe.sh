#!/bin/bash

# スクリプト名
SCRIPT_NAME="Deploy Safe"

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

# デプロイ先の選択
echo "デプロイ先を選択してください:"
echo "1) Heroku"
echo "2) 他の環境"
read DEPLOY_TARGET

if [ "$DEPLOY_TARGET" = "1" ]; then
  echo "Heroku にデプロイしています..."
  
  # Herokuリモートの確認
  HEROKU_REMOTE=$(git remote -v | grep heroku | head -n 1 | awk '{print $1}')
  
  # Herokuリモートが存在しない場合
  if [ -z "$HEROKU_REMOTE" ]; then
    echo "Herokuリモートが設定されていません。アプリ名を入力してください："
    read HEROKU_APP_NAME
    heroku git:remote -a $HEROKU_APP_NAME
  fi
  
  if [ "$CURRENT_BRANCH" = "main" ]; then
    git push heroku main
  else
    echo "現在のブランチ($CURRENT_BRANCH)をHerokuのmainブランチにプッシュします。"
    echo "続行しますか？ (y/n)"
    read CONFIRM
    if [ "$CONFIRM" = "y" ]; then
      git push heroku $CURRENT_BRANCH:main -f
    else
      echo "Herokuへのデプロイをキャンセルしました。"
    fi
  fi
  
  # Herokuアプリを再起動
  echo "Herokuアプリを再起動しています..."
  heroku restart
  
  # マイグレーションの実行確認
  echo "データベースマイグレーションを実行しますか？ (y/n)"
  read RUN_MIGRATION
  if [ "$RUN_MIGRATION" = "y" ]; then
    heroku run rails db:migrate
  fi
  
elif [ "$DEPLOY_TARGET" = "2" ]; then
  echo "他の環境へのデプロイ方法を入力してください："
  read OTHER_DEPLOY_COMMAND
  eval $OTHER_DEPLOY_COMMAND
else
  echo "無効な選択です。デプロイをスキップします。"
fi

# 完了メッセージ
echo "✅ $SCRIPT_NAME が正常に完了しました！"