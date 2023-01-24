#######################################
# PENTANNEX STUDIOS ----------------- #
# ----------------------------------- #
# PentaCODEXX LIBRARY --------------- #
# VERSION 0.1 ----------------------- #
# ----------------------------------- #
# PROJECT E ------------------------- #
# VERSION ALPHA --------------------- #
#######################################

extends Node

#######################################
########## INITIALIZATION #############
#######################################
var lifeModulates: Array = [Color(1, 1, 1), Color(1, 0.5, 0), Color(1, 0, 0), Color(0, 1, 1), Color(.5, .5, .5), Color(.1, .1, .1)]

var blasterDamage: int = 10
#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	initScreenShakeManager()

var gDelta: float
func _physics_process(delta):
	gDelta = delta
	
	screenShakeManager()

#######################################
########## RANDOM GENERATORS ##########
#######################################
func generateRandomNumber(minVal: float, maxVal: float, type: String, includeNegatives: bool):
	var rng: Object = RandomNumberGenerator.new()
	var negatives: Array = [-1, 1]
	rng.randomize()
	var output 
	if type == "int": output = int(rng.randf_range(minVal, maxVal))
	elif type == "float": output = stepify(rng.randf_range(minVal, maxVal), 0.01)
	elif type == "randomInt": output = rng.randi()
	elif type == "randomfloat": output = stepify(rng.randf(), 0.01)
	if includeNegatives:
		output *= negatives[rng.randi() % negatives.size()]
		return output
	else: return output

func generateRandomVector2(minVal: float, maxVal: float, type: String, includeNegatives: bool) -> Vector2:
	var output: Vector2 = Vector2()
	var returnOutput: float
	returnOutput = lib.generateRandomNumber(minVal, maxVal, type, includeNegatives)
	output = Vector2(returnOutput, returnOutput)
	return output

func generateRandomSeparateVector2(minVal: float, maxVal: float, type: String, includeNegatives: bool) -> Vector2:
	var output: Vector2 = Vector2()
	output.x = lib.generateRandomNumber(minVal, maxVal, type, includeNegatives)
	output.y = lib.generateRandomNumber(minVal, maxVal, type, includeNegatives)
	return output

func generateRandomColor(minVal: float, maxVal: float) -> Color:
	var color: Color = Color(
	lib.generateRandomNumber(minVal, maxVal, "float",  false), 
	lib.generateRandomNumber(minVal, maxVal, "float", false), 
	lib.generateRandomNumber(minVal, maxVal, "float",  false)
	)
	return color 

#######################################
########## NODE REPARENT ##############
#######################################
func reparent(child: Node, newParent: Node) -> void:
	var oldParent = child.get_parent()
	oldParent.remove_child(child)
	newParent.add_child(child)

#######################################
########## TRAIL MANAGER ##############
#######################################

func trailManager(trail: Node, node: Node, trailLength: int) -> void:
	var trailPoint: Vector2 = node.global_position
	trail.global_position = Vector2(0, 0)
	trail.global_rotation = 0
	trail.add_point(trailPoint)
	while trail.get_point_count() > trailLength:
		trail.remove_point(0)

#######################################
########## ROCK FRAGMENT FX ###########
#######################################
onready var rockFragment = preload("res://pck/fx/rockFragments/rockFragments.tscn")

func rockFragmentFX(position: Vector2, projectile: String, color: Color, scale: float) -> void:
	var rFInst: Object = rockFragment.instance()
	var node: Node = get_tree().root.get_node("space/2d/physics")
	node.add_child(rFInst)
	rFInst.self_modulate = color
	rFInst.global_position = position
	match projectile:
		"collision": 
			amount = 5
			rFInst.emit(75, scale)
		"blaster": rFInst.emit(50, scale)
		"explosion":
			rFInst.emit(75, scale)
			rFInst.scale = Vector2(10, 10)
			combatTextManager(position, "Critical", Color(1, 1, 1))
	rFInst = null

#######################################
####### CIRCLE EXPLOSION FX ###########
#######################################
onready var circleEx: Object = preload("res://pck/fx/circleExplosion/circleExplosion.tscn")

func circleExplosionFX(position: Vector2, scale: Vector2) -> void:
	var cEInst: Object = circleEx.instance()
	var node: Node = get_tree().root.get_node("space/2d/physics")
	node.add_child(cEInst)
	cEInst.global_position = position
	cEInst.scale = scale
	cEInst.emit(512)
	cEInst = null

#######################################
########## CAMERA SHAKE FX ############
#######################################
var camera: Node
var noise: Object = OpenSimplexNoise.new()
var noiseSpeed: float = 10
var noiseStrength: float = 20
var noiseDecay: float = 5
var noiseTrack: float = 0.0
var shakeStrength: float
var amount: float = 1
var doShake: bool = false

func initScreenShakeManager() -> void:
	camera = get_tree().root.get_node_or_null("space/2d/player/ship/camera")
	noise.seed = lib.generateRandomNumber(0, 0, "randomInt", false)
	noise.period = 2

func screenShakeManager() -> void:
	if doShake:
		shakeStrength = noiseStrength * amount * (camera.zoom.x / 2)
		doShake = false
	noiseTrack += gDelta * noiseSpeed
	shakeStrength = lerp(shakeStrength, 0, noiseDecay * gDelta)
	camera.offset = Vector2(noise.get_noise_2d(1, noiseTrack) * shakeStrength, noise.get_noise_2d(100, noiseTrack) * shakeStrength)

#######################################
########## COMBAT TEXTS FX ############
#######################################
onready var combatText: Object = preload("res://pck/fx/combatText/combatText.tscn")

func combatTextManager(position: Vector2, mode: String, color: Color):
	var cTInst: Object = combatText.instance()
	var node: Node = get_tree().root.get_node("space/2d/physics")
	node.add_child(cTInst)
	cTInst.position = position + generateRandomSeparateVector2(0, 120, "int", true)
	cTInst.showCT(mode, color)
