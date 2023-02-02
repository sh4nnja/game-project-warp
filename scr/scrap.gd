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

#######################################
########## METHODS / SIGNALS ##########
#######################################
func scrapModeManager(sMode) -> void:
	scrapMode = sMode
	if sMode == 0:
		texture.frame = 0
	elif sMode == 1:
		texture.frame = 1
