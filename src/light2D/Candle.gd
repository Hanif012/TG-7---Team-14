extends Node2D


@export  var min: float = -0.1
@export var max: float = 0.1
@export var FREQUENCY = 40

@onready var light = $Light
var cycle = 1
var average = (max+min)/2
var amplitude = (max-min)/2

func _process(delta):
	self.cycle += delta * FREQUENCY
	light.skew = average + amplitude * (sin(cycle))
#	print(light.skew)
	
