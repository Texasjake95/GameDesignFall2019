extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
class_name RoomManager
# Called when the node enters the scene tree for the first time.
func _ready():

	#ALL of these are most likely backwards... need to test and see
	#Easy fix just change which is which here
	var reverse90 = mapper90
	var reverse180 = mapper180
	var reverse270 = mapper270
	
	#1 exits
	_add_rotation("DEAD_U", "DEAD_D", reverse180)
	_add_rotation("DEAD_U", "DEAD_L", reverse90)
	_add_rotation("DEAD_U", "DEAD_R", reverse270)
	
	_add_rotation("DEAD_D", "DEAD_U", reverse180)
	_add_rotation("DEAD_D", "DEAD_L", reverse270)
	_add_rotation("DEAD_D", "DEAD_R", reverse90)
	
	_add_rotation("DEAD_L", "DEAD_U", reverse270)
	_add_rotation("DEAD_L", "DEAD_D", reverse90)
	_add_rotation("DEAD_L", "DEAD_R", reverse180)
	
	_add_rotation("DEAD_R", "DEAD_U", reverse90)
	_add_rotation("DEAD_R", "DEAD_D", reverse270)
	_add_rotation("DEAD_R", "DEAD_L", reverse180)
	
	#2 exits
	_add_rotation("LINE", "I_SHAPE", reverse90)
	_add_rotation("I_SHAPE", "LINE", reverse270)
	
	_add_rotation("L_SHAPE", "L_90_SHAPE", reverse90)
	_add_rotation("L_SHAPE", "L_180_SHAPE", reverse180)
	_add_rotation("L_SHAPE", "L_270_SHAPE", reverse270)
	
	_add_rotation("L_90_SHAPE", "L_SHAPE", reverse270)
	_add_rotation("L_90_SHAPE", "L_180_SHAPE", reverse90)
	_add_rotation("L_90_SHAPE", "L_270_SHAPE", reverse180)
	
	_add_rotation("L_180_SHAPE", "L_SHAPE", reverse180)
	_add_rotation("L_180_SHAPE", "L_90_SHAPE", reverse270)
	_add_rotation("L_180_SHAPE", "L_270_SHAPE", reverse90)
	
	_add_rotation("L_270_SHAPE", "L_SHAPE", reverse90)
	_add_rotation("L_270_SHAPE", "L_90_SHAPE", reverse180)
	_add_rotation("L_270_SHAPE", "L_180_SHAPE", reverse270)
	
	#3 exits
	_add_rotation("T_SHAPE", "T_90_SHAPE", reverse90)
	_add_rotation("T_SHAPE", "T_180_SHAPE", reverse180)
	_add_rotation("T_SHAPE", "T_270_SHAPE", reverse270)
	
	_add_rotation("T_90_SHAPE", "T_SHAPE", reverse270)
	_add_rotation("T_90_SHAPE", "T_180_SHAPE", reverse90)
	_add_rotation("T_90_SHAPE", "T_270_SHAPE", reverse180)
	
	_add_rotation("T_180_SHAPE", "T_SHAPE", reverse180)
	_add_rotation("T_180_SHAPE", "T_90_SHAPE", reverse270)
	_add_rotation("T_180_SHAPE", "T_270_SHAPE", reverse90)
	
	_add_rotation("T_270_SHAPE", "T_SHAPE", reverse90)
	_add_rotation("T_270_SHAPE", "T_90_SHAPE", reverse180)
	_add_rotation("T_270_SHAPE", "T_180_SHAPE", reverse270)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var rotation_lookup = Dictionary()

func _add_rotation(startType, endType, rotation):
	
	if not rotation_lookup.has(startType):
		rotation_lookup[startType] = Dictionary()
		
	var lookup = rotation_lookup[startType]
	
	if not lookup.has(endType):
		lookup[endType] = rotation
	
func _get_rotation(startType, endType):
	
	if startType == endType:
		return mapper
	
	return rotation_lookup[startType][endType]	
	
	
func get_provider(room, requestedType):
	var roomType = room.get_type()
	var rotation = _get_rotation(roomType, requestedType)
	
	return RoomProvider.new(room, rotation)

#Store rotation functions as a variable to call them later see RoomProvider below
var mapper = funcref(self, "with_no_degree")
var mapper90 = funcref(self, "with_90_degree")
var mapper180 = funcref(self, "with_180_degree")
var mapper270 = funcref(self, "with_270_degree")

#These are written like this so that there are not 4 multiplications happening every call
#with approximately 81 call PER room it get very expensive very fast 
func with_no_degree(pos: Vector2):
	return pos

func with_90_degree(pos: Vector2):
	return Vector2(-pos.y, pos.x)

func with_180_degree(pos: Vector2):
	return Vector2(-pos.x, -pos.y)

func with_270_degree(pos: Vector2):
	return Vector2(pos.y, -pos.x)

#Rooms can be rotated inorder to fit several types 
#This is a bridge to help with that
class RoomProvider:
	var mapper = RoomManager.mapper
	var room = null
	
	func _init(room, mapper):
		self.room = room
		self.mapper = mapper
		
	func get_tile(pos: Vector2):
		if mapper:
			pos = mapper.call_func(pos)
		
		return room.get_tile(pos)