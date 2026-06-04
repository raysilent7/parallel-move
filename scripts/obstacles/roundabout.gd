extends Area2D

func _ready() -> void:
	body_entered.connect(onBodyEntered)

func onBodyEntered(body: Node2D) -> void:
	print("aconteci 1")
	if body is CharacterBody2D and self.name == "right":
		print("aconteci 2")
		body.global_position = Vector2(-40.0, global_position.y)
	elif body is CharacterBody2D and self.name == "left":
		print("aconteci 3")
		body.global_position = Vector2(400.0, self.global_position.y)
