extends Node

var version

var class_list = {}

class ArgumentDoc:
	var name
	var type
	var default_value
	
	func get_dict():
		var dict = {}
		dict["name"] = name
		dict["type"] = type
		dict["default_value"] = default_value
		return dict

class MethodDoc:
	var name
	var return_type
	var qualifiers
	var description
	var arguments = []
	
	func get_dict():
		var dict = {}
		dict["name"] = name
		dict["return_type"] = return_type
		dict["qualifiers"] = qualifiers
		dict["description"] = description
		dict["arguments"] = []
		for p in arguments:
			dict["arguments"].append(p.get_dict())
		return dict

class ConstantDoc:
	var name
	var value
	var description
	
	func get_dict():
		var dict = {}
		dict["name"] = name
		dict["value"] = value
		dict["description"] = description
		return dict

class PropertyDoc:
	var name
	var type
	var description
	
	func get_dict():
		var dict = {}
		dict["name"] = name
		dict["type"] = type
		dict["description"] = description
		return dict

class ClassDoc:
	var name
	var inherits
	var category
	var brief_description
	var description
	var methods = []
	var signals = []
	var constants = []
	var properties = []
	var theme_properties = []
	
	func print_vars():
		var dict = {}
		dict["name"] = name
		dict["inherits"] = inherits
		dict["category"] = category
		dict["brief_description"] = brief_description
		dict["description"] = description
		
		dict["methods"] = []
		for p in methods:
			dict["methods"].append(p.get_dict())
		
		dict["signals"] = []
		for p in signals:
			dict["signals"].append(p.get_dict())
		
		dict["constants"] = []
		for p in constants:
			dict["constants"].append(p.get_dict())
		
		dict["properties"] = []
		for p in properties:
			dict["properties"].append(p.get_dict())
		
		dict["theme_properties"] = []
		for p in theme_properties:
			dict["theme_properties"].append(p.get_dict())
		
		return dict.to_json()

func _ready():
	print(load_doc("res://classes.xml"))
	print(version)
#	print(class_list["Node"].print_vars())

func load_doc(path):
	var parser = XMLParser.new()
	var err = parser.open(path)
	if (err):
		return err
	else:
		return _load(parser)

func _parse_methods(parser, methods):
	var section = parser.get_node_name()
	var element = section.substr(0, section.length() - 1)
	var err = OK
	
	err = parser.read()
	while (err == OK):
		if (parser.get_node_type() == XMLParser.NODE_ELEMENT):
			if (parser.get_node_name() == element):
				var method = MethodDoc.new()
				
				if (!parser.has_attribute("name")):
					return ERR_FILE_CORRUPT
				method.name = parser.get_named_attribute_value("name")
				if (parser.has_attribute("qualifiers")):
					method.qualifiers = parser.get_named_attribute_value("qualifiers")
				
				err = parser.read()
				while (err == OK):
					if (parser.get_node_type() == XMLParser.NODE_ELEMENT):
						var name = parser.get_node_name()
						if (name == "return"):
							if (!parser.has_attribute("type")):
								return ERR_FILE_CORRUPT
							method.return_type = parser.get_named_attribute_value("type")
						elif (name == "argument"):
							var argument = ArgumentDoc.new()
							
							if (!parser.has_attribute("name")):
								return ERR_FILE_CORRUPT
							argument.name = parser.get_named_attribute_value("name")
							if (!parser.has_attribute("type")):
								return ERR_FILE_CORRUPT
							argument.type = parser.get_named_attribute_value("type")
							
							method.arguments.push_back(argument)
						elif (name == "description"):
							parser.read()
							if (parser.get_node_type() == XMLParser.NODE_TEXT):
								method.description = parser.get_node_data().strip_edges()
					elif (parser.get_node_type() == XMLParser.NODE_ELEMENT_END && parser.get_node_name() == element):
						break
					err = parser.read()
				methods.push_back(method)
			else:
				err = ERR_FILE_CORRUPT
				break
		elif (parser.get_node_type() == XMLParser.NODE_ELEMENT_END && parser.get_node_name() == section):
			break
		else:
			parser.read()
	
	return OK

func _load(parser):
	var err = OK
	
	err = parser.read()
	while (err == OK):
		if (parser.get_node_type() == XMLParser.NODE_ELEMENT):
			if (parser.get_node_name() == "doc"):
				break
			elif (!parser.is_empty()):
				parser.skip_section() # unknown section, likely headers
		err = parser.read()
	
	if (parser.has_attribute("version")):
		version = parser.get_named_attribute_value("version")
	
	err = parser.read()
	while (err == OK):
		if (parser.get_node_type() == XMLParser.NODE_ELEMENT_END && parser.get_node_name() == "doc"):
			break # end of <doc>
		
		if (parser.get_node_type() != XMLParser.NODE_ELEMENT):
			continue # no idea what this may be, but skipping anyway
		
		if (parser.get_node_name() != "class"):
			return ERR_FILE_CORRUPT
		
		if (!parser.has_attribute("name")):
			return ERR_FILE_CORRUPT
		var name = parser.get_named_attribute_value("name")
		class_list[name] = ClassDoc.new()
		var c = class_list[name]
		
		#print("class:\"%s\"" % [name])
		c.name = name
		if (parser.has_attribute("inherits")):
			c.inherits = parser.get_named_attribute_value("inherits")
		if (parser.has_attribute("category")):
			c.category = parser.get_named_attribute_value("category")
		
		while (parser.read() == OK):
			if (parser.get_node_type() == XMLParser.NODE_ELEMENT):
				name = parser.get_node_name()
				
				if (name == "brief_description"):
					parser.read()
					if (parser.get_node_type() == XMLParser.NODE_TEXT):
						c.brief_description = parser.get_node_data().strip_edges()
				elif (name == "description"):
					parser.read()
					if (parser.get_node_type() == XMLParser.NODE_TEXT):
						c.description = parser.get_node_data().strip_edges()
				elif (name == "methods"):
					err = _parse_methods(parser, c.methods)
					if (err):
						break
				elif (name == "signals"):
					err = _parse_methods(parser, c.signals)
					if (err):
						break
				elif (name == "members"):
					while (parser.read() == OK):
						if (parser.get_node_type() == XMLParser.NODE_ELEMENT):
							name = parser.get_node_name()
							if (name == "member"):
								var prop = PropertyDoc.new()
								
								if (!parser.has_attribute("name")):
									return ERR_FILE_CORRUPT
								prop.name = parser.get_named_attribute_value("name")
								
								if (!parser.has_attribute("type")):
									return ERR_FILE_CORRUPT
								prop.type = parser.get_named_attribute_value("type")
								
								parser.read()
								if (parser.get_node_type() == XMLParser.NODE_TEXT):
									prop.description = parser.get_node_data().strip_edges()
								c.properties.push_back(prop)
							else:
								return ERR_FILE_CORRUPT
						elif (parser.get_node_type() == XMLParser.NODE_ELEMENT_END && parser.get_node_name() == "members"):
							break # end of <members>
				elif (name == "theme_items"):
					while (parser.read() == OK):
						if (parser.get_node_type() == XMLParser.NODE_ELEMENT):
							name = parser.get_node_name()
							if (name == "theme_item"):
								var prop = PropertyDoc.new()
								
								if (!parser.has_attribute("name")):
									return ERR_FILE_CORRUPT
								prop.name = parser.get_named_attribute_value("name")
								
								if (!parser.has_attribute("type")):
									return ERR_FILE_CORRUPT
								prop.type = parser.get_named_attribute_value("type")
								
								parser.read()
								if (parser.get_node_type() == XMLParser.NODE_TEXT):
									prop.description = parser.get_node_data().strip_edges()
								c.theme_properties.push_back(prop)
							else:
								return ERR_FILE_CORRUPT
						elif (parser.get_node_type() == XMLParser.NODE_ELEMENT_END && parser.get_node_name() == "theme_items"):
							break # end of <theme_items>
				elif (name == "constants"):
					while (parser.read() == OK):
						if (parser.get_node_type() == XMLParser.NODE_ELEMENT):
							name = parser.get_node_name()
							if (name == "constant"):
								var constant = ConstantDoc.new()
								
								if (!parser.has_attribute("name")):
									return ERR_FILE_CORRUPT
								constant.name = parser.get_named_attribute_value("name")
								
								if (!parser.has_attribute("value")):
									return ERR_FILE_CORRUPT
								constant.value = parser.get_named_attribute_value("value")
								
								parser.read()
								if (parser.get_node_type() == XMLParser.NODE_TEXT):
									constant.description = parser.get_node_data().strip_edges()
								c.constants.push_back(constant)
							else:
								return ERR_FILE_CORRUPT
						elif (parser.get_node_type() == XMLParser.NODE_ELEMENT_END && parser.get_node_name() == "constants"):
							break # end of <constants>
				else:
					return ERR_FILE_CORRUPT
				
			elif (parser.get_node_type() == XMLParser.NODE_ELEMENT_END && parser.get_node_name() == "class"):
				break # end of <asset>
#		print(c.print_vars())
		err = parser.read()
	
	return err
