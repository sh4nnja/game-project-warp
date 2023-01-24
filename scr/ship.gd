extends KinematicBody2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var camera: Node = $camera
onready var trail: Node = $trail
onready var userInterface: Node = $userInterfaceLayer/userInterface

onready var interface: Node = $attachments/shipInterface
onready var texture: Node = $texture
onready var shape: Node = $shape

onready var tail: Node = $texture/tail

var cameraLimit: Vector2 = Vector2(5, 1)
var cameraAddMinus: Vector2 = Vector2(0.5, 0.5)
var cameraDesired: Vector2 
var cameraLerp: float = 0.15

var trailLength: int = 5
var trailOrigin: Vector2

const HP: float = 100.0
var hp: float = HP

#######################################
############## PHYSICS ################
#######################################
var gDelta: float

var velocity: Vector2

const SPEED: float = 25.0
var speed: float = SPEED

var push: int = 25
var friction: float = 0.5

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	cameraDesired = camera.zoom
	trailOrigin = tail.position

func _physics_process(delta):
	gDelta = delta
	movementManager()
	collisionManager()
	zoomManager()
	lib.trailManager(trail, tail, trailLength)

#######################################
########## METHODS / SIGNALS ##########
#######################################
func movementManager() -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("fw"):
		velocity += transform.x * speed
		interface.animateBar(false)
	elif Input.is_action_just_released("fw"):
		interface.animateBar(true)
	
	velocity = lerp(velocity, Vector2(0, 0), friction * gDelta)
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)
	

func collisionManager() -> void:
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("physics"):
			lib.rockFragmentFX(collision.position, "collision", collision.collider.get_child(0).self_modulate, scale.x)
			lib.doShake = true
			lib.combatTextManager(global_position, "Damaged", collision.collider.get_child(0).self_modulate)
			collision.collider.apply_central_impulse(-collision.normal * push)
			hp -= 5
			lifeCheck()
			return

func zoomManager() -> void:
	if Input.is_action_just_released("zUP") and cameraDesired < Vector2(cameraLimit.x, cameraLimit.x):
		cameraDesired += cameraAddMinus
	elif Input.is_action_just_released("zDOWN") and cameraDesired > Vector2(cameraLimit.y, cameraLimit.y):
		cameraDesired -= cameraAddMinus
	camera.zoom = lerp(camera.zoom, cameraDesired, cameraLerp)
	return

func lifeCheck():
	if hp <= HP / 3:
		texture.self_modulate = lib.lifeModulates[2]
		trail.default_color = lib.lifeModulates[5]
		speed = SPEED / 3
	elif hp <= HP / 2:
		texture.self_modulate = lib.lifeModulates[1]
		trail.default_color = lib.lifeModulates[4]
		speed = SPEED / 2
	else:
		texture.self_modulate = lib.lifeModulates[0]
		trail.default_color = lib.lifeModulates[3]
		speed = SPEED
	
	if hp <= 0:
		userInterface.death()
		set_physics_process(false)
		lib.rockFragmentFX(position, "collision", self_modulate, shape.scale.x)
		hide()
