extends KinematicBody2D

#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var camera: Node = $camera
onready var trail: Node = $trail
onready var texture: Node = $texture
onready var shape: Node = $shape
onready var tail: Node = $texture/tail
onready var selfDestructTimer: Node = $selfDestructTimer
var timer: float
var canTimeFreezeNumber: int

onready var attachments: Node = $attachments
onready var materialObtainerAttachment: Node = attachments.get_node_or_null("materialObtainer")
onready var blasterAttachment: Node = attachments.get_node_or_null("blaster")
onready var interface: Node = attachments.get_node_or_null("shipInterface")

var cameraAddMinus: Vector2 = Vector2(0.25, 0.25)
var cameraDesired: Vector2 
var cameraLerp: float = 0.15

var trailLength: int = 3
var trailOrigin: Vector2

const HP: float = 100.0
var hp: float = HP
var damage: int = lib.damageFromRock

var dead: bool = false
#######################################
############## PHYSICS ################
#######################################
var velocity: Vector2
const SPEED: float = 25.0
var speed: float = SPEED
var friction: float = 1
#######################################
######## VIRTUAL CODES / START ########
#######################################
func _ready():
	cameraDesired = camera.zoom
	trailOrigin = tail.position
	selfDestructManager()
	canTimeFreezeManager()
	setCameraLimit()

func _physics_process(delta):
	movementManager(delta)
	collisionManager()
	selfDestructMonitorManager()
	zoomManager()

func _input(_event):
	doTimeFreezeManager()

#######################################
########## METHODS / SIGNALS ##########
#######################################
func setCameraLimit() -> void:
	camera.limit_top = -lib.mapSize.x
	camera.limit_bottom = lib.mapSize.x
	camera.limit_left = -lib.mapSize.x
	camera.limit_right = lib.mapSize.x

func movementManager(delta) -> void:
	look_at(get_global_mouse_position())
	velocity += transform.x * speed
	speed = lifeCheck()
	
	if Input.is_action_pressed("fw"):
		speed = lifeCheck() * 2
	elif Input.is_action_just_released("fw"):
		speed = lifeCheck()
	
	velocity = lerp(velocity, Vector2(0, 0), friction * delta)
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)
	lib.trailManager(trail, tail, trailLength)

func collisionManager() -> void:
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("physics"):
			lib.rockFragmentFX(collision.position, "collision", collision.collider.get_child(0).self_modulate, scale.x)
			lib.doShake = true
			lib.combatTextManager(global_position, "Damaged", collision.collider.get_child(0).self_modulate)
			hp -= damage
			return

func selfDestructMonitorManager() -> void:
	if selfDestructTimer.time_left != 0 and interface:
		interface.selfDestructCountManager(selfDestructTimer.time_left, timer)

func zoomManager() -> void:
	if Input.is_action_just_released("zUP") and cameraDesired < Vector2(lib.zoomThreshold.x, lib.zoomThreshold.x):
		cameraDesired += cameraAddMinus
	elif Input.is_action_just_released("zDOWN") and cameraDesired > Vector2(lib.zoomThreshold.y, lib.zoomThreshold.x):
		cameraDesired -= cameraAddMinus
	camera.zoom = lerp(camera.zoom, cameraDesired, cameraLerp)
	return


func canTimeFreezeManager() -> void:
	canTimeFreezeNumber = lib.generateRandomNumber(30, 50, "int", false)

func doTimeFreezeManager() -> void:
	if materialObtainerAttachment and interface:
		if materialObtainerAttachment.obtainedScraps >= canTimeFreezeNumber:
			if Input.is_action_just_pressed("freezeTime"):
				if interface:
					interface.canTimeFreezeCountManager(materialObtainerAttachment.obtainedScraps, canTimeFreezeNumber)
					interface.scrapCountManager(materialObtainerAttachment.obtainedScraps)
					interface.canTimeFreezeCountManager(materialObtainerAttachment.obtainedScraps, canTimeFreezeNumber)
				if materialObtainerAttachment:
					materialObtainerAttachment.obtainedScraps -= canTimeFreezeNumber
				lib.frameFreezeManager(0.05, 5)
				selfDestructManager()
				canTimeFreezeManager()
	
		if Engine.time_scale < 1.0:
			doRepairShipManager() 
			doReplenishAmmo()
			interface.isTimeFrozen(true)
		elif Engine.time_scale >= 1.0:
			interface.isTimeFrozen(false)

func doRepairShipManager() -> void:
	if Input.is_action_just_pressed("repairShip") and materialObtainerAttachment and interface:
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
	if Input.is_action_just_pressed("replenishAmmo") and blasterAttachment and interface and materialObtainerAttachment:
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


func lifeCheck() -> float:
	var returnSpeed: float
	if hp <= 0 and interface:
		interface.death()
		hide()
		set_physics_process(false)
		for i in attachments.get_children():
			i.set_physics_process(false)
		lib.rockFragmentFX(position, "collision", self_modulate, shape.scale.x)
		lib.circleExplosionFX(global_position, texture.scale)
		dead = true
		
	if hp <= HP / 3:
		texture.self_modulate = lib.lifeModulates[2]
		trail.default_color = lib.lifeModulates[5]
		returnSpeed = SPEED * 3
		return returnSpeed
	elif hp <= HP / 2:
		texture.self_modulate = lib.lifeModulates[1]
		trail.default_color = lib.lifeModulates[4]
		returnSpeed = SPEED * 2
		return returnSpeed
	else:
		texture.self_modulate = lib.lifeModulates[0]
		trail.default_color = lib.lifeModulates[3]
		returnSpeed =  SPEED
		return returnSpeed

func selfDestructManager() -> void:
	if lib.selfDestructMode:
		timer = lib.generateRandomNumber(lib.selfDestructTimer.x, lib.selfDestructTimer.y, "int", false)
		selfDestructTimer.start(timer)

func _on_selfDestructTimer_timeout() -> void:
	hp = 0

