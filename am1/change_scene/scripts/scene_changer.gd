extends Node

## シーン切り替えを実行するクラス。
## 自動読み込みに設定して利用する。
## 画面を隠す演出とシーンを切り替えたいとき、cover_and_change_scene関数。
## シーンの切り替えだけ必要なら、change_scene関数。
## 初期化が必要なシーンは、_ready内で、SceneChanger.all_scenes_loadedシグナルに処理を登録する。
## シーンリストにない、自動読み込みではないシーンは、画面を隠したあとに自動的に解放する。
## load_scenes_async関数で、配列で渡したシーンを読み込む。すでに読み込み済みのシーンは何もしない。
## 読み込み終えたら、all_scenes_loadedシグナルを発行する。
## unload_scene関数で、指定のシーンを解放する。シーンがないときは何もしない。
## すべてのシーンが解放されたら、all_scenes_unloadedシグナルを発行する。

func cover_and_change_scene(cover: ScreenCoverBase, cover_seconds: float, load_scenes: LoadSceneArray):
	pass

