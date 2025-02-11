extends Node

var currentArea = -1
var areaPath = "res://assets/scenes/playable/"

func nextLevel():
	currentArea += 1
	var fullPath = areaPath + "area_" + str(currentArea) + ".tscn"
	get_tree().change_scene_to_file(fullPath)
	print("entered portal")
