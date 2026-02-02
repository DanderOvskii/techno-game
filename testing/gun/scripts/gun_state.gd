class_name GunState extends Node

var Gun_controller: GunController

func _ready()->void:
    if %GunStateMashine and %GunStateMashine is GunStateMashine:
        Gun_controller = %GunStateMashine.Gun_controller