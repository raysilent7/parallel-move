extends Area2D

func _ready() -> void:
	body_entered.connect(onBodyEntered)

func onBodyEntered(body: Node2D) -> void:
	if body.name == "playerBody" or body.name == "playerBody2":
		body.get_parent().death()
		
