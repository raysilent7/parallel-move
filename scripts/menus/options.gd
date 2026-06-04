extends Node2D

@onready var music_slider: HSlider = $HSlider
@onready var effects_slider: HSlider = $HSlider2
@onready var exit_label: Label = $Label4

func _ready() -> void:
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	
	effects_slider.min_value = 0.0
	effects_slider.max_value = 1.0
	effects_slider.step = 0.05

	music_slider.value = AudioManager.musicVol
	effects_slider.value = AudioManager.FXVol

	music_slider.value_changed.connect(on_music_slider_changed)
	effects_slider.value_changed.connect(on_effects_slider_changed)

	exit_label.gui_input.connect(on_exit_gui_input)
	exit_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func on_music_slider_changed(value: float) -> void:
	AudioManager.setMusicVolume(value)


func on_effects_slider_changed(value: float) -> void:
	AudioManager.setFXVolume(value)


func on_exit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		queue_free()
