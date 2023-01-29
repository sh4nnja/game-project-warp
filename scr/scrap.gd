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
	scrapSetMode(lib.generateRandomNumber(0, 1, "int", false))

#######################################
########## METHODS / SIGNALS ##########
#######################################
func scrapSetMode(sMode):
	scrapMode = sMode
	if sMode == 0:
		texture.frame = 0
	elif sMode == 1:
		texture.frame = 1
