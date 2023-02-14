extends Node2D

#######################################
########## INITIALIZATION #############
#######################################
onready var ammoCount: Node = $ammoCount

onready var selfDestructCountLeft: Node = $userInterfaceLayer/userInterface/deathTimer/left
onready var selfDestructCountRight: Node = $userInterfaceLayer/userInterface/deathTimer/right

onready var scrapCount: Node = $userInterfaceLayer/userInterface/scrapAnchor/scrap
onready var scrapCountTween: Node = $userInterfaceLayer/userInterface/scrapAnchor/tween

onready var canTimeFreezeCountLeft: Node = $userInterfaceLayer/userInterface/canTimeFreeze/left
onready var canTimeFreezeCountRight: Node = $userInterfaceLayer/userInterface/canTimeFreeze/right

onready var canTimeFreezeIcon: Node = $userInterfaceLayer/userInterface/tools/freezeTime
onready var canRepairShipIcon: Node = $userInterfaceLayer/userInterface/tools/repairShip
onready var canReplenishAmmoIcon: Node = $userInterfaceLayer/userInterface/tools/replenishAmmo

onready var animation: Node = $userInterfaceLayer/userInterface/animation

onready var home: Node = $userInterfaceLayer/userInterface/deathScreen/home
onready var restart: Node = $userInterfaceLayer/userInterface/deathScreen/restart

var minColor: float = 0.1
var maxColor: float = 1

var paused: bool = false
#######################################
######## VIRTUAL CODES / START ########
#######################################
func _input(_event):
	pause()
#######################################
########## METHODS / SIGNALS ##########
#######################################
func ammoCountManager(value: float, maxValue: float) -> void:
	ammoCount.max_value = maxValue
	ammoCount.value = value
	if value <= maxValue / 3:
		ammoCount.self_modulate = lib.lifeModulates[2]
	elif value <= maxValue / 2:
		ammoCount.self_modulate = lib.lifeModulates[1]
	else:
		ammoCount.self_modulate = lib.lifeModulates[0]

func scrapCountManager(amount: int) -> void:
	scrapCountTween.interpolate_property(scrapCount, "rect_scale", Vector2(1.15, 1.15), Vector2(1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	scrapCountTween.interpolate_property(scrapCount, "self_modulate", lib.generateRandomColor(minColor, maxColor, 1), Color(1, 1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	scrapCount.text = str(amount)
	scrapCountTween.start()

func selfDestructCountManager(value: float, maxValue: float) -> void:
	selfDestructCountLeft.max_value = maxValue
	selfDestructCountRight.max_value = maxValue
	selfDestructCountLeft.value = value
	selfDestructCountRight.value = value
	if value <= maxValue / 3:
		selfDestructCountLeft.self_modulate = lib.lifeModulates[2]
		selfDestructCountRight.self_modulate = lib.lifeModulates[2]
	elif value <= maxValue / 2:
		selfDestructCountLeft.self_modulate = lib.lifeModulates[1]
		selfDestructCountRight.self_modulate = lib.lifeModulates[1]
	elif value >= maxValue:
		selfDestructCountLeft.self_modulate = lib.lifeModulates[6]
		selfDestructCountRight.self_modulate = lib.lifeModulates[6]
	else:
		selfDestructCountLeft.self_modulate = lib.lifeModulates[0]
		selfDestructCountRight.self_modulate = lib.lifeModulates[0]

func canTimeFreezeCountManager(value: float, maxValue: float) -> void:
	canTimeFreezeCountLeft.max_value = maxValue
	canTimeFreezeCountRight.max_value = maxValue
	canTimeFreezeCountLeft.value = value
	canTimeFreezeCountRight.value = value
	if value <= maxValue / 3:
		canTimeFreezeCountLeft.self_modulate = lib.lifeModulates[2]
		canTimeFreezeCountRight.self_modulate = lib.lifeModulates[2]
	elif value <= maxValue / 2:
		canTimeFreezeCountLeft.self_modulate = lib.lifeModulates[1]
		canTimeFreezeCountRight.self_modulate = lib.lifeModulates[1]
	elif value > maxValue:
		canTimeFreezeCountLeft.self_modulate = lib.lifeModulates[6]
		canTimeFreezeCountRight.self_modulate = lib.lifeModulates[6]
		canTimeFreezeIcon.modulate = Color(1, 1, 1, 1)
	else:
		canTimeFreezeCountLeft.self_modulate = lib.lifeModulates[0]
		canTimeFreezeCountRight.self_modulate = lib.lifeModulates[0]
		canTimeFreezeIcon.modulate = Color(1, 1, 1, .25)

func isTimeFrozen(mode: bool) -> void:
	if mode:
		canRepairShipIcon.modulate = Color(1, 1, 1, 1)
		canReplenishAmmoIcon.modulate = Color(1, 1, 1, 1)
	else:
		canRepairShipIcon.modulate = Color(1, 1, 1, .25)
		canReplenishAmmoIcon.modulate = Color(1, 1, 1, .25)

func canTimeFreeze(mode: bool) -> void:
	if mode:
		animation.playback_speed = 5
		animation.play("canTimeFreeze")
	else:
		animation.playback_speed = 1
		animation.play_backwards("canTimeFreeze")

func death() -> void:
	animation.play("death")

func pause() -> void:
	if Input.is_action_just_pressed("pause") and !paused and !get_parent().get_parent().dead:
		paused = true
		animation.play("pause")
		get_tree().paused = true
	elif Input.is_action_just_pressed("pause") and paused and !get_parent().get_parent().dead:
		paused = false
		animation.play_backwards("pause")
		get_tree().paused = false

func _on_home_mouse_entered() -> void:
	home.self_modulate = lib.generateRandomColor(minColor, maxColor, 1)
func _on_home_mouse_exited() -> void:
	home.self_modulate = Color(1, 1, 1)
func _on_home_pressed() -> void:
	var _changeScn = get_tree().change_scene("res://scn/mainmenu/mainmenu.tscn")

func _on_restart_mouse_entered() -> void:
	restart.self_modulate = lib.generateRandomColor(minColor, maxColor, 1)
func _on_restart_mouse_exited() -> void:
	restart.self_modulate = Color(1, 1, 1)
func _on_restart_pressed() -> void:
	var _changeScn = get_tree().change_scene("res://scn/space/space.tscn")

