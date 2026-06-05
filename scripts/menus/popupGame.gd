extends Control

@onready var menu: Button = $container/menu

func _ready() -> void:
	menu.pressed.connect(onMenuPressed)

func onMenuPressed() -> void:
	get_tree().change_scene_to_file("res://objects/menus/mainMenu.tscn")
