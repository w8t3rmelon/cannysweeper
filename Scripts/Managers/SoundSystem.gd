extends Node
class_name SoundSystem

var sfxTrack: AudioStreamPlayer
var musicTrack: AudioStreamPlayer

var sfxPlayback: AudioStreamPlaybackPolyphonic

var sounds = [
	preload("res://Sounds/Jumpscare.ogg"), # Enums.Sound.JUMPSCARE
	preload("res://Sounds/Break.ogg"), # Enums.Sound.BREAK
	preload("res://Sounds/Win.ogg") # Enums.Sound.WIN
]

var music = [
	preload("res://Music/MainTheme.ogg") # Enums.Music.DEFAULT
]

func _ready():
	sfxTrack = AudioStreamPlayer.new()
	sfxTrack.stream = AudioStreamPolyphonic.new()
	sfxTrack.name = "SFXTrack"
	sfxTrack.bus = &"SFX"
	add_child.call_deferred(sfxTrack)
	await get_tree().process_frame
	sfxTrack.play()
	sfxPlayback = sfxTrack.get_stream_playback()
	
	musicTrack = AudioStreamPlayer.new()
	musicTrack.name = "Music"
	musicTrack.bus = &"Music"
	add_child.call_deferred(musicTrack)
	
	print("[SoundSystem] initialised")

func snd_play(snd: Enums.Sound):
	sfxPlayback.play_stream(sounds[snd])

func mus_play(mus: Enums.Music):
	musicTrack.pitch_scale = 1
	musicTrack.stream = music[mus]
	musicTrack.play()

func mus_windup(mus: Enums.Music, duration):
	mus_play(mus)
	musicTrack.pitch_scale = 0.01
	var squeen = get_tree().create_tween()
	squeen.tween_property(musicTrack, "pitch_scale", 1, duration)
	
func mus_winddown(duration):
	var squeen = get_tree().create_tween()
	squeen.tween_property(musicTrack, "pitch_scale", 0.01, duration)
	squeen.tween_callback(func(): musicTrack.stop())
