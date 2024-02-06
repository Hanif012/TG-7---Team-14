extends Node2D


@export  var minimum: float = -0.1
@export var maximum: float = 0.1
@export var FREQUENCY = 40

@onready var light = $Light
var cycle = 1
var average = (maximum+minimum)/2
var amplitude = (maximum-minimum)/2

func _process(delta):
	self.cycle += delta * FREQUENCY
	light.skew = average + amplitude * (sin(cycle))
#	print(light.skew)
	
