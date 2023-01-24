extends RigidBody2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var texture: Node = $texture
onready var shape: Node = $shape

var rockMode: int

var rockScale: Vector2 = Vector2(5, 35)
var minColor: float = 0.1
var maxColor: float = 1

var rockSquarePoly: PoolVector2Array = [Vector2(-7.7, -10), Vector2(-7.7, -7.7), Vector2(-10, -7.7), Vector2(-10, 7.7), Vector2(-7.7, 7.7), Vector2(-7.7, 10), Vector2(7.7, 10), Vector2(7.7, 7.7), Vector2(10, 7.7), Vector2(10, -7.7), Vector2(7.7, -7.7), Vector2(7.7, -10), Vector2(-7.7, -10)]
var rockTrianglePoly: PoolVector2Array = [Vector2(-10, 5), Vector2(-8, 5), Vector2(-7.5, -2.5), Vector2(-5, -2.5), Vector2(-5, -7.5), Vector2(-2.5, -7.5), Vector2(-2.5, -10), Vector2(2.5, -10), Vector2(2.5, -7.5), Vector2(5, -7.5), Vector2(5, -2.5), Vector2(7.5, -2.5), Vector2(7.5, 5), Vector2(10, 4.5), Vector2(10, 10), Vector2(-10, 10)]
var rockCirclePoly: PoolVector2Array = [Vector2(-5, -10), Vector2(-5, -7.5), Vector2(-7.5, -7.5), Vector2(-7.5, -5), Vector2(-10, -5), Vector2(-10, 5), Vector2(-7.5, 5), Vector2(-7.5, 7.5), Vector2(-5, 7.5), Vector2(-5, 10), Vector2(5, 10), Vector2(5, 7.5), Vector2(7.5, 7.5), Vector2(7.5, 5), Vector2(10, 5), Vector2(10, -5), Vector2(7.5, -5), Vector2(7.5, -7.5), Vector2(5, -7.5), Vector2(5, -10)]

var hp: int

#######################################
####### OBJECTS AND tEXTURE ###########
#######################################


#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	randomRock()

#######################################
########## METHODS / SIGNALS ##########
#######################################
func randomRock() -> void:
	rockMode = lib.generateRandomNumber(0, 2, "int", false)
	match rockMode:
		0: 
			texture.frame = 0 
			shape.polygon = rockSquarePoly
			
		1: 
			texture.frame = 1
			shape.polygon = rockTrianglePoly
		2: 
			texture.frame = 2
			shape.polygon = rockCirclePoly
	rotation_degrees = lib.generateRandomNumber(0, 180, "int", false)
	shape.scale = lib.generateRandomVector2(rockScale.x, rockScale.y, "float", false)
	texture.scale = shape.scale * 2.5
	texture.self_modulate = lib.generateRandomColor(minColor, maxColor)
	
	hp = int(shape.scale.x) * 10
	return

func lifeCheck(amount) -> void:
	hp -= amount
	if hp <= 0:
		if shape.scale > Vector2(15, 15):
			lib.circleExplosionFX(global_position, texture.scale / 10)
		lib.rockFragmentFX(global_position, "explosion", texture.self_modulate, texture.scale.x)
		queue_free()
