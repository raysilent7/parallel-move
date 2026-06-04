extends Node2D

@onready var buttonArea: Area2D = $buttonArea
@onready var buttonAnim: AnimatedSprite2D = $buttonAnim 

func _ready() -> void:
	buttonArea.body_entered.connect(onBodyEntered)
	buttonArea.body_exited.connect(onBodyExited)

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		updateButtonState()

func onBodyExited(body: Node2D) -> void:
	if body is CharacterBody2D:
		updateButtonState()

func updateButtonState() -> void:
	var bodiesInside: int = 0
	
	for b in buttonArea.get_overlapping_bodies():
		if b is CharacterBody2D:
			bodiesInside += 1
			
	if bodiesInside > 0:
		GameState.buttonPressed = true
		buttonAnim.play("pressed")
	else:
		GameState.buttonPressed = false
		buttonAnim.play("unpressed")
