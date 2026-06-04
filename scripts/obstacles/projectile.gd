extends Area2D

var speed: float = 300.0
var startingPoint: Vector2 = Vector2(1.1, 1.1)

func _ready() -> void:
	print("aconteci")
	startingPoint = global_position

func _process(delta: float) -> void:
	var projectileDirection: String = get_tree().current_scene.player.getPlayerFacingDirection()

	if projectileDirection == "right":
		global_position.x += speed * delta
	else:
		global_position.x -= speed * delta

	if global_position.distance_to(startingPoint) > 1000.0:
		queue_free()

func onAreaEntered(area: Area2D) -> void:
	#TODO: refatorar quando tiver primeiro inimigo
	if area.is_in_group("enemy"):
		queue_free()
