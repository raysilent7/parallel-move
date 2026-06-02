extends Area2D

var playerInside: bool = false

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	body_exited.connect(onBodyExited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and playerInside:
		GameState.hasKey = true
		get_parent().call_deferred("queue_free")

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = true

func onBodyExited(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = false
