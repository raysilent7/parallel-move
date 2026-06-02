extends Node2D

@onready var p1 = $playerBody
@onready var p2 = $playerBody2

var baseSpeed: int = 100

func _physics_process(_delta) -> void:
	var inputDir = Input.get_axis("left", "right")
	var xSpeed = inputDir * baseSpeed

	if inputDir == 0:
		p1.tryToMove(0)
		p2.tryToMove(0)
		return

	p1.tryToMove(xSpeed)
	p2.tryToMove(xSpeed)

	if p1.global_position.x > p2.global_position.x or p1.global_position.x < p2.global_position.x:
		p1.global_position.x = p2.global_position.x
		p1.tryToMove(0)
		if p1.global_position.x > p2.global_position.x or p1.global_position.x < p2.global_position.x:
			p2.global_position.x = p1.global_position.x
