extends Area2D

var playerInside: bool = false
var player: Node2D

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	body_exited.connect(onBodyExited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and playerInside:
		GameState.gravityInverted = not GameState.gravityInverted
		player.invertGravity()

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = true
		player = body.get_parent()

func onBodyExited(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = false
