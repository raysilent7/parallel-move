extends Node

@onready var doorArea: Area2D = $doorBody/doorArea
@onready var doorCollision: CollisionShape2D = $doorBody/bodyCollision
@onready var doorAnim: AnimatedSprite2D = $doorBody/doorAnim

func _ready() -> void:
	doorArea.body_entered.connect(onBodyEntered)

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D and GameState.hasKey:
		GameState.hasKey = false
		doorAnim.play("opened")
		doorCollision.call_deferred("queue_free")
		doorArea.call_deferred("queue_free")
