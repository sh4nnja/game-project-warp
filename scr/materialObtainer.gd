extends Node2D


#######################################
#### LOADING AND INITIALIZATION #######
#######################################
var obtainedScraps: int
var minColor: float = 0.1
var maxColor: float = 1

#######################################
########## METHODS / SIGNALS ##########
#######################################
func _on_vacuum_body_entered(body):
	if body.is_in_group("scrap"):
		body.sleeping = false
func _on_vacuum_body_exited(body):
	if body.is_in_group("scrap"):
		body.sleeping = true

func _on_obtainer_body_entered(body):
	if body.is_in_group("scrap"):
		body.queue_free()
		lib.combatTextManager(global_position, "Scrap", lib.generateRandomColor(minColor, maxColor))
		obtainedScraps += 1





