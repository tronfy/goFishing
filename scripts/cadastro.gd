extends Node2D

func _on_submit_pressed() -> void:
	$Control/Control/Submit.disabled = false
	$Control/Control/LoginButton.disabled = false
	var body = {
		"nome": $Control/Control/UsernameInput.text,
		"senha": $Control/Control/PasswordInput.text
	}
	var json = JSON.stringify(body)
	
	var headers = ["Content-Type: application/json"]
	var url = Constants.API_URL + "/auth/cadastro"
	
	print(url)
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json)
	
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json["sucesso"]:
		var config = ConfigFile.new()
		config.set_value("player", "userID", int(json["userID"]))
		config.save("user://auth.cfg")
		print("logged in as ", json["userID"])
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		$Control/Control/Submit.disabled = true
		$Control/Control/LoginButton.disabled = true
		
