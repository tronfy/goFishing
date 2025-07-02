extends Node2D

@onready var api: PraxisEndpoints = $PraxisEndpoints

var timer = null
var busy = false
var requestQueue = []
var cell8waterdata: Dictionary

signal response_or_timeout

func AddToQueue(cell8):
	if !requestQueue.has(cell8):
		#api.response_data.connect(MyFunc.bind(cell8))
		requestQueue.append(cell8)
	if !busy:
		RunQueue()

func RunQueue():
	busy = true
	while requestQueue.size() > 0:
		var next
		#o cell8 atual pode pular a fila
		var cpc = PraxisCore.currentPlusCode.substr(0,8)
		if requestQueue.has(cpc):
			next = requestQueue.pop_at(requestQueue.find(cpc))
		else:
			#var next = requestQueue.pop_front()
			next = requestQueue.pop_back() #usando back para adquirir o mais recentemente adicionado
		print("getting " + PraxisServer.serverURL + "/Data/Terrain/" + next)
		
		api.response_data.connect(MyFunc.bind(next))
		#api.response_data.connect(func(): response_or_timeout.emit())
		api.GetTerrainData(next)
		timer = get_tree().create_timer(10).timeout.connect(MyFunc.bind("ERROR",next))
		
		#Implementação: sinal conjunto ativo quando 1. há resposta; 2. timeout
		#Quando o timer zera, cancela a requisição e libera a fila
		#await api.response_data
		await response_or_timeout
		
		#Esperar pela resposta OU timeout
	print("Fim runQueue")
	busy = false


	
func _ready() -> void:
	#$ScrollingCenteredMap.SetLoadableSource(MakeAreaNode)
	$ScrollingCenteredMap.SetLoadableSource(Cell8HasWater)

func MakeAreaNode(cell8, gridSize):
	#print(cell8)
	var results = []
	for x in gridSize:
		for y in gridSize:
			var thisCell8 = PlusCodes.ShiftCode(cell8, x, -y)
			#Make an RNG that always gives the same values for the same inputs.
			var rng = PraxisCore.GetFixedRNGForPluscode(thisCell8)
			#Pick a Cell10 inside this Cell8
			var yCoord = PlusCodes.CODE_ALPHABET_[rng.randi_range(0,19)]
			var xCoord = PlusCodes.CODE_ALPHABET_[rng.randi_range(0,19)]
			#Make a random colored square for that point.
			var color = Color.from_hsv(rng.randf(),rng.randf(),rng.randf())
			var colorRect = ColorRect.new()
			colorRect.size = Vector2(16,25)
			colorRect.color = color
			colorRect.set_meta("location", thisCell8 + yCoord + xCoord)
			results.append(colorRect)
	return results

func Cell8HasWater(cell, gridSize):
	var results = []
	for x in gridSize:
		for y in gridSize:
			var thisCell8 = PlusCodes.ShiftCode(cell, x, -y)
			
			#Se já houver dado pronto para esta célula, apenas o recupera
			#Senão, consulta a api
			var thisCell8waterdata = cell8waterdata.get(thisCell8)
			if thisCell8waterdata != null:
				#Para cada cell10 com água, cria um retângulo
				for cell10 in thisCell8waterdata:
					var colorRect = ColorRect.new()
					colorRect.size = Vector2(16,25)
					colorRect.color = Color.AQUA
					colorRect.set_meta("location", cell10)
					results.append(colorRect)
					
			else:
				#só é possível fazer uma requisição por vez
				#GET cell8 terrain data
				#api.response_data.connect(MyFunc.bind(thisCell8))
				
				#print("getting " + PraxisServer.serverURL + "/Data/Terrain/" + thisCell8)
				#api.GetTerrainData(thisCell8)
				AddToQueue(thisCell8)
			
	print('Fim')
	return results


# quando a API responde:
func MyFunc(result: PackedByteArray, cell8):
	response_or_timeout.emit()
	print("received body for " + cell8)
	api.response_data.disconnect(MyFunc)
	
	var cell10waterset: Dictionary = {} # usando como se fosse um Set
	var myStr: String = result.get_string_from_ascii()
	#Formato da string adquirida (cada linha):
	# plusCode|name|type|privacyID 
	# cell10|x|water|x <- valores de interesse, x: descartar
	for line: String in myStr.split("\n"):
		var words = line.split("|")
		if words.size() < 3:
			continue
		if words[2] == "water":
			cell10waterset[words[0]] = null
	
	cell8waterdata[cell8] = cell10waterset
	return
