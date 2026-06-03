extends Node2D

@export var pointA: Vector2 = Vector2(1.0,1.0)
@export var pointB: Vector2 = Vector2(1.0,1.0)
@export var speed: float = 0.3
@onready var detector: Area2D = $detector

var movingToA: bool = false
var lastPosition: Vector2
var passangers: Array = []

func _ready() -> void:
	detector.body_entered.connect(onBodyEntered)
	detector.body_exited.connect(onBodyExited)

func _physics_process(_delta: float) -> void:
	movePassengers()
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

func movePassengers() -> void:
	var moveSpeed = global_position - lastPosition
	lastPosition = global_position
	
	for passanger in passangers:
		passanger.movePlayerWithPlatform(moveSpeed)

func onBodyEntered(body):
	if body is CharacterBody2D:
		var alvo = body.get_parent()
		if alvo.has_method("movePlayerWithPlatform"):
			if not passangers.has(alvo):
				passangers.append(alvo)

func onBodyExited(body):
	if body is CharacterBody2D:
		var alvo = body.get_parent()
		if passangers.has(alvo):
			passangers.erase(alvo)
