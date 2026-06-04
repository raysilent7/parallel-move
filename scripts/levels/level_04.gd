extends Node2D

@onready var camera: Camera2D = $camera
@onready var player: Node2D = $Player
@onready var darkness: CanvasModulate = $darkness

func _ready() -> void:
	AudioManager.startMusicSystem()
	GameState.hasKey = false
	GameState.isDark = darkness.visible
	if GameState.isDark:
		pass
	else:
		pass

func _process(_delta: float) -> void:
	camera.global_position.x = player.p1.global_position.x
