extends Node2D

@onready var buttonArea: Area2D = $buttonArea
@onready var buttonAnim: AnimatedSprite2D = $buttonAnim 

func _ready() -> void:
	buttonArea.body_entered.connect(onBodyEntered)
	buttonArea.body_exited.connect(onBodyExited)
	buttonAnim.play("unpressed")

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		atualizar_estado_botao()

func onBodyExited(body: Node2D) -> void:
	if body is CharacterBody2D:
		atualizar_estado_botao()

func atualizar_estado_botao() -> void:
	var corpos_no_botao: int = 0
	
	for b in buttonArea.get_overlapping_bodies():
		if b is CharacterBody2D:
			corpos_no_botao += 1
			
	if corpos_no_botao > 0:
		GameState.buttonPressed = true
		buttonAnim.play("pressed")
	else:
		GameState.buttonPressed = false
		buttonAnim.play("unpressed")
