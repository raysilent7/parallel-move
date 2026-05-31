extends Node2D

@onready var p1 = $playerBody
@onready var p2 = $playerBody2

var baseSpeed = 100

func _physics_process(delta):
	var inputDir = Input.get_axis("left", "right")

	if inputDir == 0:
		p1.tryToMove(0)
		p2.tryToMove(0)
		return

	var xSpeed = inputDir * base

	# Cada personagem tenta se mover
	var p1_ok = p1.tryToMove()
	var p2_ok = p2.tryToMove()

	# Se qualquer um falhar → ambos param
	if not p1_ok or not p2_ok:
		p1.tentar_mover(0)
		p2.tentar_mover(0)
