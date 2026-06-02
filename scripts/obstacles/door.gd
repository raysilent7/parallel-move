extends Node

@onready var doorArea: Area2D = $doorBody/doorArea
@onready var doorCollision: CollisionShape2D = $doorBody/bodyCollision
@onready var doorAnim: AnimatedSprite2D = $doorBody/doorAnim

var playerInside: bool = false

func _ready() -> void:
	doorArea.body_entered.connect(onBodyEntered)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and playerInside and GameState.hasKey:
		GameState.hasKey = false
		doorAnim.play("opened")
		doorCollision.call_deferred("queue_free")
		doorArea.call_deferred("queue_free")

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = true

func onBodyExited(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = false
