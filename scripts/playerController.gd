extends Node2D

@onready var p1 = $playerBody
@onready var p2 = $playerBody2

var baseSpeed = 70

func _physics_process(_delta):
	var inputDir = Input.get_axis("left", "right")

	if inputDir == 0:
		p1.tryToMove(0)
		p2.tryToMove(0)
		return

	var xSpeed = inputDir * baseSpeed
	p1.tryToMove(xSpeed)
	p2.tryToMove(xSpeed)
