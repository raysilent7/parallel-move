extends Node2D

@onready var camera: Camera2D = $camera
@onready var player: Node2D = $Player
@onready var light: PointLight2D = $light
@onready var darkness: CanvasModulate = $obstacles/darkness
@onready var hud: CanvasLayer = $HUD
var popupScene: PackedScene = preload("res://objects/menus/popupGame.tscn")

func _ready() -> void:
	AudioManager.startMusicSystem()
	GameState.hasKey = false
	GameState.isDark = darkness.visible
	if GameState.isDark:
		light.enabled = true
	else:
		light.enabled = false

func _process(_delta: float) -> void:
	camera.global_position.x = player.p1.global_position.x
	light.global_position = camera.global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pauseMenu = popupScene.instantiate()
		hud.add_child(pauseMenu)
		get_tree().paused = true
