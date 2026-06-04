extends Area2D

func _ready() -> void:
	body_entered.connect(onBodyEntered)

func onBodyEntered(body: Node2D) -> void:
	print("aconteci 1")
	if body is CharacterBody2D and self.name == "right":
		print("aconteci 2")
		body.get_parent().moveTo(Vector2(-40.0, body.global_position.y), Vector2(-40.0, body.global_position.y+64.0))
	elif body is CharacterBody2D and self.name == "left":
		print("aconteci 3")
		body.get_parent().moveTo(Vector2(1152.0, body.global_position.y), Vector2(1152.0, body.global_position.y+64.0))
