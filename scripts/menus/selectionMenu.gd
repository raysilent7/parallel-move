extends Control

@onready var level1: Button = $level1
@onready var level2: Button = $level2
@onready var level3: Button = $level3

func _ready() -> void:
	loadBeatenLevels()
	level1.pressed.connect(onLevel1Pressed)
	level2.pressed.connect(onLevel2Pressed)
	level3.pressed.connect(onLevel3Pressed)

func onLevel1Pressed() -> void:
	get_tree().change_scene_to_file("res://objects/levels/level01.tscn")

func onLevel2Pressed() -> void:
	get_tree().change_scene_to_file("res://objects/levels/level02.tscn")

func onLevel3Pressed() -> void:
	get_tree().change_scene_to_file("res://objects/levels/level03.tscn")

func loadBeatenLevels() -> void:
	if level1.name == SaveData.lastLevel:
		level1.disabled = false
	elif level2.name == SaveData.lastLevel:
		level1.disabled = false
		level2.disabled = false
	elif level3.name == SaveData.lastLevel:
		level1.disabled = false
		level2.disabled = false
		level3.disabled = false
