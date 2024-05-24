extends Node

## ユーザー設定の読み書きクラス。
## 自動読み込みに対応させる。

const USER_SETTINGS_NAME := "user://user_settings%s.cnf"

## 最後に開いていたシーンを指定する列挙子。
enum SceneType {
	TITLE,
	GAME,
}

@onready var _config = ConfigFile.new()

## テスト用に、ファイル名の末尾につける文字列
var _postfix := ""

## 準備ができたら、自動的に読み込みや、初期化を実行する。
func _ready() -> void:
	load_settings()

## 設定を読み込む。
func load_settings() -> void:
	var err = _config.load(USER_SETTINGS_NAME)

	print_debug("設定を読み込む。")

## 最後に開いていたシーンを読み取って返す。
func get_last_scene() -> SceneType:
	print_debug("TODO 未実装")
	return SceneType.TITLE

## シーンを切り替えたら呼び出して、最後に開いたシーンを保存する。
func set_and_save_last_scene(scene: SceneType) -> void:
	print_debug("TODO 最後に開いたシーンを保存")

## 撃破したキャラのインデックスをリストで返す。
func get_destroyed_characters() -> Array[int]:
	print_debug("TODO 未実装")
	return []

## 撃破したキャラのインデックスを設定する。
func set_destroy_character(chr: int) -> void:
	print_debug("TODO 未実装")

## 登録したキャラのインデックスを保存する。
func save() -> void:
	print_debug("TODO 保存実行")

## デバッグ用の設定ファイルの接尾語を設定して、該当ファイルを読み込み直す。
func debug_set_postfix(post: String) -> void:
	_postfix = post

## 設定ファイルを削除する。
func delete_save_data() -> void:
	print_debug("TODO 未実装")

