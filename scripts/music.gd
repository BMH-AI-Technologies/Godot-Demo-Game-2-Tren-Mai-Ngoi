extends AudioStreamPlayer
# Persistent background music survives a level restart.
func _ready() -> void:
	var track: AudioStreamWAV = load("res://assets/audio/night.wav")
	track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	track.loop_end = track.data.size() / 2
	stream = track
	volume_db = -15
	play()

func _exit_tree() -> void:
	stop()
	stream = null

