extends Node2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var leftBarrel: Node = $left
onready var rightBarrel: Node = $right

var bulletPool: Array 

var side: int = 0

#######################################
####### OBJECTS AND tEXTURE ###########
#######################################
onready var texture1: Node = $left/texture
onready var texture2: Node = $right/texture2

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready() -> void:
	bulletManager(lib.bulletAmount)

func _physics_process(_delta) -> void:
	firingManager()

func _exit_tree():
	clearBulletPool()
#######################################
########## METHODS / SIGNALS ##########
#######################################
func bulletManager(bCount) -> void:
	bulletPool.clear()
	for _i in range(bCount):
		var bulletInst: Node = lib.bullet.instance()
		bulletInst.set_physics_process(false)
		bulletPool.append(bulletInst)
		if get_parent().get_node_or_null("shipInterface"):
			get_parent().get_node("shipInterface").ammoCountManager(bulletPool.size(), lib.bulletAmount)

func firingManager() -> void:
	if get_parent().is_in_group("attachment") and Input.is_action_just_pressed("fire") and bulletPool.size() > 0 and lib.physicsNode:
		var pooledBullet: Object = bulletPool[bulletPool.size() - 1]
		lib.physicsNode.call_deferred("add_child", pooledBullet)
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
		if get_parent().get_node_or_null("shipInterface"):
			get_parent().get_node("shipInterface").ammoCountManager(bulletPool.size(), lib.bulletAmount)
	texture1.self_modulate = get_parent().get_parent().get_node("texture").self_modulate
	texture2.self_modulate = get_parent().get_parent().get_node("texture").self_modulate
	return

func clearBulletPool():
	var i: int = 0
	while i < lib.bulletAmount and bulletPool.size() > 0:
		for j in bulletPool[0].get_children():
			j.queue_free()
		bulletPool[0].queue_free()
		bulletPool.remove(0)
		i += 1
	bulletPool.clear()
