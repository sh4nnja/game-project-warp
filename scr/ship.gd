extends KinematicBody2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var spaceAnimation: Node = get_tree().root.get_node("space/animation")

onready var camera: Node = $camera
onready var trail: Node = $trail
onready var interface: Node = $attachments/shipInterface
onready var texture: Node = $texture
onready var shape: Node = $shape

onready var attachments: Node = $attachments
onready var materialObtainerAttachment: Node = $attachments/materialObtainer
onready var blasterAttachment: Node = $attachments/blaster

onready var selfDestructTimer: Node = $selfDestructTimer

onready var tail: Node = $texture/tail

var cameraLimit: Vector2 = Vector2(2, 1)
var cameraAddMinus: Vector2 = Vector2(0.5, 0.5)
var cameraDesired: Vector2 
var cameraLerp: float = 0.15

var trailLength: int = 5
var trailOrigin: Vector2

const HP: float = 100.0
var hp: float = HP

var timer: float
var canTimeFreezeNumber: int

var timeAccessedLock: bool = false
#######################################
############## PHYSICS ################
#######################################
var gDelta: float

var velocity: Vector2

const SPEED: float = 25.0
var speed: float = SPEED

var push: int = 25
var friction: float = 1

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	cameraDesired = camera.zoom
	trailOrigin = tail.position
	selfDestructManager()
	canTimeFreezeManager()

func _physics_process(delta):
	gDelta = delta
	movementManager()
	collisionManager()
	zoomManager()
	selfDestructMonitorManager()
	doTimeFreezeManager()
	
	lib.trailManager(trail, tail, trailLength)

#######################################
########## METHODS / SIGNALS ##########
#######################################
func movementManager() -> void:
	look_at(get_global_mouse_position())
	velocity += transform.x * speed
	speed = lifeCheck()
	
	if Input.is_action_pressed("fw"):
		speed = lifeCheck() * 2
	elif Input.is_action_just_released("fw"):
		speed = lifeCheck()
	
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
			return

func zoomManager() -> void:
	if Input.is_action_just_released("zUP") and cameraDesired < Vector2(cameraLimit.x, cameraLimit.x):
		cameraDesired += cameraAddMinus
	elif Input.is_action_just_released("zDOWN") and cameraDesired > Vector2(cameraLimit.y, cameraLimit.y):
		cameraDesired -= cameraAddMinus
	camera.zoom = lerp(camera.zoom, cameraDesired, cameraLerp)
	return

func lifeCheck() -> float:
	var returnSpeed: float
	if hp <= 0:
		interface.death()
		hide()
		set_physics_process(false)
		for i in attachments.get_children():
			i.set_physics_process(false)
		lib.rockFragmentFX(position, "collision", self_modulate, shape.scale.x * 2)
		lib.circleExplosionFX(global_position, texture.scale / 10)
		
	if hp <= HP / 3:
		texture.self_modulate = lib.lifeModulates[2]
		trail.default_color = lib.lifeModulates[5]
		returnSpeed = SPEED / 3
		return returnSpeed
	elif hp <= HP / 2:
		texture.self_modulate = lib.lifeModulates[1]
		trail.default_color = lib.lifeModulates[4]
		returnSpeed = SPEED / 2
		return returnSpeed
	else:
		texture.self_modulate = lib.lifeModulates[0]
		trail.default_color = lib.lifeModulates[3]
		returnSpeed =  SPEED
		return returnSpeed

func selfDestructManager() -> void:
	timer = lib.generateRandomNumber(lib.selfDestructTimer.x, lib.selfDestructTimer.y, "int", false)
	selfDestructTimer.start(timer)

func selfDestructMonitorManager() -> void:
	if selfDestructTimer.time_left != 0:
		interface.selfDestructCountManager(selfDestructTimer.time_left, timer)

func _on_selfDestructTimer_timeout() -> void:
	hp = 0

func canTimeFreezeManager() -> void:
	canTimeFreezeNumber = lib.generateRandomNumber(30, 50, "int", false)

func doTimeFreezeManager() -> void:
	if materialObtainerAttachment.obtainedScraps >= canTimeFreezeNumber:
		if Input.is_action_just_pressed("freezeTime"):
			materialObtainerAttachment.obtainedScraps -= canTimeFreezeNumber
			interface.canTimeFreezeCountManager(materialObtainerAttachment.obtainedScraps, canTimeFreezeNumber)
			interface.scrapCountManager(materialObtainerAttachment.obtainedScraps)
			lib.frameFreezeManager(spaceAnimation, 0.05, 5)
			selfDestructManager()
			canTimeFreezeManager()
	
	if Engine.time_scale < 1.0:
		doRepairShipManager() 
		doReplenishAmmo()
		if !timeAccessedLock:
			interface.isTimeFrozen(true)
			timeAccessedLock = true
	elif Engine.time_scale >= 1.0 and timeAccessedLock:
		interface.isTimeFrozen(false)
		timeAccessedLock = false

func doRepairShipManager() -> void:
	if Input.is_action_just_pressed("repairShip"):
		if hp < HP:
			var healthToAdd: int = hp + materialObtainerAttachment.obtainedScraps
			if healthToAdd > HP:
				materialObtainerAttachment.obtainedScraps -= (HP - hp)
				hp = HP
			else:
				hp = healthToAdd
				materialObtainerAttachment.obtainedScraps = 0
		interface.canTimeFreezeCountManager(materialObtainerAttachment.obtainedScraps, canTimeFreezeNumber)
		interface.scrapCountManager(materialObtainerAttachment.obtainedScraps)

func doReplenishAmmo() -> void:
	if Input.is_action_just_pressed("replenishAmmo"):
		var bulletNumber: int = blasterAttachment.bulletPool.size()
		if bulletNumber < blasterAttachment.BULLETAMOUNT:
			var bulletToAdd: int = bulletNumber + materialObtainerAttachment.obtainedScraps
			if bulletToAdd > blasterAttachment.BULLETAMOUNT:
				materialObtainerAttachment.obtainedScraps -= (blasterAttachment.BULLETAMOUNT - bulletNumber)
				blasterAttachment.bulletManager(blasterAttachment.BULLETAMOUNT)
			else:
				blasterAttachment.bulletManager(bulletToAdd)
				materialObtainerAttachment.obtainedScraps = 0
		interface.canTimeFreezeCountManager(materialObtainerAttachment.obtainedScraps, canTimeFreezeNumber)
		interface.scrapCountManager(materialObtainerAttachment.obtainedScraps)
