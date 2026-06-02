extends Node2D

@export var pointA: Vector2 = Vector2(1.0,1.0)
@export var pointB: Vector2 = Vector2(1.0,1.0)
@onready var detector: Area2D = $detector

const speed: float = 0.3

var movingToA: bool = false
var player: Node2D
var lastPosition: Vector2

func _ready() -> void:
	detector.body_entered.connect(onBodyEntered)
	detector.body_exited.connect(onBodyExited)

func _process(_delta: float) -> void:
	movePlayer()
	movePlatform()

func movePlatform() -> void:
	if movingToA:
		global_position = global_position.move_toward(pointA, speed)
		if global_position == pointA:
			movingToA = false
	else:
		global_position = global_position.move_toward(pointB, speed)
		if global_position == pointB:
			movingToA = true

func movePlayer() -> void:
	var moveSpeed = global_position - lastPosition
	lastPosition = global_position
	
	if player:
		player.movePlayerWithPlatform(moveSpeed)

func onBodyEntered(body):
	if body is CharacterBody2D:
		player = body.get_parent()

func onBodyExited(body):
	if body is CharacterBody2D:
		player = null
