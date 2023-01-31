extends Area2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var trail: Node = $trail

var minColor: float = 0.1
var maxColor: float = 1

var trailLength: int = 10
var trailPoint: Vector2

var damage: int = lib.blasterDamage
#######################################
############## PHYSICS ################
#######################################
var speed: int = 75
var push: int = 25

var gDelta: float

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready() -> void:
	trail.self_modulate = lib.generateRandomColor(minColor, maxColor)

func _physics_process(delta) -> void:
	gDelta = delta
	
	bulletManager()
	lib.trailManager(trail, self, trailLength)

#######################################
########## METHODS / SIGNALS ##########
#######################################
func bulletManager() -> void:
	position += transform.x * speed 
	return

func _on_screenCheck_timeout() -> void:
	queue_free()

func _on_bullet_body_entered(body) -> void:
	if body.is_in_group("physics"):
		if body.is_in_group("rock"):
			body.lifeCheck(damage)
			lib.rockFragmentFX(global_position, "blaster", body.get_child(0).self_modulate, scale.x * 2)
			lib.doShake = true
			lib.combatTextManager(global_position, "Normal", body.get_child(0).self_modulate)
		queue_free()



