class_name LoadSceneData
extends Resource

## 読み込むシーンのデータクラス。

## 読み込むシーンのファイルパス
@export_file("*.tscn") var scene_path: String

## シーンが読み込み済みのとき、リロードするならtrue
@export var is_reload: bool = false
