extends Node2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var leftBarrel: Node = $left
onready var rightBarrel: Node = $right

var bulletPool: Array 
var bulletAmount: int = 250
var bulletCount: int

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
func _ready():
	prepareBullets()

func _physics_process(_delta):
	firingManager()

#######################################
########## METHODS / SIGNALS ##########
#######################################
func prepareBullets() -> void:
	for _i in bulletAmount:
		var bulletInst = bullet.instance()
		bulletPool.append(bulletInst)

func firingManager() -> void:
	bulletCount = bulletPool.size()
	if get_parent().is_in_group("attachment") and Input.is_action_just_pressed("fire") and bulletCount > 0:
		get_tree().root.get_node("space/2d/physics").add_child(bulletPool[0])
		if side == 0:
			bulletPool[0].position = leftBarrel.global_position
			bulletPool[0].rotation_degrees = leftBarrel.global_rotation_degrees
			side = 1
		elif side == 1:
			bulletPool[0].position = rightBarrel.global_position
			bulletPool[0].rotation_degrees = rightBarrel.global_rotation_degrees
			side = 0
		bulletPool.remove(0)
		get_parent().get_node("shipInterface").updateAmmoCount(bulletCount, bulletAmount)
	texture1.self_modulate = get_parent().get_parent().get_node("texture").self_modulate
	texture2.self_modulate = get_parent().get_parent().get_node("texture").self_modulate
