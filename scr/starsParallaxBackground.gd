extends ParallaxBackground
#######################################
########## INITIALIZATION #############
#######################################
onready var starParticles1: Node = $starsLayer1/stars
onready var starParticles2: Node = $starsLayer2/stars
onready var starParticles3: Node = $starsLayer3/stars
onready var starPool: Array = [starParticles1, starParticles2, starParticles3]
onready var spaceColor: Node = $starsLayer1/space
onready var spaceColor2: Node = $starsLayer2/space
onready var spaceColor3: Node = $starsLayer3/space
var minColor: float = 0.1
var maxColor: float = 1
#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	starManager()
	changeSpaceColor()

func _exit_tree():
	starPool.clear()
#######################################
########## METHODS / SIGNALS ##########
#######################################
func changeSpaceColor() -> void:
	spaceColor.modulate = lib.generateRandomColor(minColor, maxColor, 0.015)
	spaceColor2.modulate = lib.generateRandomColor(minColor, maxColor, 0.015)
	spaceColor3.modulate = lib.generateRandomColor(minColor, maxColor, 0.015)
func starManager() -> void:
	for i in starPool:
		i.preprocess = lib.generateRandomNumber(500, 600, "int", false)
		i.amount = lib.mapSize.x * 0.5
		i.emission_rect_extents = lib.mapSize
