extends Area2D

@export var nextLevel: String = ""

func _ready() -> void:
	body_entered.connect(onBodyEntered)

func onBodyEntered(body: Node2D) -> void:
	if body.name == "playerBody" or body.name == "playerBody2":
		SaveData.saveLevelBeaten(nextLevel)
		get_tree().change_scene_to_file("res://objects/menus/selectionMenu.tscn")
