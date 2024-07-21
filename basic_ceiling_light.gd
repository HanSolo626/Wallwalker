extends Node3D

var START_POSITION

func init_light(position):
	START_POSITION = position
	transform.origin = START_POSITION
