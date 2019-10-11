extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
class_name RoomManager
# Called when the node enters the scene tree for the first time.
func _ready():

	#1 exits
	_add_rotation("DEAD_U", "DEAD_D", mapper180)
	_add_rotation("DEAD_U", "DEAD_L", mapper90)
	_add_rotation("DEAD_U", "DEAD_R", mapper270)
	
	_add_rotation("DEAD_D", "DEAD_U", mapper180)
	_add_rotation("DEAD_D", "DEAD_L", mapper270)
	_add_rotation("DEAD_D", "DEAD_R", mapper90)
	
	_add_rotation("DEAD_L", "DEAD_U", mapper270)
	_add_rotation("DEAD_L", "DEAD_D", mapper90)
	_add_rotation("DEAD_L", "DEAD_R", mapper180)
	
	_add_rotation("DEAD_R", "DEAD_U", mapper90)
	_add_rotation("DEAD_R", "DEAD_D", mapper270)
	_add_rotation("DEAD_R", "DEAD_L", mapper180)
	
	#2 exits
	_add_rotation("LINE", "I_SHAPE", mapper90)
	_add_rotation("I_SHAPE", "LINE", mapper270)
	
	_add_rotation("L_SHAPE", "L_90_SHAPE", mapper90)
	_add_rotation("L_SHAPE", "L_180_SHAPE", mapper180)
	_add_rotation("L_SHAPE", "L_270_SHAPE", mapper270)
	
	_add_rotation("L_90_SHAPE", "L_SHAPE", mapper270)
	_add_rotation("L_90_SHAPE", "L_180_SHAPE", mapper90)
	_add_rotation("L_90_SHAPE", "L_270_SHAPE", mapper180)
	
	_add_rotation("L_180_SHAPE", "L_SHAPE", mapper180)
	_add_rotation("L_180_SHAPE", "L_90_SHAPE", mapper270)
	_add_rotation("L_180_SHAPE", "L_270_SHAPE", mapper90)
	
	_add_rotation("L_270_SHAPE", "L_SHAPE", mapper90)
	_add_rotation("L_270_SHAPE", "L_90_SHAPE", mapper180)
	_add_rotation("L_270_SHAPE", "L_180_SHAPE", mapper270)
	
	#3 exits
	_add_rotation("T_SHAPE", "T_90_SHAPE", mapper90)
	_add_rotation("T_SHAPE", "T_180_SHAPE", mapper180)
	_add_rotation("T_SHAPE", "T_270_SHAPE", mapper270)
	
	_add_rotation("T_90_SHAPE", "T_SHAPE", mapper270)
	_add_rotation("T_90_SHAPE", "T_180_SHAPE", mapper90)
	_add_rotation("T_90_SHAPE", "T_270_SHAPE", mapper180)
	
	_add_rotation("T_180_SHAPE", "T_SHAPE", mapper180)
	_add_rotation("T_180_SHAPE", "T_90_SHAPE", mapper270)
	_add_rotation("T_180_SHAPE", "T_270_SHAPE", mapper90)
	
	_add_rotation("T_270_SHAPE", "T_SHAPE", mapper90)
	_add_rotation("T_270_SHAPE", "T_90_SHAPE", mapper180)
	_add_rotation("T_270_SHAPE", "T_180_SHAPE", mapper270)
	
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

var mapper = funcref(self, "with_no_degree")
var mapper90 = funcref(self, "with_90_degree")
var mapper180 = funcref(self, "with_180_degree")
var mapper270 = funcref(self, "with_270_degree")

func with_no_degree(pos: Vector2):

	return pos

func with_90_degree(pos: Vector2):
	var x = - pos.y
	var y = pos.x
	return Vector2(x, y)

func with_180_degree(pos: Vector2):
	var x = - pos.x 
	var y = - pos.y
	return Vector2(x, y)

func with_270_degree(pos: Vector2):
	var x = pos.y 
	var y = - pos.x
	return Vector2(x, y)
	

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