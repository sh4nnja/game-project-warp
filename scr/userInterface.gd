extends Control

onready var animation: Node = $animation

func death():
	animation.play("death")
