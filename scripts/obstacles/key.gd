extends Area2D

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		GameState.hasKey = true
		get_parent().call_deferred("queue_free")
