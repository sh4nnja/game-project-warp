extends Node2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var starParticles1: Node = $"2d/starsParallaxBackground/starsLayer1/stars"
onready var starParticles2: Node = $"2d/starsParallaxBackground/starsLayer2/stars"
onready var starParticles3: Node = $"2d/starsParallaxBackground/starsLayer3/stars"

onready var physics: Node = $"2d/physics"
onready var animation: Node = $animation

onready var starPool: Array = [starParticles1, starParticles2, starParticles3]

#######################################
####### OBJECTS AND tEXTURE ###########
#######################################
var rockAmount: int = lib.rockAmount
var rockCount: int

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	starManager()
	spawnRocks()

#######################################
########## METHODS / SIGNALS ##########
#######################################
func starManager() -> void:
	for i in starPool:
		i.preprocess = lib.generateRandomNumber(500, 600, "int", false)

func spawnRocks() -> void:
	var rock: Object = load("res://pck/rock/rock.tscn")
	for _i in rockAmount:
		var rockI = rock.instance()
		physics.add_child(rockI)
		rockI.global_position = lib.generateRandomSeparateVector2(250, 7500, "float", true)
		rockI = null
	return
