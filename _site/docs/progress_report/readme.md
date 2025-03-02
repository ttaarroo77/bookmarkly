# 進捗レポート管理

## 1. レポートの種類
- **日次レポート**: 毎日の進捗と課題を記録
- **週次レポート**: 週単位の進捗と振り返り
- **マイルストーンレポート**: 主要なタスク完了時に作成

## 2. レポートテンプレート
### 2.1 基本テンプレート
【必須】タスク管理にチェックボックス [] は使うこと

```markdown
# [レポートタイトル] (YYYY-MM-DD)

## 1. 本日の進捗
- [ ] タスク1
- [ ] タスク2

## 2. 発生した問題
- 問題1
- 問題2

## 3. 明日の予定
- [ ] タスク1
- [ ] タスク2

## 4. その他
- 気づきや改善点
```

### 2.2 バグレポートテンプレート
```markdown
# バグレポート (YYYY-MM-DD)

## 1. バグ概要
- **バグID**: [自動生成または手動入力]
- **報告日**: [YYYY-MM-DD]
- **報告者**: [名前]

## 2. 詳細
- **バグ概要**: [簡潔な説明]
- **発生条件**: [再現手順]
- **期待する挙動**: [正しい動作]
- **実際の挙動**: [観測された動作]

## 3. 重要度
- **重要度**: [高/中/低]
- **緊急度**: [高/中/低]

## 4. 対応
- **原因の見立て**: [暫定的な原因分析]
- **対応状況**: [未対応/調査中/修正済み]
- **関連チケット**: [関連するIssue番号など]
```

## 3. レポート管理方法
1. 日次レポート: `docs/progress_report/daily/YYYY/MM/YYYY-MM-DD.md`
2. 週次レポート: `docs/progress_report/weekly/YYYY/YYYY-MM-WW.md`
3. マイルストーンレポート: `docs/progress_report/milestone/YYYY/YYYY-MM-DD_milestone.md`

## 4. 参考
- [プロジェクト概要](docs/overview_0/product-brief.md)
- [システム設計](docs/system_design_2/architecture.md)
- [テスト戦略](docs/testing_4/test_strategy.md)

### 5.参考プロンプト：
[prompt]
================
[Input] → [User Intent] →[Intent]( , , , , , , , , , , , , , )
[Input] → [User Intent] →[Want or need Intent]( , , , , , , , , , , , , , )
<User Input>
exmample: what I want to do
</User Input>
[Fixed User want intent] = Def Fixied Goal
Achieve Goal == Neet Tasks
[Goal]=[Tasks](Task, Task, Task, Task, Task, Task, Task, Task)
To Do Task Excute
 need Prompt And (Need Tool)
 assign Agent 
Agent Task Excute Feed back loop 
Then Task Complete
Excute
================