extends Node

## ユーザー設定の読み書きクラス。
## 自動読み込みに対応させる。

const USER_SETTINGS_NAME := "user://user_settings.cnf"

@onready var _config = ConfigFile.new()

func _ready() -> void:
	var err = _config.load(USER_SETTINGS_NAME)
	

