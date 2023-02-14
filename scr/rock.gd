extends RigidBody2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var sprite: Node = $sprite
onready var shape: Node = $shape
var minColor: float = 0.1
var maxColor: float = 1

var rockMode: int
var scrapPool: Array = []
var scrapCount: int 
var hp: int

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready() -> void:
	randomRock()
	poolMaterial()

func _exit_tree():
	clearScrapPool()
#######################################
########## METHODS / SIGNALS ##########
#######################################
func randomRock() -> void:
	rockMode = lib.generateRandomNumber(0, 2, "int", false)
	match rockMode:
		0: sprite.texture = load("res://assts/textures/rock/rockCircle.png")
		1: sprite.texture = load("res://assts/textures/rock/rockSquare.png")
		2: sprite.texture = load("res://assts/textures/rock/rockTriangle.png")
	createCollision(sprite.texture)
	sprite.self_modulate = lib.generateRandomColor(minColor, maxColor, 1)
	hp = shape.scale.x * 10
	return

func createCollision(spriteTexture) -> void:
	var data: Image = spriteTexture.get_data()
	var bitmap: Object = BitMap.new()
	bitmap.create_from_image_alpha(data)
	var polygon = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, spriteTexture.get_size()), 1)
	for poly in polygon:
		shape.polygon = poly
	shape.scale = lib.generateRandomVector2(lib.rockSizes.x, lib.rockSizes.y, "float", false)
	sprite.scale = shape.scale
	sprite.rotation_degrees = lib.generateRandomNumber(0, 180, "int", false)
	shape.rotation_degrees = sprite.rotation_degrees
	scrapCount = int(shape.scale.x * lib.scrapMultiplier)
	return

func poolMaterial() -> void:
	for _i in range(scrapCount):
		var scrapInst: Node = lib.scrap.instance()
		scrapPool.append(scrapInst)
		scrapInst.set_physics_process(false)
		scrapInst = null

func lifeCheck(amount) -> void:
	hp -= amount
	if hp <= 0:
		if shape.scale > Vector2(2, 2):
			lib.frameFreezeManager(0.05, shape.scale.x / 3)
			lib.circleExplosionFX(global_position + ((sprite.texture.get_size() / 2) * sprite.scale), sprite.scale * 2)
		else:
			lib.frameFreezeManager(0.05, shape.scale.x / 5)
		lib.rockFragmentFX(global_position + ((sprite.texture.get_size() / 2) * sprite.scale), "explosion", sprite.self_modulate, sprite.scale.x * 5)
		lib.doShake = true
		spawnMaterial()
		lib.playerNode.get_node_or_null("ship").selfDestructManager()
		queue_free()
	return

func spawnMaterial() -> void:
	var i: int = 0
	while i < scrapCount and scrapPool.size() > 0:
		scrapPool[0].set_physics_process(true)
		scrapPool[0].global_position = (((sprite.texture.get_size() / 2) * sprite.scale) + global_position) + lib.generateRandomSeparateVector2(0, shape.scale.x * 20, "float", true)
		lib.physicsNode.call_deferred("add_child", scrapPool[0])
		scrapPool.remove(0)
		i += 1

func clearScrapPool(): 
	var i: int = 0
	while i < scrapCount and scrapPool.size() > 0:
		for j in scrapPool[0].get_children():
			j.queue_free()
		scrapPool[0].queue_free()
		scrapPool.remove(0)
		i += 1
	scrapPool.clear()
