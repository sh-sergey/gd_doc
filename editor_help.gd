extends Control

onready var text = get_node("TextPanel/Text")
onready var class_dialog = get_node("../../ClassDialog")

var s = ""

const s_keyw = "ffffb3"
const s_btype = "a4ffd4"
const s_text = "aaaaaa"
const s_smb = "badfff"


func _ready():
	
	pass

func write_doc(doc):
	text.clear()
	var name = doc.name
	var item = doc
	
	s = ""
	
	s += "[color=#%s]Class:[/color] [color=#%s]%s[/color]" % [s_keyw, s_btype, doc.name]
	if (item.inherits):
		s += "[color=#%s]\nInherits:[/color] [color=#%s][url]%s[/url][/color]" % [s_keyw, s_btype, str(item.inherits)]
	if (item.brief_description):
		s += "\n\n[color=#%s]Brief description:[/color]\n\n [color=#%s]%s[/color]" % [s_keyw, s_text, str(item.brief_description)]
	
	if (item.methods.size()):
		item.methods.sort()
		s += "\n\n[color=#%s]Methods Description:[/color]\n\n" % [s_keyw]
		for p in item.methods:
			s += "\n[color=#%s]" % [s_btype]
			if (p.return_type):
				s += p.return_type
			elif (!p.return_type):
				s += "void"
			s += "[/color] "
			
			s += "[color=#%s]%s[/color] [color=#%s]([/color]" % [s_text, str(p.name), s_smb]
			for i in range(p.arguments.size()):
				if (i > 0):
					s += "[color=#%s], [/color]" % [s_text]
				s +=  "[color=#%s]%s [/color]" % [s_btype, p.arguments[i].type]
				s += "[color=#%s]%s[/color]" % [s_text, str(p.arguments[i].name)]
			
			s += "[color=#%s])[/color]\n" % [s_smb]
			if (p.description):
				s += "\n [color=#%s]%s[/color]\n\n" % [s_text, p.description]
			
	
	if (item.signals.size()):
		item.signals.sort()
		s += "\n\n[color=#%s]Signals:[/color]\n\n" % [s_keyw]
		for p in item.signals:
			s += "[color=#%s]%s[/color] [color=#%s]([/color]" % [s_text, str(p.name), s_smb]
			for i in range(p.arguments.size()):
				if (i > 0):
					s += "[color=#%s], [/color]" % [s_text]
				s +=  "[color=#%s]%s [/color]" % [s_btype, p.arguments[i].type]
				s += "[color=#%s]%s[/color]" % [s_text, str(p.arguments[i].name)]
			
			s += "[color=#%s])[/color]" % [s_smb]
			s += " [color=#%s]%s[/color]\n" % [s_text, p.description]
	
	if (item.properties.size()):
		item.properties.sort()
		s += "\n\n[color=#%s]Properties:[/color]\n\n" % [s_keyw]
		for p in item.properties:
			s += "[color=#%s]%s[/color] [color=#%s]%s[/color]" % [s_btype, str(p.type), s_smb, str(p.name)] 
			s += " [color=#%s]%s[/color]\n" % [s_text, p.description]
	
	if (item.theme_properties.size()):
		item.theme_properties.sort()
		s += "\n\n[color=#%s]GUI theme properties:[/color]\n\n" % [s_keyw]
		for p in item.theme_properties:
			s += "[color=#%s]%s[/color] [color=#%s]%s[/color]" % [s_btype, str(p.type), s_smb, str(p.name)] 
			s += " [color=#%s]%s[/color]\n" % [s_text, p.description]
	
	if (item.constants.size()):
		item.constants.sort()
		s += "\n\n[color=#%s]Constants:[/color]\n\n" % [s_keyw]
		for p in item.constants:
			s += "[color=#%s]%s[/color] [color=#%s]=[/color] [color=#%s]%s[/color]" % [s_btype, str(p.name), s_smb, s_keyw, str(p.value)] 
			s += " [color=#%s]%s[/color]\n" % [s_text, p.description]
	
	if (item.description):
		s += "\n\n[color=#%s]Description:[/color]\n\n [color=#%s]%s[/color]" % [s_keyw, s_text, str(item.description)]
	
	text.set_bbcode(s)
	
	


func _on_Classes_pressed():
	class_dialog.show()


func _on_Text_meta_clicked(meta):
	print(meta)
