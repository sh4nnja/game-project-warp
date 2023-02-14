extends Node2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var animation: Node = $animation

onready var spaceNode: Node = get_tree().root.get_node_or_null("space")
onready var physicsNode: Node = get_tree().root.get_node_or_null("space/2d/physics")
onready var playerNode: Node = get_tree().root.get_node_or_null("space/2d/player")

var minColor: float = 0.1
var maxColor: float = 1
#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	lib.spaceNode = spaceNode
	lib.physicsNode = physicsNode
	lib.playerNode = playerNode
	
	spawnRocks()
#######################################
########## METHODS / SIGNALS ##########
#######################################
func spawnRocks() -> void:
	for _i in lib.rockAmount:
		var rockI = lib.rock.instance()
		lib.physicsNode.call_deferred("add_child", rockI)
		rockI.global_position = lib.generateRandomSeparateVector2(150, lib.mapSize.x, "int", true)
		rockI = null
	return

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	clearPhysicsNode()
	
	lib.spaceNode = null
	lib.physicsNode = null
	lib.playerNode = null

func clearPhysicsNode():
	for i in physicsNode.get_children():
		for k in i.get_children():
			k.queue_free()
		i.queue_free()
