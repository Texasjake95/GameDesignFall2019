extends Node

static func loadJson(fileLoc):
	var file : File = File.new();
	file.open(fileLoc, File.READ)

	var fileData = file.get_as_text()
	file.close()
	
	var result = JSON.parse(fileData)
	
	return result.get_result()
	
static func check(opcode : int, bit : int):
	return (opcode & bit) == bit