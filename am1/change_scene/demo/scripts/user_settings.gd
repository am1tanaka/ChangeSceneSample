extends Node

## ユーザー設定の読み書きクラス。
## 自動読み込みに対応させる。

## 設定ファイルパスのテンプレート
const USER_SETTINGS_NAME := "user://user_settings%s.cfg"
## ユーザー設定ファイルパスを返す。
var _user_setting_path: String:
	get:
		return USER_SETTINGS_NAME % _postfix

## 設定セクション名
const SETTING_SECTION_NAME := "play_data"

## 最後のシーンのキー名
const LAST_SCENE_KEY := "last_scene"

## 破壊敵リストのキー名
const DESTROYED_CHARACTERS_KEY := "destroyed"

## 最後に開いていたシーンを指定する列挙子。
enum SceneType {
	TITLE,
	GAME,
}

@onready var _config = ConfigFile.new()

## テスト用に、ファイル名の末尾につける文字列
var _postfix := ""

## 前回のシーン
var _last_scene: SceneType

## やっつけたキャラクターの配列
var _destroyed_characters : Array[int] = []

## 準備ができたら、自動的に読み込みや、初期化を実行する。
func _ready() -> void:
	load_settings()

## データを初期化
func _init_data():
	_last_scene = SceneType.TITLE
	_destroyed_characters = []

## 設定を読み込む。
func load_settings() -> void:
	var err = _config.load(_user_setting_path)
	if err != OK:
		# 初期化
		_init_data()
		return
	
	# データを読み込む
	_last_scene = _config.get_value(SETTING_SECTION_NAME, LAST_SCENE_KEY, SceneType.TITLE)
	var destroyed_chrs = _config.get_value(SETTING_SECTION_NAME, DESTROYED_CHARACTERS_KEY, "").split(",")
	_destroyed_characters.clear()
	for str_index in destroyed_chrs:
		_destroyed_characters.append(str_index.to_int())

## 最後に開いていたシーンを読み取って返す。
func get_last_scene() -> SceneType:
	return _last_scene

## シーンを切り替えたら呼び出して、最後に開いたシーンを保存する。
func set_and_save_last_scene(scene: SceneType) -> void:
	_last_scene = scene
	_destroyed_characters.clear()

	# シーンを切り替えたら、撃破データは削除
	_config.clear()
	_config.set_value(SETTING_SECTION_NAME, LAST_SCENE_KEY, scene)
	save()

## 撃破したキャラのインデックスをリストで返す。
func get_destroyed_characters() -> Array[int]:
	print_debug("TODO 未実装")
	return []

## 撃破したキャラのインデックスを設定する。
func set_destroy_character(chr: int) -> void:
	print_debug("TODO 未実装")

## 登録したキャラのインデックスを保存する。
func save() -> void:
	var err = _config.save(_user_setting_path)
	if err != OK:
		push_error("save %s error." % _user_setting_path)


## デバッグ用の設定ファイルの接尾語を設定して、該当ファイルを読み込み直す。
func debug_set_postfix(post: String) -> void:
	_postfix = post

## 設定ファイルを削除する。
func delete_save_data() -> void:
	_config.clear()
	save()

