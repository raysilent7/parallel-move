extends Node2D

@export var pointA: Vector2 = Vector2(1.0,1.0)
@export var pointB: Vector2 = Vector2(1.0,1.0)
@onready var detector: Area2D = $detector

const speed: float = 0.3

var movingToA: bool = false
var lastPosition: Vector2

# Jujuba: A plataforma agora tem uma lista para carregar vários objetos ao mesmo tempo!
var passageiros: Array = []

func _ready() -> void:
	detector.body_entered.connect(onBodyEntered)
	detector.body_exited.connect(onBodyExited)

# Jujuba: Mudamos para _physics_process para a plataforma se mover no mesmo tempo da física da caixa!
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

# Jujuba: Agora a função passa por todo mundo que está na lista e move cada um deles
func movePassengers() -> void:
	var moveSpeed = global_position - lastPosition
	lastPosition = global_position
	
	for passageiro in passageiros:
		passageiro.movePlayerWithPlatform(moveSpeed)

func onBodyEntered(body):
	if body is CharacterBody2D:
		var alvo = body.get_parent()
		# Jujuba: Se o alvo sabe pegar carona e ainda não está no ônibus, entra na lista!
		if alvo.has_method("movePlayerWithPlatform"):
			if not passageiros.has(alvo):
				passageiros.append(alvo)

func onBodyExited(body):
	if body is CharacterBody2D:
		var alvo = body.get_parent()
		# Jujuba: Se o alvo desceu da plataforma, a gente tira ele da lista!
		if passageiros.has(alvo):
			passageiros.erase(alvo)
