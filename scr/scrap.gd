extends RigidBody2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var texture: Node = $texture

var scrapMode: int
#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	scrapModeManager(lib.generateRandomNumber(0, 1, "int", false))

func _exit_tree():
	queue_free()
#######################################
########## METHODS / SIGNALS ##########
#######################################
func scrapModeManager(sMode) -> void:
	scrapMode = sMode
	if sMode == 0:
		texture.frame = 0
	elif sMode == 1:
		texture.frame = 1
	rotation_degrees = lib.generateRandomNumber(0, 180, "int", true)
