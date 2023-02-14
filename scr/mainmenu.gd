extends Node2D
#######################################
########## INITIALIZATION #############
#######################################
onready var playBtn: Node = $userInterfaceLayer/userInterface/play
var minColor: float = 0.1
var maxColor: float = 1
#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	pass

#######################################
########## METHODS / SIGNALS ##########
#######################################
func _on_play_pressed() -> void:
	var _cScene := get_tree().change_scene_to(lib.spaceScene)
	return

func _on_play_mouse_exited() -> void:
	playBtn.modulate = Color(1, 1, 1, 1)
	return

func _on_play_mouse_entered() -> void:
	playBtn.modulate = lib.generateRandomColor(minColor, maxColor, 1)
	return


