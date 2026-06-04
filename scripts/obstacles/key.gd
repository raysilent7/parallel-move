extends Area2D

var playerInside: bool = false
var playerNode: CharacterBody2D = null

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	body_exited.connect(onBodyExited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and playerInside and playerNode:
		GameState.hasKey = true
		
		if playerNode.has_method("startHoldingKeyAnimation"):
			playerNode.startHoldingKeyAnimation()
		
		get_parent().call_deferred("queue_free")

func onBodyEntered(body: Node2D) -> void:
	if body.name == "playerBody" or body.name == "playerBody2":
		playerInside = true
		playerNode = body

func onBodyExited(body: Node2D) -> void:
	if body == playerNode:
		playerInside = false
		playerNode = null
