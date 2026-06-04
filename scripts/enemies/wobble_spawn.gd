extends Marker2D

@export var wobble_scene: PackedScene
@export var max_wobbles: int = 3
@export var spawn_interval: float = 4.0
@export var inverted: bool = false # Certifique-se de ativar no Inspetor do spawner do Void!

@onready var timer = $Timer

func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	var current_wobble_count = get_tree().get_nodes_in_group("wobbles").size()
	
	if current_wobble_count < max_wobbles and wobble_scene:
		var new_wobble = wobble_scene.instantiate()
		
		# Jujuba: Super proteção! Configura o modo invertido se a raiz for o corpo OU se for o Node2D genérico
		if new_wobble is CharacterBody2D:
			new_wobble.inverted = self.inverted
		elif new_wobble.has_node("wobbleBody"):
			new_wobble.get_node("wobbleBody").inverted = self.inverted
		
		get_parent().add_child(new_wobble)
		new_wobble.global_position = self.global_position
