extends Area2D

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	body_exited.connect(onBodyExited)

func onBodyEntered(body: Node2D) -> void:
	if body.name == "playerBody" or body.name == "playerBody2":
		body.get_parent().activateUpButton()

func onBodyExited(body: Node2D) -> void:
	if body.name == "playerBody" or body.name == "playerBody2":
		body.get_parent().deactivateUpButton()
