extends Control

@onready var startButton: Button = $buttonContainer/startButton

func _ready() -> void:
	AudioManager.startMusicSystem()
	startButton.pressed.connect(onStartButtonPressed)
	get_tree().paused = false

func onStartButtonPressed() -> void:
	get_tree().change_scene_to_file("res://objects/menus/selectionMenu.tscn")
