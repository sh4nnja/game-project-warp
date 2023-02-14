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
########## CONFIGURATION ##############
#######################################
onready var spaceNode: Node
onready var physicsNode: Node 
onready var playerNode: Node 

var mapSize: Vector2 = Vector2(3500, 3500)
var rockSizes: Vector2 = Vector2(1, 5)
var rockAmount: int = 250

var damageFromRock: int = 15

var selfDestructTimer: Vector2 = Vector2(5, 10)

var zoomThreshold: Vector2 = Vector2(1, .5)

var bulletAmount: int = 250
var blasterDamage: int = 5
var scrapMultiplier: int = 4

var selfDestructMode: bool = true

#######################################S
###### OBJECTS / tEXTURES #############
#######################################
onready var spaceScene: PackedScene = preload("res://scn/space/space.tscn")
onready var rock: PackedScene = preload("res://pck/rock/rock.tscn")
onready var rockFragment: PackedScene = preload("res://pck/fx/rockFragments/rockFragments.tscn")
onready var combatText: PackedScene = preload("res://pck/fx/combatText/combatText.tscn")
onready var circleEx: PackedScene = preload("res://pck/fx/circleExplosion/circleExplosion.tscn")
onready var bullet: PackedScene = preload("res://pck/ammo/bullet/bullet.tscn")
onready var scrap: PackedScene = preload("res://pck/scrap/scrap.tscn")

#######################################
########## INITIALIZATION #############
#######################################
var lifeModulates: Array = [Color(1, 1, 1), Color(1, 0.5, 0), Color(1, 0, 0), Color(0, 1, 1), Color(.5, .5, .5), Color(.1, .1, .1), Color(0, 1, 0.5)]

var camera: Node
var noise: Object = OpenSimplexNoise.new()
var noiseSpeed: float = 1
var noiseStrength: float = 10
var noiseDecay: float = 5
var noiseTrack: float = 0.0
var shakeStrength: float
var amount: float = 1
var doShake: bool = false
#######################################
######## VIRTUAL CODES / START ########
#######################################
func _physics_process(delta):
	screenShakeManager(delta)

#######################################
########## RANDOM GENERATORS ##########
#######################################
func generateRandomNumber(minVal: float, maxVal: float, type: String, includeNegatives: bool):
	var rng: Object = RandomNumberGenerator.new()
	rng.randomize()
	var output
	if includeNegatives: output = rng.randf_range(minVal, maxVal) * (rng.randi() % 2 * 2 - 1)
	else: output = rng.randf_range(minVal, maxVal)
	match type:
		"int": output = round(output)
		"float": output = stepify(output, 0.01)
		"randomInt": output = rng.randi()
		"randomfloat": output = stepify(rng.randf(), 0.01)
	return output

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

func generateRandomColor(minVal: float, maxVal: float, opacity: float) -> Color:
	var color: Color = Color(
	lib.generateRandomNumber(minVal, maxVal, "float",  false), 
	lib.generateRandomNumber(minVal, maxVal, "float", false), 
	lib.generateRandomNumber(minVal, maxVal, "float",  false),
	opacity
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
func rockFragmentFX(position: Vector2, projectile: String, color: Color, scale: float) -> void:
	if physicsNode:
		var rFInst: Object = rockFragment.instance()
		rFInst.self_modulate = color
		rFInst.global_position = position
		match projectile:
			"collision": 
				amount = 5
				rFInst.rAmount = 175
				rFInst.rScale = scale
			"blaster": 
				rFInst.rAmount = 50
				rFInst.rScale = scale
			"explosion":
				rFInst.rAmount = 150
				rFInst.rScale = scale
				rFInst.scale = Vector2(12, 12)
				combatTextManager(position, "Critical", Color(1, 1, 1))
		physicsNode.add_child(rFInst)
		rFInst = null
	pass
#######################################
####### CIRCLE EXPLOSION FX ###########
#######################################
func circleExplosionFX(position: Vector2, scale: Vector2) -> void:
	if physicsNode:
		var cEInst: Object = circleEx.instance()
		cEInst.scale = scale
		cEInst.cAmount = 256
		physicsNode.add_child(cEInst)
		cEInst.global_position = position
		cEInst = null
	pass

#######################################
########## COMBAT TEXTS FX ############
#######################################
func combatTextManager(position: Vector2, mode: String, color: Color) -> void:
	if physicsNode:
		var cTInst: Node = combatText.instance()
		cTInst.mode = mode
		cTInst.color = color 
		physicsNode.call_deferred("add_child", cTInst)
		cTInst.global_position = position + generateRandomSeparateVector2(96, 128, "int", true)
	pass

#######################################
########## CAMERA SHAKE FX ############
#######################################
func screenShakeManager(delta) -> void:
	if playerNode:
		camera = playerNode.get_node_or_null("ship/camera")
		noise.seed = lib.generateRandomNumber(0, 0, "randomInt", false)
		noise.period = 2
		if doShake:
			shakeStrength = noiseStrength * amount * (camera.zoom.x / 2)
			camera.zoom -= Vector2(0.05, 0.05)
			doShake = false
		noiseTrack += delta * noiseSpeed
		shakeStrength = lerp(shakeStrength, 0, noiseDecay * delta)
		if camera:
			camera.offset = Vector2(noise.get_noise_2d(1, noiseTrack) * shakeStrength, noise.get_noise_2d(5, noiseTrack) * shakeStrength)

#######################################
########## FRAME FREEZE ###############
#######################################
func frameFreezeManager(timeScale: float, duration: float) -> void:
	spaceNode.get_node("animation").play("darkenScene")
	Engine.time_scale = timeScale
	playerNode.get_node("ship").cameraDesired = Vector2(2.5, 2.5)
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	playerNode.get_node("ship").cameraDesired = Vector2(1, 1)
	spaceNode.get_node("animation").playback_speed = duration
	spaceNode.get_node("animation").play_backwards("darkenScene")
	Engine.time_scale = 1.0
	pass
#######################################
########## ARCHIVES ###################
#######################################

#func movementCode() -> void:
#	if lib.checkIfDesktopElseMobile():
#		look_at(get_global_mouse_position())
#		if Input.is_action_pressed("fw"):
#			velocity += transform.x * speed
#			interface.animateBar(false)
#		elif Input.is_action_just_released("fw"):
#			interface.animateBar(true)
#	else:
#		pass

#func checkIfDesktopElseMobile() -> bool:
#	var platform: String
#	platform = OS.get_name()
#	if platform in ["Android", "BlackBerry 10", "iOS"]:
#		return false
#	else:
#		return true
