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

onready var animation: Node = $userInterfaceLayer/userInterface/animation

var minColor: float = 0.1
var maxColor: float = 1

#######################################
######## VIRTUAL CODES / START ########
#######################################

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

func scrapCountManager(amount: int):
	scrapCountTween.interpolate_property(scrapCount, "rect_scale", Vector2(1.15, 1.15), Vector2(1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	scrapCountTween.interpolate_property(scrapCount, "self_modulate", lib.generateRandomColor(minColor, maxColor), Color(1, 1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
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
	elif value >= maxValue:
		canTimeFreezeCountLeft.self_modulate = lib.lifeModulates[6]
		canTimeFreezeCountRight.self_modulate = lib.lifeModulates[6]
	else:
		canTimeFreezeCountLeft.self_modulate = lib.lifeModulates[0]
		canTimeFreezeCountRight.self_modulate = lib.lifeModulates[0]

func isTimeFrozen(mode: bool):
	if mode:
		animation.playback_speed = 5
		animation.play("timeFreeze")
	else:
		animation.playback_speed = 1
		animation.play_backwards("timeFreeze")

func death() -> void:
	animation.play("death")
