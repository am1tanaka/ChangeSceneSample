extends Node

## 起動スクリプト

const COVER_SECONDS := 0.5

## タイトルのためのシーン
@export var _title_scenes: LoadSceneArray

## ゲームのためのシーン
@export var _game_scenes: LoadSceneArray

func _ready():
	# 設定を確認
	if UserSettings.get_last_scene() == UserSettings.SceneType.TITLE:
		# タイトルから起動
		SceneChanger.cover_and_change_scene($SplashScreen, COVER_SECONDS, Color.WHITE, _title_scenes)
	else:
		# ゲームから起動
		SceneChanger.cover_and_change_scene($SplashScreen, COVER_SECONDS, Color.WHITE, _game_scenes)

