extends Control

@onready var startButton: Button = $buttonContainer/startButton

func _ready() -> void:
	startButton.pressed.connect(onStartButtonPressed)

func onStartButtonPressed() -> void:
	get_tree().change_scene_to_file("res://objects/levels/level0.tscn")
