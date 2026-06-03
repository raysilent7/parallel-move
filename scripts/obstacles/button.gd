extends Node2D

@onready var buttonArea: Area2D = $buttonArea

func _ready() -> void:
	buttonArea.body_entered.connect(onBodyEntered)
	buttonArea.body_exited.connect(onBodyExited)

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		GameState.buttonPressed = true

func onBodyExited(body: Node2D) -> void:
	if body is CharacterBody2D:
		GameState.buttonPressed = false
