extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $playerAnim
@export var inverted: bool = false

var baseSpeed: int = 100
var baseGravity: int = 300
var baseJumpForce: int = -300
var canJump: bool = true
var locked: bool = false

func _ready() -> void:
	animation.flip_h = inverted
	invertValues()

func _physics_process(_delta: float) -> void:
	applyGravity()
	jump()
	move_and_slide()
	resolveAnimation()

func invertValues() -> void:
	if inverted:
		up_direction = Vector2.DOWN
		baseGravity *= -1
		baseJumpForce *= -1

func tryToMove() -> bool:
	velocity.x = baseSpeed
	move_and_slide()

	if is_on_wall():
		return false

	return true

func applyGravity() -> void:
	if not is_on_floor():
		velocity.y += baseGravity * 0.070
		if inverted:
			velocity.y = max(velocity.y, baseGravity)
		else:
			velocity.y = min(velocity.y, baseGravity)
	else:
		velocity.y = 0
		canJump = true

func jump() -> void:
	if Input.is_action_just_pressed("jump") and canJump:
		velocity.y = baseJumpForce
		canJump = false

func resolveAnimation() -> void:
	if velocity.x == 0 and (is_on_floor() or inverted):
		animation.play("idle")
	elif velocity.x != 0:
		animation.play("walking")
	else:
		animation.play("jumping")
