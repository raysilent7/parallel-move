extends Node

@onready var walk: AudioStreamPlayer2D = $walking
@onready var dragginBox: AudioStreamPlayer2D = $dragginBox
@onready var steamLeak: AudioStreamPlayer2D = $steamLeak

var silenceMin: int = 20
var silenceMax: int = 30
var lastTrack = null
var playing: bool = false
var generalVol: float = 1.0
var musicVol: float = 1.0
var FXVol: float = 1.0
var muteMusic: bool = false
var muteFX: bool = false

func _ready() -> void:
	$music1.finished.connect(onTrackFinished)
	loadSettings()

func setGeneralVolume(value: float):
	generalVol = value
	updateVolumes()

func setMusicVolume(value: float):
	musicVol = value
	updateVolumes()

func setFXVolume(value: float):
	FXVol = value
	updateVolumes()

func setMuteMusic(value: bool):
	muteMusic = value
	updateVolumes()

func setMuteFX(value: bool):
	muteFX = value
	updateVolumes()

func updateVolumes():
	var music: Array = get_tree().get_nodes_in_group("music")
	var effects: Array = get_tree().get_nodes_in_group("effect")

	for m in music:
		m.volume_db = linear_to_db(generalVol * musicVol)
		if muteMusic:
			m.volume_db = linear_to_db(generalVol * 0)

	for e in effects:
		e.volume_db = linear_to_db(generalVol * FXVol)
		if muteFX:
			e.volume_db = linear_to_db(generalVol * 0)
	
	saveSettings()

func onTrackFinished():
	if not playing:
		return

	var waitTime = randf_range(silenceMin, silenceMax)
	await get_tree().create_timer(waitTime).timeout

	if playing:
		playMusic1()

func startMusicSystem():
	if not playing:
		playing = true
		playMusic1()

func stopMusicSystem():
	playing = false
	lastTrack.stop()

func saveSettings():
	var data: Dictionary = {
		"generalVol": generalVol,
		"musicVol": musicVol,
		"FXVol": FXVol,
		"muteMusic": muteMusic,
		"muteFX": muteFX
	}
	var file: FileAccess = FileAccess.open("user://settings.save", FileAccess.WRITE)
	file.store_var(data)

func loadSettings():
	if not FileAccess.file_exists("user://settings.save"):
		return
	var file: FileAccess = FileAccess.open("user://settings.save", FileAccess.READ)
	var data: Dictionary = file.get_var()
	generalVol = data["generalVol"]
	musicVol = data["musicVol"]
	FXVol = data["FXVol"]
	muteMusic = data["muteMusic"]
	muteFX = data["muteFX"]
	updateVolumes()

## MUSICAS

func playMusic1():
	$music1.play()

## EFEITOS SONOROS
func playDeath():
	$death.play()

func playDragginBox():
	if not dragginBox.playing:
		walk.stop()
		dragginBox.play()

func playJumping():
	$jumping.play()

func playLanding():
	$landing.play()

func playHit():
	$hit.play()

func playShoot():
	$shoot.play()

func playThrow():
	$throw.play()

func playWalking():
	if not walk.playing and not dragginBox.playing:
		walk.play()

func playWobble():
	$wobble.play()

func playSteamLeak():
	if not steamLeak.playing:
		steamLeak.play()

func stopSteamLeak():
	steamLeak.stop()
