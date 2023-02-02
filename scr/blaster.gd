extends Node2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var physicsNode: Node = get_tree().root.get_node("space/2d/physics")

onready var leftBarrel: Node = $left
onready var rightBarrel: Node = $right

var bulletPool: Array 

const BULLETAMOUNT: int = 250

var side: int = 0

#######################################
####### OBJECTS AND tEXTURE ###########
#######################################
onready var texture1: Node = $left/texture
onready var texture2: Node = $right/texture2

var bullet: Object = preload("res://pck/ammo/bullet/bullet.tscn")

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready() -> void:
	bulletManager(BULLETAMOUNT)

func _physics_process(_delta) -> void:
	firingManager()

#######################################
########## METHODS / SIGNALS ##########
#######################################
func bulletManager(bCount) -> void:
	bulletPool.clear()
	for _i in range(bCount):
		var bulletInst = bullet.instance()
		bulletInst.set_physics_process(false)
		bulletPool.append(bulletInst)
		get_parent().get_node("shipInterface").ammoCountManager(bulletPool.size() - 1, BULLETAMOUNT)

func firingManager() -> void:
	if get_parent().is_in_group("attachment") and Input.is_action_just_pressed("fire") and bulletPool.size() > 0:
		var pooledBullet: Object = bulletPool[bulletPool.size() - 1]
		physicsNode.call_deferred("add_child", pooledBullet)
		if side == 0:
			pooledBullet.position = leftBarrel.global_position
			pooledBullet.rotation_degrees = leftBarrel.global_rotation_degrees
			side = 1
		elif side == 1:
			pooledBullet.position = rightBarrel.global_position
			pooledBullet.rotation_degrees = rightBarrel.global_rotation_degrees
			side = 0
		pooledBullet.set_physics_process(true)
		bulletPool.remove(bulletPool.size() - 1)
		get_parent().get_node("shipInterface").ammoCountManager(bulletPool.size() - 1, BULLETAMOUNT)
	texture1.self_modulate = get_parent().get_parent().get_node("texture").self_modulate
	texture2.self_modulate = get_parent().get_parent().get_node("texture").self_modulate
	return
