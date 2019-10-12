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

const TOP = 1 << 0
const BOTTOM = 1 << 1
const LEFT = 1 << 2
const RIGHT = 1 << 3

var NONE: RoomType
var DEAD_U: RoomType
var DEAD_D: RoomType
var DEAD_L: RoomType
var DEAD_R: RoomType
var LINE: RoomType
var I_SHAPE: RoomType
var L_SHAPE: RoomType
var L_90_SHAPE: RoomType
var L_180_SHAPE: RoomType
var L_270_SHAPE: RoomType
var T_SHAPE: RoomType
var T_90_SHAPE: RoomType
var T_180_SHAPE: RoomType
var T_270_SHAPE: RoomType
var FOUR_WAY: RoomType

var room_manager: RoomManager
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var roomTypeData : Dictionary = util.loadJson("res://internal/room_types.json")
	for key in roomTypeData.keys() :
		
		var data = roomTypeData[key]
		var roomType = RoomType.new()
		var roomName = data["name"]
		var roomExits = data["exits"]
		
		roomType.init(roomName, roomExits)
		roomTypes[key] = roomType
	
	NONE = roomTypes["NONE"]
	FOUR_WAY = roomTypes["4_WAY"]
	DEAD_U = roomTypes["DEAD_U"]
	DEAD_D = roomTypes["DEAD_D"]
	DEAD_L = roomTypes["DEAD_L"]
	DEAD_R = roomTypes["DEAD_R"]
	LINE = roomTypes["LINE"]
	I_SHAPE = roomTypes["I_SHAPE"]
	L_SHAPE = roomTypes["L_SHAPE"]
	L_90_SHAPE = roomTypes["L_90_SHAPE"]
	L_180_SHAPE = roomTypes["L_180_SHAPE"]
	L_270_SHAPE = roomTypes["L_270_SHAPE"]
	T_SHAPE = roomTypes["T_SHAPE"]
	T_90_SHAPE = roomTypes["T_90_SHAPE"]
	T_180_SHAPE = roomTypes["T_180_SHAPE"]
	T_270_SHAPE = roomTypes["T_270_SHAPE"]

	opcodeLookup.resize(roomTypes.size())
	
	for value in roomTypes.values():
		opcodeLookup[value.opcode] = value
		print(opcodeLookup[value.opcode].name)
	master_grammar = load_layout("res://internal/dungeon_grammar.json")
	
	room_manager = load("res://room_manager.gd").new()
	add_child(room_manager)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func load_layout(fileLoc) -> Layout:
	var layoutData = util.loadJson(fileLoc)
	
	var layout = Layout.new()
	
	var maxSizeData = layoutData["maxSize"]
	var maxSize = Vector2(maxSizeData["x"], maxSizeData["y"])

	var roomGroupsData = layoutData["roomGroups"]
	var roomGroups = Dictionary()
	
	for key in roomGroupsData.keys():
		var groupData = roomGroupsData[key]
		var array = util.WeightedArray.new()
		for roomData in groupData:
			var roomType = ""
			var weight = 1
			
			if roomData is String:
				roomType = roomData
				
			if roomData is Dictionary:
				roomType = roomData["type"]
				weight = util.get_or_default(roomData, "weight", 1)

					
			array.add(roomType, weight)
			
		roomGroups[key] = array
		
	layout.init(maxSize, roomGroups)
	
	var errors = 0
	
	errors += _check_group("TOP", layout, TOP)
	errors += _check_group("BOTTOM", layout, BOTTOM)
	errors += _check_group("LEFT", layout, LEFT)
	errors += _check_group("RIGHT", layout, RIGHT)
	errors += _check_group("START", layout, 0)
	
	assert(errors == 0)
	
	return layout

func _check_group(groupName, layout, bit) -> int:
	
	if not layout.roomGroups.has(groupName):
		print("GROUP: " + groupName + " DOES NOT EXIST")
		return 1
	
	var rooms = layout.roomGroups[groupName]
	
	if rooms.size() == 0:
		print("NO ROOMS IN: " + groupName)
		return 1
		
	var errors = 0
	for name in rooms:
		if not roomTypes.has(name):
			print("INVALID ROOM " + name + " IN " + groupName + " DOES NOT EXIST")
		
		var room = roomTypes[name]
		
		if not util.check(room.opcode, bit):
			print("INVALID ROOM " + name + " IN " + groupName)
			errors += 1
	
	return errors

func print_layout(tileMap: LayoutMap, minX, maxX, minY, maxY):
	for y in range(minY, maxY+1):
		var toPrint = ""
		for x in range(minX, maxX+1):
			toPrint += _get_char(tileMap, x, y)
		print(toPrint)

func _get_char(map: LayoutMap, x, y) -> String:
	var v = Vector2(x,y)
	
	var room = " "
	var cell = map.get_cellv(v)
	if cell != -1:
		room = HEX[cell]
	
	return room

func generate_layout(layout : Layout, ranSeed=null) -> LayoutMap:
	print("GENERATING")
	if ranSeed == null:
		randomize()
		var random_seed = randi()
		seed(random_seed)
		print("\tUsing seed: " + str(random_seed))
	else:
		seed(ranSeed)
		print("\tUsing seed: " + str(ranSeed))
	
	var map = LayoutMap.new()
	var neededRooms = Dictionary()
	
	var time_before = OS.get_ticks_usec()
	_set_room(map, Vector2(0, 0), roomTypes[layout.roomGroups["START"].getRandom()], neededRooms)
	
	#Needed Rooms need to be empty inorder for generation to be successful
	while neededRooms.size() > 0:
		
		#Get next position to set at along with the rooom
		var pos = neededRooms.keys()[0]
		var group = neededRooms[pos]
		
		#Remove this position as it WILL be set this iteration
		neededRooms.erase(pos)
		debug(neededRooms.size())
		
		#Check and make sure a room type is set
		var set = false
		
		# If the size if bigger than the configured size
		if map.sizeV.x > layout.maxSize.x:
			debug("Outside x check")
			#Make sure we are on the border
			if pos.x <= map.minV.x || map.maxV.x <= pos.x:
				debug("TERMINAL")
				#Try to set a "terminal" room type
				set = _try_terminal(map, pos, neededRooms)
		
		#Only check y if x failed
		if not set:
			# If the size if bigger than the configured size
			if map.sizeV.y > layout.maxSize.y:
				debug("Outside y check")
				#Make sure we are on the border
				if pos.y <= map.minV.y || map.maxV.y <= pos.y:
					debug("TERMINAL")
					#Try to set a "terminal" room type
					set = _try_terminal(map, pos, neededRooms)
						
		#If were are not too big or inside the border
		if not set:
			#Set a room type from the provided layout configuration
			if not _trySetGroup(map, group, pos, layout, neededRooms):
				debug("MASTER")
				# If not successful have master set a room type
				set = _trySetGroup(map, group, pos, master_grammar, neededRooms)
			else:
				set = true
		
		#Error out if the set was not successful
		assert(set)
		
		debug(str(map.minV) + " " + str(map.maxV) + " " + str(map.sizeV))
		debug(neededRooms.size())
		
	var total_time = OS.get_ticks_usec() - time_before
	print("DONE! SIZE: " + str(map.sizeV))
	#print_layout(map, minX, maxX, minY, maxY)
	
	print("Time taken to generate: " + str(total_time) + "us")
	print("Time taken to generate: " + str(total_time/1000) + "ms")
	print("Time taken to generate: " + str(total_time/1000000) + "s")
	return map

#Used to try and stop generation pass the position provided
func _try_terminal(currentLayout: LayoutMap, pos: Vector2, neededRooms: Dictionary) -> bool:
	return _trySetArray(currentLayout, TERMINAL, pos, neededRooms, false)

#Try to set a room type from the layout provided at position with the given room type
func _trySetGroup(currentLayout: LayoutMap, group: String, pos: Vector2, layout: Layout, neededRooms: Dictionary) -> bool:
	debug("\tGROUP: " + group)
	return _trySetArray(currentLayout, layout.roomGroups[group], pos, neededRooms, true)

#Try to set a room from the provided types at position
func _trySetArray(currentLayout: LayoutMap, roomNames, pos: Vector2, neededRooms: Dictionary, shuffle : bool) -> bool:
	if shuffle:
		roomNames = roomNames.shuffle()
		
	debug("Finding tile for: " + str(pos))
	#Iterate through all rooms as the first one might not be able to set
	for name in roomNames:
		
		debug("\tTrying to place " + name)
		var roomType = roomTypes[name]
		#Check if room and exist
		if _can_room_exist(currentLayout, pos, roomType):
			
			debug("\t\t\tPlaced " + name)
			#And place room
			_set_room(currentLayout, pos, roomType, neededRooms)
			return true;
	
	return false
	
func _set_room(currentLayout: LayoutMap, pos: Vector2, roomType: RoomType, neededRooms: Dictionary):
	#Set the room via opcode as it should be unique and TileMaps can't store string
	currentLayout.set_roomv(pos, roomType)
	
	var opcode = roomType.opcode
	
	#If room type as a top exit 
	if util.check(opcode, TOP):
		#Request a room that has a bottom exit be place above
		_add_if_needed(currentLayout, pos + UP_V, "BOTTOM", neededRooms)
	
	#If room type as a bottom exit
	if util.check(opcode, BOTTOM):
		#Request a room that has a top exit be place below
		_add_if_needed(currentLayout, pos + DOWN_V, "TOP", neededRooms)
	
	#If room type as a left exit
	if util.check(opcode, LEFT):
		#Request a room that has a right exit be place to the left
		_add_if_needed(currentLayout, pos + LEFT_V, "RIGHT", neededRooms)
	
	#If room type as a right exit
	if util.check(opcode, RIGHT):
		#Request a room that has a left exit be place to the right
		_add_if_needed(currentLayout, pos + RIGHT_V, "LEFT", neededRooms)

#Used to keep track of positions that need to be generated
func _add_if_needed(currentLayout: LayoutMap, pos: Vector2, group: String, neededRooms: Dictionary):
	
	#Do nothing if tile exists should be a vaild tile
	if currentLayout.get_cellv(pos) != -1:
		return
		
	debug("ADDING" + str(pos) + "WITH GROUP" + group)
	#Make sure position is not request as placement code will ensure valid type is placed
	if not neededRooms.has(pos):
		#Add position and group to neededRooms
		neededRooms[pos] = group

#Used to ensure the room type attempting to be place can live at position
func _can_room_exist(currentLayout: LayoutMap, pos: Vector2, roomType: RoomType) -> bool:
	
	#If there is a room type here, HOW DID WE GET HERE?!?!?
	if currentLayout.get_cellv(pos) >= 0:
		return false;
		
	var opcode = roomType.opcode

	debug("\t\tChecking TOP")
	#Ensure that if we have a top exit that type above (if any) has a bottom exit
	if not _check_opcode(currentLayout, opcode, pos + UP_V, TOP, BOTTOM):
		return false
		
	debug("\t\tChecking BOTTOM")
	#Ensure that if we have a bottom exit that type below (if any) has a top exit
	if not _check_opcode(currentLayout, opcode, pos + DOWN_V, BOTTOM, TOP):
		return false
		
	debug("\t\tChecking RIGHT")
	#Ensure that if we have a right exit that type to the right (if any) has a left exit
	if not _check_opcode(currentLayout, opcode, pos + RIGHT_V, RIGHT, LEFT):
		return false
		
	debug("\t\tChecking LEFT")
	#Ensure that if we have a left exit that type to the left (if any) has a right exit
	if not _check_opcode(currentLayout, opcode, pos + LEFT_V, LEFT, RIGHT):
		return false
	debug("\t\tPASSED ALL CHECKS")
	return true

#Check neighbor at position to see if its room type and the 
#current one that is being placed (opcode) is a valid pair
func _check_opcode(currentLayout: LayoutMap, opcode: int,  pos: Vector2, bit: int, opposite: int) -> bool:
	var neighborOpcode = currentLayout.get_cellv(pos)
	
	#If neighbor doesn't exist then placement is valid
	if neighborOpcode == -1:
		return true
	
	#Check if exit exists
	var check1 = util.check(opcode, bit)
	
	#Check if neighbors exit exists
	var check2 = util.check(neighborOpcode, opposite)
	
	#If both exits exists or both exist do not exist placement is valid
	return check1 == check2

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
	
	func getChar() -> String:
		return layout_gen.HEX[self.opcode]
	
class Layout:
	var roomGroups : Dictionary
	var maxSize : Vector2
	
	func init(maxSize : Vector2, roomGroups : Dictionary):
		self.maxSize = Vector2(int(maxSize.x), int(maxSize.y))
		self.roomGroups = roomGroups