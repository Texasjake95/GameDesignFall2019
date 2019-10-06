extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Attempting to load rooms")
	loadRooms("entity")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

static func _toLoc(file : String):
	if file.begins_with("res://"):
		return file.right("res://".length ())
	return file

static func removeExt(file : String):
	var index = file.rfind(".")
	if index == -1:
		return file
	return file.left(index)

static func loadRooms(directory, pathFromRoot = ""):
	
	var dir : Directory = Directory.new()
	dir.open(directory)

	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		var fileLoc = directory +"/" + file
		
		var fileFromRoot = pathFromRoot
		
		if fileFromRoot != "":
			fileFromRoot += "/"
		fileFromRoot += file
		
		if file == "":
			return
		
		if file == "." || file == "..":
			continue
		
		if dir.current_is_dir():
			loadRooms(fileLoc, fileFromRoot)
		else:
			loadRoom(fileLoc, fileFromRoot)

static func loadRoom(fileLoc, pathFromRoot):
	
	if true:
		print(removeExt(pathFromRoot))
		return
	
	var file : File = File.new();
	file.open(fileLoc, File.READ)

	var fileData = file.get_as_text()
	file.close()
	
	var roomJson = JSON.parse(fileData)
	
	pass
