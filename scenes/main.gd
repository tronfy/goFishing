extends Node2D

#Guardando para usar depois
#func RequestPerms():
#	if OS.get_name() == "Windows":
#		HavePerms()
#		return
#	var granted = OS.request_permissions()
#	if granted == true:
#		PraxisCore.perm_check("android.permission.ACCESS_FINE_LOCATION", true)
#		HavePerms()
		
@onready var api: PraxisEndpoints = $PraxisEndpoints

const FISHING_DIST = 3
const DRAW_WATER = false

var timer = null
var busy = false
var requestQueue = []
var cell8waterdata: Dictionary

signal response_or_timeout

func AddToQueue(cell8):
	if !requestQueue.has(cell8):
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
		#print("getting " + PraxisServer.serverURL + "/Data/Terrain/" + next)
		
		api.response_data.connect(MyFunc.bind(next))
		#api.response_data.connect(func(): response_or_timeout.emit())
		api.GetTerrainData(next)
		
		timer = Timer.new()
		add_child(timer)
		timer.wait_time = 10.0
		timer.one_shot = true
		timer.timeout.connect(MyFunc.bind("TIMEOUT", next))
		timer.start()
		#timer = get_tree().create_timer(10).timeout.connect(func(): response_or_timeout.emit())
		#timer = get_tree().create_timer(10).timeout.connect(func(): print("Timeout!"))
		
		#Implementação: sinal conjunto ativo quando 1. há resposta; 2. timeout
		#Quando o timer zera, cancela a requisição e libera a fila
		#await api.response_data
		await response_or_timeout
		remove_child(timer)
		
		#Esperar pela resposta OU timeout
	#print("Fim runQueue")
	busy = false



func _ready() -> void:
	$ScrollingCenteredMap.SetLoadableSource(Cell8HasWater)
	PraxisCore.plusCode_changed.connect(plusCode_changed)
	# avaliar trocar o sinal pelo de atualização do mapa
	# motivo: ser possível atualizar o mapa forçadamente quando uma resposta da api chega
	# e assim atualizar se há água por perto sem precisar de quaisquer movimentos


func Cell8HasWater(cell, gridSize):
	var results = []
	for x in gridSize:
		for y in gridSize:
			var thisCell8 = PlusCodes.ShiftCode(cell, x, -y)
			
			#Se já houver dado pronto para esta célula, apenas o recupera
			#Senão, consulta a api
			var thisCell8waterdata = cell8waterdata.get(thisCell8)
			if thisCell8waterdata == null:
				AddToQueue(thisCell8)
			elif DRAW_WATER:
				#Para cada cell10 com água, cria um retângulo
				for cell10 in thisCell8waterdata:
					var colorRect = ColorRect.new()
					colorRect.size = Vector2(16,25)
					colorRect.color = Color.AQUA
					colorRect.set_meta("location", cell10)
					results.append(colorRect)
			
	#print('Fim')
	return results


# quando a API responde:
func MyFunc(result, cell8):
	timer.stop()
	api.response_data.disconnect(MyFunc)
	response_or_timeout.emit()
	if (typeof(result) == TYPE_STRING):
	#if (result == "ERROR" || result == "TIMEOUT"):
		print (result + ' ' + cell8)
		return
	ProcessCellForWater(result, cell8)

func ProcessCellForWater(result: PackedByteArray, cell8):
	#response_or_timeout.emit()
	#print("received body for " + cell8)
	
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


func plusCode_changed(curr, prev):
	waterNearby(curr)
	
func waterNearby(curr):
	# calculo simples de distância em pluscode10
	#var cpc = PraxisCore.currentPlusCode # pluscode10
	var cells = PlusCodes.GetNearbyCells(curr, FISHING_DIST)
	for cell in cells:
		var cell8 = cell.substr(0,8)
		if cell8waterdata.has(cell8):
			if cell8waterdata[cell8].has(cell):
				# há água por perto!
				print("ÁGUA À VISTA")
				$Control/FishButton.disabled = false
				return
	$Control/FishButton.disabled = true
