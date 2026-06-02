extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $playerAnim
@export var inverted: bool = false

var baseGravity: int = 300
var baseJumpForce: int = -270
var canJump: bool = true

func _ready() -> void:
	startInvertedPlayer()

func _physics_process(_delta: float) -> void:
	applyGravity()
	jump()
	resolveAnimation()

func startInvertedPlayer() -> void:
	if inverted:
		animation.flip_h = inverted
		up_direction = Vector2.DOWN
		baseGravity *= -1
		baseJumpForce *= -1

func invertValues() -> void:
	if GameState.gravityInverted:
		animation.flip_v = true
		up_direction = Vector2.UP if inverted else Vector2.DOWN
		baseGravity *= -1
		baseJumpForce *= -1
	else:
		animation.flip_v = false
		up_direction = Vector2.DOWN if inverted else Vector2.UP
		baseGravity *= -1
		baseJumpForce *= -1

func tryToMove(speed) -> void:
	velocity.x = speed
	move_and_slide()

func applyGravity() -> void:
	if not is_on_floor():
		velocity.y += baseGravity * 0.070
		if not GameState.gravityInverted:
			if inverted:
				velocity.y = max(velocity.y, baseGravity)
			else:
				velocity.y = min(velocity.y, baseGravity)
		else:
			if inverted:
				velocity.y = min(velocity.y, baseGravity)
			else:
				velocity.y = max(velocity.y, baseGravity)
	else:
		velocity.y = 0
		canJump = true

func jump() -> void:
	if Input.is_action_just_pressed("jump") and canJump:
		velocity.y = baseJumpForce
		canJump = false

func resolveAnimation() -> void:
	if Input.get_axis("left", "right") == 0 and is_on_floor():
		animation.play("idle")
	elif Input.get_axis("left", "right") > 0:
		animation.play("walking")
		animation.flip_h = true if inverted else false
	elif Input.get_axis("left", "right") < 0:
		animation.play("walking")
		animation.flip_h = false if inverted else true
	else:
		animation.play("jumping")
