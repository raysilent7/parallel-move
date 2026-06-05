extends Node

var playerName: String = ""
var playerId: String = ""
var lastLevel: String = ""

func _ready():
	loadData()
	if playerId == "":
		generateNewPlayer()

func generateNewPlayer():
	playerId = str(randi()) + str(Time.get_ticks_msec())
	playerName = "Player" + playerId
	lastLevel = "level1"
	saveData()

func saveData():
	var data: Dictionary = {
		"playerName": playerName,
		"playerId": playerId,
		"lastLevel": lastLevel
	}
	var file: FileAccess = FileAccess.open("user://player.save", FileAccess.WRITE)
	file.store_var(data)

func loadData():
	if not FileAccess.file_exists("user://player.save"):
		return
	var file: FileAccess = FileAccess.open("user://player.save", FileAccess.READ)
	var data: Dictionary = file.get_var()
	playerName = data.get("playerName", "Player")
	playerId = data.get("playerId", "")
	lastLevel = data.get("lastLevel", "")
