extends Control


func _process(delta):
	$Label.text = str(Performance.get_monitor(Performance.TIME_FPS))
