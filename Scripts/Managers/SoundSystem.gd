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
