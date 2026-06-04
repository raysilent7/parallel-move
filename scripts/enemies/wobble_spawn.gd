extends Marker2D

# Jujuba: Arraste a sua cena "Wobble.tscn" do painel de arquivos para cá no Inspetor!
@export var wobble_scene: PackedScene
@export var max_wobbles: int = 3
@export var spawn_interval: float = 4.0

@onready var timer = $Timer

func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	# Jujuba: Conta quantos nós no grupo "wobbles" existem na fase
	var current_wobble_count = get_tree().get_nodes_in_group("wobbles").size()
	
	# Se tiver menos que o máximo, cria um novo!
	if current_wobble_count < max_wobbles and wobble_scene:
		var new_wobble = wobble_scene.instantiate()
		
		# Adiciona na fase (como filho do Level, não do Spawner)
		get_parent().add_child(new_wobble)
		
		# Como a sua raiz é um nó genérico e o corpo está dentro, precisamos posicionar a raiz
		new_wobble.global_position = self.global_position
