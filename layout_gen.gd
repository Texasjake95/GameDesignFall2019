extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const TERMINAL = [ 
	"DEAD_U",
	"DEAD_D",
	"DEAD_L",
	"DEAD_R",
	"L_SHAPE",
	"L_90_SHAPE",
	"L_180_SHAPE",
	"L_270_SHAPE",
	"T_SHAPE",
	"T_90_SHAPE",
	"T_180_SHAPE",
	"T_270_SHAPE"
]

const DEBUG = false

static func debug(message):
	if DEBUG:
		print(message)

const HEX = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
const UP_V = Vector2(0, -1)
const DOWN_V = Vector2(0, 1)
const RIGHT_V = Vector2(1, 0)
const LEFT_V = Vector2(-1, 0)

const roomTypes = Dictionary()
const opcodeLookup = []
var master_grammar

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var roomTypeData : Dictionary = util.loadJson("res://room_types.json")
	for key in roomTypeData.keys() :
		
		var data = roomTypeData[key]
		var roomType = RoomType.new()
		var roomName = data["name"]
		var roomExits = data["exits"]
		
		roomType.init(roomName, roomExits)
		roomTypes[key] = roomType
		
	opcodeLookup.resize(roomTypes.size())
	
	for value in roomTypes.values():
		opcodeLookup[value.opcode] = value
		print(opcodeLookup[value.opcode].name)
	master_grammar = load_layout("res://dungeon_grammar.json")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func load_layout(fileLoc):
	var layoutData = util.loadJson(fileLoc)
	
	var layout = Layout.new()
	
	var maxSizeData = layoutData["maxSize"]
	var maxSize = Vector2(maxSizeData["x"], maxSizeData["y"])
	print(maxSize)
	var roomGroups = layoutData["roomGroups"]
	layout.init(maxSize, roomGroups)
	
	var errors = 0
	
	errors += _check_group("TOP", layout.roomGroups["TOP"], TOP)
	errors += _check_group("BOTTOM", layout.roomGroups["BOTTOM"], BOTTOM)
	errors += _check_group("LEFT", layout.roomGroups["LEFT"], LEFT)
	errors += _check_group("RIGHT", layout.roomGroups["RIGHT"], RIGHT)
	
	assert(errors == 0)
	
	return layout

func _check_group(groupName, rooms, bit):
	
	var errors = 0
	
	for name in rooms:
		var room = roomTypes[name]
		if not util.check(room.opcode, bit):
			print("INVALID ROOM " + name + " IN " + groupName)
			errors += 1
	
	return errors

func print_layout(tileMap: TileMap, minX, maxX, minY, maxY):
	for y in range(minY, maxY+1):
		var toPrint = ""
		for x in range(minX, maxX+1):
			toPrint += _get_char(tileMap, x, y)
		print(toPrint)

func _get_char(map: TileMap, x, y):
	var v = Vector2(x,y)
	
	var room = " "
	var cell = map.get_cellv(v)
	if cell != -1:
		room = HEX[cell]
	
	return room

func generate_layout(layout : Layout):
	print("GENERATING")
	var map = TileMap.new()
	var minX = 0
	var maxX = 0
	var minY = 0
	var maxY = 0
	var sizeX = 1
	var sizeY = 1
	var neededRooms = Dictionary()
	
	var time_before = OS.get_ticks_usec()
	_set_room(map, Vector2(0, 0), roomTypes[_get_random(layout.roomGroups["START"])], neededRooms)
	
	while neededRooms.size() > 0:
		sizeX = maxX - minX + 1;
		sizeY = maxY - minY + 1;
		
		var pos = neededRooms.keys()[0]
		var group = neededRooms[pos]
		
		neededRooms.erase(pos)
		debug(neededRooms.size())
		var set = false
		
		if sizeX > layout.maxSize.x:
			debug("Outside x check")
			if pos.x <= minX || maxX <= pos.x:
				debug("TERMINAL")
				if _try_terminal(map, pos, neededRooms):
					set = true
		
		if not set:
			if sizeY > layout.maxSize.y:
				debug("Outside y check")
				if pos.y <= minY || maxY <= pos.y:
					debug("TERMINAL")
					if _try_terminal(map, pos, neededRooms):
						set = true
						
		if not set:
			if not _trySetGroup(map, group, pos, layout, neededRooms):
				debug("MASTER")
				_trySetGroup(map, group, pos, master_grammar, neededRooms)
			set = true
			
		minX = min(pos.x, minX)
		maxX = max(pos.x, maxX)
		minY = min(pos.y, minY)
		maxY = max(pos.y, maxY)
		
		sizeX = maxX - minX + 1;
		sizeY = maxY - minY + 1;
		
		debug(str(Vector2(minX, minY)) + " " + str(Vector2(maxX, maxY)) + " " + str(Vector2(sizeX, sizeY)))
		debug(neededRooms.size())
		
	var total_time = OS.get_ticks_usec() - time_before
	print("DONE! SIZE: " + str(Vector2(sizeX, sizeY)))
	print_layout(map, minX, maxX, minY, maxY)
	

	print("Time taken to generate: " + str(total_time) + "us")
	print("Time taken to generate: " + str(total_time/1000) + "ms")
	print("Time taken to generate: " + str(total_time/1000000) + "s")
	return map
	
func _try_terminal(currentLayout: TileMap, pos: Vector2, toSet: Dictionary):
	return _trySetArray(currentLayout, TERMINAL, pos, toSet, false)

func _get_random(array: Array):
	array.shuffle()
	return array[0]

func _trySetGroup(currentLayout: TileMap, group: String, pos: Vector2, layout: Layout, toSet: Dictionary):
	debug("\tGROUP: " + group)
	return _trySetArray(currentLayout, layout.roomGroups[group], pos, toSet, true)

#FIGURE OUT toSet
func _trySetArray(currentLayout: TileMap, roomNames : Array, pos: Vector2, toSet: Dictionary, shuffle : bool):
	if shuffle:
		roomNames.shuffle()
		
	debug("Finding tile for: " + str(pos))
	for name in roomNames:
		
		debug("\tTrying to place " + name)
		var roomType = roomTypes[name]
		if _can_room_exist(currentLayout, pos, roomType):
			
			debug("\t\t\tPlaced " + name)
			_set_room(currentLayout, pos, roomType, toSet)
			return true;
	
	return false
	
func _set_room(currentLayout: TileMap, pos: Vector2, roomType: RoomType, toSet: Dictionary):
	currentLayout.set_cell(pos.x, pos.y, roomType.opcode)
	
	var opcode = roomType.opcode
	
	if util.check(opcode, TOP):
		_add_if_needed(currentLayout, pos + UP_V, "BOTTOM", toSet)
		
	if util.check(opcode, BOTTOM):
		_add_if_needed(currentLayout, pos + DOWN_V, "TOP", toSet)
		
	if util.check(opcode, LEFT):
		_add_if_needed(currentLayout, pos + LEFT_V, "RIGHT", toSet)
		
	if util.check(opcode, RIGHT):
		_add_if_needed(currentLayout, pos + RIGHT_V, "LEFT", toSet)
		
func _add_if_needed(currentLayout: TileMap, pos: Vector2, group: String, toSet: Dictionary):
	
	if currentLayout.get_cellv(pos) != -1:
		return
	debug("ADDING" + str(pos) + "WITH GROUP" + group)
	if not toSet.has(pos):
		toSet[pos] = group

func _can_room_exist(currentLayout: TileMap, pos: Vector2, roomType: RoomType):
	if currentLayout.get_cellv(pos) >= 0:
		return false;
		
	var opcode = roomType.opcode

	debug("\t\tChecking TOP")
	if not _check_opcode(currentLayout, opcode, pos + UP_V, TOP, BOTTOM):
		return false
		
	debug("\t\tChecking BOTTOM")
	if not _check_opcode(currentLayout, opcode, pos + DOWN_V, BOTTOM, TOP):
		return false
		
	debug("\t\tChecking RIGHT")
	if not _check_opcode(currentLayout, opcode, pos + RIGHT_V, RIGHT, LEFT):
		return false
		
	debug("\t\tChecking LEFT")
	if not _check_opcode(currentLayout, opcode, pos + LEFT_V, LEFT, RIGHT):
		return false
	debug("\t\tPASSED ALL CHECKS")
	return true
	
func _check_opcode(currentLayout: TileMap, opcode: int,  pos: Vector2, bit: int, opposite: int):
	var neighborOpcode = currentLayout.get_cellv(pos)
	
	if neighborOpcode == -1:
		return true
		
	var check1 = util.check(opcode, bit)
	var check2 = util.check(neighborOpcode, opposite)
	
	return check1 == check2


const TOP = 1 << 0
const BOTTOM = 1 << 1
const LEFT = 1 << 2
const RIGHT = 1 << 3

class RoomType:
	var name : String
	var opcode : int
	
	func init(name : String, exits : Array):
		self.name = name
		var opcode = 0
		if (exits.has("TOP")):
			opcode = opcode | TOP;
		if (exits.has("BOTTOM")):
			opcode = opcode | BOTTOM;
		if (exits.has("LEFT")):
			opcode = opcode | LEFT;
		if (exits.has("RIGHT")):
			opcode = opcode | RIGHT;
		self.opcode = opcode
		
class Layout:
	var roomGroups : Dictionary
	var maxSize : Vector2
	
	func init(maxSize : Vector2, roomGroups : Dictionary):
		self.maxSize = Vector2(int(maxSize.x), int(maxSize.y))
		self.roomGroups = roomGroups