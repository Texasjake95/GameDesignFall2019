extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MOTION_SPEED = 160 # Pixels/second

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var time_before = OS.get_ticks_usec()
	
	var floors = get_node("floor")
	var walls = get_node("walls")
	
	var validFloorCells = []
	validFloorCells.push_back(-1)
	validFloorCells.push_back(0)
	
	# 5, 4
	#15, -14
	
	for x in range(5,16):
		for y in range(-14, 5):
			
			var floorCell = randi() % validFloorCells.size()
			
			if floors.get_cell(x, y) == -1:
				floors.set_cell(x, y, validFloorCells[floorCell])
			
			var current = walls.get_cell(x, y)
			
			var flipX = randi() % 2 == 0
			var flipY = randi() % 2 == 0
			
			if current == 2:
				walls.set_cell(x, y, 3, false, false)
			elif current == 3:
				walls.set_cell(x, y, 4, flipX, false)
			elif current == 4:
				walls.set_cell(x, y, 2, false, false)
	
	var total_time = OS.get_ticks_usec() - time_before
	print("Time taken: " + str(total_time) + "us")
	print("Time taken: " + str(total_time/1000) + "ms")
	print("Time taken: " + str(total_time/1000000) + "s")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
