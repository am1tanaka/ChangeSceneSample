# シーン切り替え

## 必要なもの

- シーンチェンジャースクリプト
  - 自動読み込み
  - シーン切り替えの処理に関する機能を提供
- タイトル
- UI
  - ゲーム中のボタンを提供
- ステージ
  - クリックすると消えるボタンを配置
- フェードシーン
  - アニメーションで画面を隠す
  - 画面切り替え用の仮想関数を定義したベースクラスを持つ

## シーン切り替え処理の流れ

- SceneChanger.cover_and_change_scene(カバーシーンのインスタンス, 速度, シーンデータ)
  - 指定のカバーで画面を隠して、シーンの読み込みを開始
  - シーンを生成しながら、ready完了のシグナルに登録
  - すべての読み込みが完了したら、呼び出すシグナルに、次のシーンの初期化処理を登録させる
  - 読み込みが完了したら、処理をemit
- 次のシーンのreadyで、初期化処理を登録
- 次のシーンで、SceneChangerのuncover(倍率)でスクリーンを解除。コルーチン
