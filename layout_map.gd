extends TileMap

class_name LayoutMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


const v1 = Vector2(1,1)

var minV = Vector2()
var maxV = Vector2()

var sizeV 

var randSeed = 0

func set_seed(randSeed):
	self.randSeed = randSeed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _update_size(pos):
	minV.x = min(pos.x, minV.x)
	minV.y = min(pos.y, minV.y)
	maxV.x = max(pos.x, maxV.x)
	maxV.y = max(pos.y, maxV.y)
	
	sizeV = maxV - minV + v1
	
func set_cellv(pos, tile, flip_x=false, flip_y=false, transpose=false):
	.set_cellv(pos, tile, flip_x, flip_y, transpose)
	_update_size(pos)

func set_cell(x, y, tile, flip_x=false, flip_y=false, transpose=false, autotile_coord=Vector2( 0, 0 ) ):
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	_update_size(Vector2(x, y))

func get_room_typev(pos):
	var tile = get_cellv(pos)
	if tile == -1:
		return null
	return layout_gen.opcodeLookup[tile]

func get_room_type(x, y):
	return get_room_typev(Vector2(x, y))
	
func set_roomv(pos, roomType):
	set_cellv(pos, roomType.opcode)

func set_room(x, y, roomType):
	set_cell(x, y, roomType.opcode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
