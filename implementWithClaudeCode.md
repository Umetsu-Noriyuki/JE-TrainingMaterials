# Claude Code 運用ガイド

このドキュメントは、剣道アプリUI/UX改善プロジェクト（ippon_mobile2）の実装フェーズで Claude Code を利用してきた際の指示方法・ルール構成・運用Tipsをまとめたものである。今後 Claude Code に指示を出す際、あるいは新しいメンバーがこの体制を引き継ぐ際の参考資料とする。

尚、剣道アプリUI/UX改善は、Flutter を利用したスマホアプリである。そのリポジトリは Backlog の Git を利用している。


## 1. 概要

本プロジェクトでは、Claude Code に対して以下を明文化したファイル群を用意し、実装の一貫性・品質・安全性を担保してきた。

- `CLAUDE.md` — プロジェクトルート直下、Claude Code が自動読み込みする最上位の指示ファイル
- `rules/` — 言語横断・言語別のコーディング規約、レビュー基準
- `specification/` — アプリ仕様、アーキテクチャ、命名規則、テスト規約、利用ライブラリ
- `.claude/setting.json` / `.claude/settings.local.json` — 実行権限（コマンド許可/拒否リスト）

指示は「何を実装するか」だけでなく「どういう手順で・どこまで確認を取りながら進めるか」まで明文化している点が特徴で、これにより承認なしの実装や意図しない破壊的操作を防いできた。

## 2. 基本設定

### 2.1 CLAUDE.md の必須ルール

- すべての応答は日本語で行う
- **実装前に、まずアプローチの計画を立てて提示し、その後は停止する。ユーザーから承認を受けるまで実装してはいけない**（1行の修正のような些細な変更でも例外なし）
- 実装前に、確認したファイルを報告する
- `.env` / credentials 等の機密ファイルを読み取り・編集・コミットしない
- シークレットやAPIキーをコードにハードコードしない
- `rm -rf /` やforce push等の破壊的コマンドを実行しない
- レビューを指示された際は `rules/dart/review-rule.md` にも従う
- 新規作成ファイルごとにテストコードを作成する（指示がなくても必須）
- 実装前に `specification/coding.md`（命名規則・テストルール・ディレクトリ構成）、`specification/Library.md`（利用ライブラリ）、`rules/common/coding-style.md`、`rules/dart/coding-style.md` を読む

### 2.2 permission設定（`.claude/setting.json` / `settings.local.json`）

- `setting.json` で `sudo`/`rm`/`git push`/`git reset --hard`/`git rebase`/`git clean`/`curl`/`wget`/`chmod`/`npm install` 等の破壊的・環境変更系コマンドや、`.env`/秘密鍵/`.aws`/`.ssh`等の機密ファイルへの Read/Write/Edit を deny リストで明示的に禁止
- `settings.local.json` で `fvm flutter *`、`fvm dart *`、`git status *`、`adb` 経由の実機操作コマンドなど、日常的に使う安全なコマンドを allow リストに追加し、確認プロンプトの頻度を下げている
- 新しいコマンドパターンを許可する場合は `update-config` スキル等を使い、都度 allow リストに追記する運用

### 2.3 FVMによるFlutterバージョン固定

Flutter 3.38.3 を FVM で固定。すべての `flutter`/`dart` コマンドは `fvm flutter <command>` / `fvm dart <command>` の形で実行する。

## 3. 指示ドキュメントの構成と役割

| ディレクトリ/ファイル | 役割 |
|---|---|
| `rules/common/coding-style.md` | 不変性、ファイル構成（200〜400行目安・最大800行）、エラーハンドリング、入力検証の共通方針 |
| `rules/common/patterns.md` | Repositoryパターン、APIレスポンス形式などの設計パターン |
| `rules/common/security.md` | シークレット管理・入力検証・SQLi/XSS対策等の必須セキュリティチェック |
| `rules/common/code-review.md` | レビューチェックリストと重大度レベル（CRITICAL/HIGH/MEDIUM/LOW） |
| `rules/common/agents.md` | サブエージェント運用方針（本プロジェクトでは実体としては未整備、方針のみ） |
| `rules/dart/coding-style.md` | Dart/Flutter固有の規約（フォーマット、イミュータビリティ、null安全、sealed型、非同期、import順） |
| `rules/dart/review-rule.md` | PRレビュー観点（アーキ違反・Drift利用・Riverpod方針・N+1・不要な再描画・メモリリーク・テスト不足等） |
| `rules/dart/design-system.md` | カラー・タイポグラフィ・共通コンポーネント定義 |
| `specification/coding.md` | 命名規則、コーディングルール（1関数50行目安等）、テストコード作成ルール、レイヤー別カバレッジ目標 |
| `specification/Library.md` | 採用ライブラリ（Drift, Riverpod, GoRouter, fl_chart）とその方針 |
| `specification/architecture.md` | `/lib` 以下のディレクトリ構成の正本。構成にないディレクトリを新設する場合は確認必須 |
| `specification/*_*.md`（画面別） | 各画面（Calendar, Record, Training, Condition, Analysis等）の仕様書。UI・振る舞いの一次情報源 |

`rules/` と `specification/` が矛盾する場合は `specification/` を優先する（CLAUDE.md記載）。

## 4. 実装ワークフロー

任意の実装指示後、Claude code側の実装のサイクルは以下の通り。

1. **要望のヒアリング** — 曖昧な指示は `specification/` の該当仕様書と突き合わせて解釈する
2. **関連ファイルの確認** — 変更対象・参照すべきルール/仕様ファイルを読み、ユーザーに報告する
3. **計画の提示** — 変更内容・対象ファイル・テスト方針を明示し、そこで一旦停止する
4. **承認待ち** — ユーザーの明示的な承認（「進めてください」等）を得るまで着手しない
5. **実装** — `specification/architecture.md` のディレクトリ構成、`rules/dart/coding-style.md` の規約に従う
6. **テストコード作成** — 新規/修正ファイルごとに `test/` 以下へ同一ディレクトリ構造でテストを作成・更新
7. **レビュー** — `/code-review` 等で `rules/dart/review-rule.md` の観点に従いレビュー
8. **テスト実行** — 変更範囲に応じて対象ディレクトリ単位で `fvm flutter test` を実行

### テストコード規約（要点）

- 配置: `/test` 以下に `/lib` と同じディレクトリ構造。ファイル名は対象ファイル名の `.dart` を `.test.dart` に変更
- 内容: ブラックボックステスト→分岐網羅→例外処理の順で記述。`test()` のsubjectは日本語
- Riverpodテスト等インスタンス生成を伴う場合は `addTearDown()` で解放しメモリリークを回避
- RepositoryのMockには `mocktail` を利用
- カバレッジ目標: Service/ViewModel 80〜90%、Provider 60〜80%、Page 20〜40%、再利用Widget 30〜50%

## 5. コードレビュー基準

コードレビューは任意の実装完了し、作業ブランチのPush後に、「developブランチと現在のブランチの差分(git diff)をレビューしてください
」の指示により Claude code に実施させる。その際、実装とは別のセッションとし、実装時とは異なる客観的な観点でレビューさせる。

`rules/dart/review-rule.md` に基づき、以下の観点でレビューする。

- アーキテクチャ違反、Driftの使い方、Riverpod利用方針
- N+1クエリ、不要な再描画、メモリリーク
- テスト不足、命名規則違反、可読性、セキュリティ

重大度は `rules/common/code-review.md` の基準に従う。

| レベル | 意味 | アクション |
|---|---|---|
| CRITICAL | セキュリティ脆弱性・データ損失リスク | マージ前に修正必須（BLOCK） |
| HIGH | バグ・重大な品質問題 | マージ前に修正すべき（WARN） |
| MEDIUM | 保守性の懸念 | 修正を検討（INFO） |
| LOW | スタイル・軽微な提案 | 任意（NOTE） |

## 6. 運用で得られたTips

実際の実装フェーズで得られた、ドキュメント化されていない実務上の知見。これらは個々の Claude code 契約毎に記録している。複数の開発者で契約が異なる Claude code を利用している場合は、これら Tips の内容を精査し、必要なものは次のプロジェクト開始前には CLAUDE.md などのルールを記載するファイルに追記し共有すべきである。 

### 6.1 些細な変更でも承認を待つ

1行の文字列変更のような軽微な修正であっても、「計画提示」と「実装」を同じターンで済ませてはならない。計画を提示したら一度必ず停止し、ユーザーからの明示的な承認を待ってから着手する。過去に些細さを理由に確認を省略し、指摘を受けた経緯がある。

### 6.2 共有ViewModelメソッドへの依存追加はテストのoverride漏れに注意

`loadForEdit()` のような複数画面・複数テストファイルから呼ばれる共有ViewModelメソッドに新しい `ref.read(xxxRepositoryProvider)` を追加すると、その `xxxRepositoryProvider` をoverrideしていない既存の `ProviderContainer`/`ProviderScope` が実DBを叩こうとしてハングし、10分後に `TimeoutException` で失敗することがある。個別ファイル実行では気づきにくいため、共有メソッドに依存を追加した際は、それを呼ぶ全テストファイルを `grep` で洗い出してoverride漏れがないか確認し、該当featureディレクトリ単位で `fvm flutter test test/features/<feature>/` を実行して確認する。

### 6.3 `fvm flutter test` 全体実行時のsqlite3関連エラーの切り分け方

`fvm flutter test`（引数なし・全体実行）でDrift/SQLite系テストが `Failed to load dynamic library 'libsqlite3.so'` で多数失敗することがある。これはLinux環境で `libsqlite3.so` のシンボリックリンクが無いことに起因する既知の環境要因であり、必ずしも自分の変更による回帰ではない。切り分け手順:

1. 失敗しているテストファイルを個別に `fvm flutter test <file>` で実行し、単体で通るか確認する
2. 通るなら環境要因と判断してよい（`git stash` での前後比較も有効）
3. DB系以外（viewmodel/widget/pure dartロジック）のテストが失敗している場合はこの限りではなく、実際のバグを疑う

※ これは Claude code セッションの開発環境(WSL2, Ubuntu)に`libsqlite3.so`の参照がうまく行かなかったため、Claude code が留意したものである。エミュレータにより実際の動作を手動で行いDB系の動作確認を行っている。

### 6.4 スコープが過大なタスクは見送り、判断根拠を残す

コードレビューでのMinor指摘等、対応の投資対効果が見合わないと判断した場合は、その場で完全修正を目指さず見送る判断も選択肢とする。その際は「なぜ見送ったか」「再検討すべき条件」を記録しておくことで、同じ議論の再発を防げる（例: 6.5, 6.6参照）。

※ この判断を行ったのは Calude code ではなく開発者である。


### 6.5 Calendar画面の不要な再描画修正（見送り中）

CL-01カレンダー画面（`lib/features/calendar/`）では、予定/記録を1件追加・編集するたびに `CalendarNotifier.init()` が呼ばれ `calendarData` 全体が再構築される。真に「変更のあった日付・種類のデータだけ再描画する」には `CalendarState`/`CalendarDayEntry` 等の値の等価性実装が必要で、影響範囲がアプリ全体のモデル（`ScheduleEntry`/`ConditionRecord`/`TrainingRecord`/`DiaryEntry`）に及ぶため、Minor指摘に対して変更量・リスクが過大と判断し見送った。実機での表示速度を確認した上で対応要否を再検討する予定。

### 6.6 個人戦/団体戦一覧のページング（対応不要と判断済み）

`individual_match_list_page.dart` / `team_match_list_page.dart` は `findAll()` で全件取得しページングなしで表示している。年間試合数の想定から「数千件規模」に達するには10年以上の継続利用が必要と見積もり、現時点では対応不要と判断した。チーム単位の一括インポート機能追加等、データ量の前提が変わった場合は再検討する。

## 7. よく使うコマンド

```bash
fvm flutter pub get                      # 依存関係インストール
fvm flutter run                          # 実機/エミュレータで実行
fvm flutter build apk                    # Android APKビルド
fvm flutter build web                    # Webビルド
fvm flutter analyze                      # 静的解析
fvm flutter test                         # 全テスト実行
fvm flutter test test/path/to_test.dart  # 単一テストファイル実行
fvm flutter test test/features/<feature>/ # feature単位のテスト実行
```

## 8. 申し送り事項

以下は意図的に対応を見送っているタスク。再着手時は背景（6章）を踏まえて判断すること。

- Calendar画面の不要な再描画の完全修正（実機確認待ち、6.5参照）
- 個人戦/団体戦一覧のページング対応（データ量前提が変わった場合のみ再検討、6.6参照）
