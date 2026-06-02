extends Area2D

@onready var playerController: Node2D = $"../../Player"

func _ready() -> void:
	body_entered.connect(onBodyEntered)

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerController.movePlayerToCheckPoint()
