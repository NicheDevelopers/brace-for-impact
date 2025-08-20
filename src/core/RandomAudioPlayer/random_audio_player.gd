extends Node3D

class_name RandomAudioPlayer

@export var volume_db: float = 0.0
@export var streams: Array[AudioStream] = []

## Whether the audio is played with an AudioStreamPlayer3D
## and is positional, as opposed to a non-positional playback
## for which a regular AudioStreamPlayer is used
@export var positional: bool = false

## Whether the audio player is fully random and allows
## playing the same stream twice in a row or ensures
## subsequent streams are different (as long as there
## are at least two streams)
@export var allow_stream_repeat: bool = false

## Whether a new random stream is played automatically when
## this node is created and when a previous stream has ended
@export var autoplay: bool = false

@export_group("Autoplay", "autoplay")
## The delay between automatic stream playbacks
@export var autoplay_delay_ms: float = 1000.0

## The audio player node used. Is set to an AudioStreamPlayer
## or AudioStreamPlayer3D instance based on [member positional].
@onready var audio_player

var last_stream: AudioStream = null

func _ready():
	if positional:
		audio_player = $AudioStreamPlayer3D
	else:
		audio_player = $AudioStreamPlayer
	
	audio_player.volume_db = volume_db
	
	if autoplay:
		audio_player.finished.connect(func() -> void:
			await get_tree().create_timer(autoplay_delay_ms / 1000).timeout
			if autoplay:
				play()
		)
		play()

## Play one of the sounds from the set, chosen at random
func play(from_position: float = 0.0):
	if streams.is_empty():
		push_warning("No tracks assigned to the RandomAudioPlayer")
		return
	
	var new_stream_ix = Random.index(streams)
	if not allow_stream_repeat and streams.size() > 1:
		if streams[new_stream_ix] == last_stream:
			new_stream_ix = (new_stream_ix + 1) % streams.size()
	
	last_stream = streams[new_stream_ix]
	audio_player.stream = streams[new_stream_ix]
	audio_player.play(from_position)

func stop():
	autoplay = false
	audio_player.stop()
