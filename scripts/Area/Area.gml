function Area() constructor {
	level = undefined
	slot = noone
	active = false
	master = undefined
	players = ds_list_create()
	
	sky = noone
	model = undefined
	collider = undefined
	things = []
	
	active_things = ds_list_create()
	particles = ds_list_create()
	lights = array_create(MAX_LIGHTS, false)
	light_data = array_create(MAX_LIGHTS * LightData.__SIZE)
	sounds = new SoundPool()
	
	bump_x = 0
	bump_y = 0
	bump_grid = ds_grid_create(1, 1)
	bump_lists = ds_grid_create(1, 1)
	
	clear_color = undefined
	ambient_color = undefined
	fog_distance = undefined
	fog_color = undefined
	wind_strength = 1
	wind_direction = undefined
	gravity = 0.6
	
	/// @desc Attempts to activate the area.
	static activate = function () {
		if active {
			exit
		}
		
		array_foreach(things, function (_element, _index) {
			with _element {
				if disposed or instance_exists(thing) {
					exit
				}
			}
			
			var _level, _area, _type, _x, _y, _z, _angle, _tag, _special, _persistent, _disposable
			
			with _element {
				_level = level
				_area = area
				_type = type
				_x = x
				_y = y
				_z = z
				_angle = angle
				_tag = tag
				_special = special
				_persistent = persistent
				_disposable = disposable
			}
			
			var _thing = noone
			
			if is_string(_type) {
				var _idx = asset_get_index(_type)
				
				if object_exists(_idx) {
					if not object_is_ancestor(_type, Thing) {
						print($"! Area.add: Tried to add non-Thing '{_type}'")
						
						return noone
					}
					
					if string_starts_with(_type, "pro") {
						print($"! Area.add: Tried to add protected Thing '{_type}'")
						
						return noone
					}
					
					_thing = instance_create_depth(_x, _y, 0, _idx)
				}
			} else {
				if object_exists(_type) {
					if not object_is_ancestor(_type, Thing) {
						print($"! Area.add: Tried to add non-Thing '{_type}'")
						
						return noone
					}
					
					_thing = instance_create_depth(_x, _y, 0, _type)
				}
			}
			
			if _thing == noone {
				var _thing_script = global.scripts.get(_type)
				
				if _thing_script == undefined {
					instance_destroy(_thing, false)
					print($"! Area.add: Unknown Thing '{_type}'")
					
					exit
				}
				
				_thing = instance_create_depth(_x, _y, 0, _thing_script.internal_parent)
				
				with _thing {
					thing_script = _thing_script
					create = _thing_script.create
					on_destroy = _thing_script.on_destroy
					clean_up = _thing_script.clean_up
					tick = _thing_script.tick
					draw = _thing_script.draw
					draw_screen = _thing_script.draw_screen
					draw_gui = _thing_script.draw_gui
				}
			}
			
			with _thing {
				level = _level
				area = _area
				area_thing = _element
				
				z = _z
				z_start = _z
				z_previous = _z
				angle = _angle
				tag = _tag
				special = _special
				f_persistent = _persistent
				f_disposable = _disposable
				f_new = true
			}
			
			ds_list_add(active_things, _thing.id)
		})
		
		
		var _thing_amount, _syncables
		
		with level {
			_thing_amount = ds_list_size(area_things)
			_syncables = syncables
		}
		
		var i = ds_list_size(active_things)
		
		repeat i {
			with active_things[| --i] {
				if f_new and not f_created {
					event_user(ThingEvents.CREATE)
					f_created = true
					
					if f_sync and area_thing != undefined {
						sync_id = area_thing.slot
						
						while ds_grid_width(_syncables) <= sync_id {
							var n = ds_grid_width(_syncables)
							
							ds_grid_resize(_syncables, -~n, 2)
							_syncables[# n, 0] = noone
							_syncables[# n, 1] = 0
						}
						
						_syncables[# sync_id, 0] = id
						_syncables[# sync_id, 1] = irandom(SYNC_INTERVAL)
					}
				}
			}
		}
		
		active = true
		
		with level {
			if area_activated != undefined {
				area_activated(other)
			}
		}
	}
	
	/// @func add(type, [x], [y], [z], [angle], [tag], [special])
	/// @desc Creates a new Thing.
	static add = function (_type, _x = 0, _y = 0, _z = 0, _angle = 0, _tag = 0, _special = undefined) {
		var _thing = noone
		
		if is_string(_type) {
			var _idx = asset_get_index(_type)
			
			if object_exists(_idx) {
				if not object_is_ancestor(_type, Thing) {
					print($"! Area.add: Tried to add non-Thing '{_type}'")
					
					return noone
				}
				
				if string_starts_with(_type, "pro") {
					print($"! Area.add: Tried to add protected Thing '{_type}'")
					
					return noone
				}
				
				_thing = instance_create_depth(_x, _y, 0, _idx)
			}
		} else {
			if object_exists(_type) {
				if not object_is_ancestor(_type, Thing) {
					print($"! Area.add: Tried to add non-Thing '{_type}'")
					
					return noone
				}
				
				_thing = instance_create_depth(_x, _y, 0, _type)
			}
		}
		
		if _thing == noone {
			var _thing_script = global.scripts.get(_type)
			
			if _thing_script == undefined {
				instance_destroy(_thing, false)
				print($"! Area.add: Unknown Thing '{_type}'")
				
				return noone
			}
			
			_thing = instance_create_depth(_x, _y, 0, _thing_script.internal_parent)
			
			with _thing {
				thing_script = _thing_script
				create = _thing_script.create
				on_destroy = _thing_script.on_destroy
				clean_up = _thing_script.clean_up
				tick = _thing_script.tick
				draw = _thing_script.draw
				draw_screen = _thing_script.draw_screen
				draw_gui = _thing_script.draw_gui
			}
		}
		
		with _thing {
			area = other
			level = other.level
			z = _z
			z_start = _z
			z_previous = _z
			angle = _angle
			tag = _tag
			special = _special
			f_new = true
			event_user(ThingEvents.CREATE)
			f_created = true
			
			if f_sync {
				var _netgame = global.netgame
				
				if _netgame != undefined {
					with _netgame {
						if not active or not master {
							instance_destroy(other.id, false)
							
							return noone
						}
					}
					
					var _syncables = level.syncables
					
					sync_id = max(ds_list_size(level.area_things), ds_grid_width(_syncables))
					
					while ds_grid_width(_syncables) <= sync_id {
						var n = ds_grid_width(_syncables)
						
						ds_grid_resize(_syncables, -~n, 2)
						_syncables[# n, 0] = noone
						_syncables[# n, 1] = 0
					}
					
					_syncables[# sync_id, 0] = id
					_syncables[# sync_id, 1] = irandom(SYNC_INTERVAL)
					
					var b = net_buffer_create(true, NetHeaders.HOST_THING)
					
					buffer_write(b, buffer_u16, sync_id)
					buffer_write(b, buffer_u32, other.slot)
					buffer_write(b, buffer_string, _thing_script != undefined ? _thing_script.name : object_get_name(object_index))
					
					var _n_pos = buffer_tell(b)
					var n = ds_list_size(net_variables)
					var j = 0
					
					buffer_write(b, buffer_u8, 0)
					
					if n {
						var i = 0
						
						repeat n {
							var _netvar = net_variables[| i]
							
							with _netvar {
								if not (flags & NetVarFlags.CREATE) {
									break
								}
								
								var _value
								
								if write != undefined {
									if is_catspeak(write) {
										write.setSelf(scope)
									}
									
									_value = write()
								} else {
									_value = struct_get_from_hash(scope, hash)
								}
								
								value = _value
								buffer_write(b, buffer_u8, i)
								buffer_write_dynamic(b, _value)
								++j
							}
							
							++i
						}
					}
					
					buffer_poke(b, _n_pos, buffer_u8, j)
					print($"Area.add: Sent new syncable {sync_id} for processing ({n} variables)")
					_netgame.send(SEND_OTHERS, b)
				}
			}
		}
		
		// Failsafe, Things can get destroyed while being created
		if not instance_exists(_thing) {
			return noone
		}
		
		ds_list_add(active_things, _thing.id)
		
		return _thing
	}
	
	/// @func add_particle(x, y, z)
	/// @desc Creates a new particle as long as there are less than MAX_PARTICLES.
	static add_particle = function (_x, _y, _z) {
		var _particle
		var _dead_particle = ds_stack_pop(global.dead_particles)
		
		// Add or replace particle data
		if _dead_particle == undefined {
			// Create a new particle or replace the oldest one
			if ds_list_size(particles) < MAX_PARTICLES {
				_particle = array_create(ParticleData.__SIZE)
				ds_list_add(particles, _particle)
			} else {
				_particle = particles[| 0]
				ds_list_delete(particles, 0)
				ds_list_add(particles, _particle)
			}
		} else {
			// Replace the oldest dead particle
			_particle = _dead_particle
			ds_list_add(particles, _particle)
		}
		
		_particle[ParticleData.DEAD] = false
		_particle[ParticleData.IMAGE] = undefined
		_particle[ParticleData.FRAME] = 0
		_particle[ParticleData.FRAME_SPEED] = 1
		_particle[ParticleData.ANIMATION] = ParticleAnimations.PLAY
		_particle[ParticleData.ALPHA_TEST] = 0
		_particle[ParticleData.WIDTH] = 1
		_particle[ParticleData.WIDTH_SPEED] = 0
		_particle[ParticleData.HEIGHT] = 1
		_particle[ParticleData.HEIGHT_SPEED] = 0
		_particle[ParticleData.ANGLE] = 0
		_particle[ParticleData.ANGLE_SPEED] = 0
		_particle[ParticleData.COLOR] = c_white
		_particle[ParticleData.ALPHA] = 1
		_particle[ParticleData.ALPHA_SPEED] = 0
		_particle[ParticleData.BRIGHT] = 0
		_particle[ParticleData.BRIGHT_SPEED] = 0
		_particle[ParticleData.TICKS] = infinity
		_particle[ParticleData.X] = _x
		_particle[ParticleData.Y] = _y
		_particle[ParticleData.Z] = _z
		_particle[ParticleData.FLOOR_Z] = -infinity
		_particle[ParticleData.CEILING_Z] = infinity
		_particle[ParticleData.X_SPEED] = 0
		_particle[ParticleData.Y_SPEED] = 0
		_particle[ParticleData.Z_SPEED] = 0
		_particle[ParticleData.X_FRICTION] = 1
		_particle[ParticleData.Y_FRICTION] = 1
		_particle[ParticleData.Z_FRICTION] = 1
		_particle[ParticleData.GRAVITY] = 0
		_particle[ParticleData.MAX_FLY_SPEED] = infinity
		_particle[ParticleData.MAX_FALL_SPEED] = -infinity
		
		return _particle
	}
	
	/// @func count(type)
	/// @desc Returns the amount of the specified Thing and its children in the area.
	static count = function (_type) {
		var n = 0
		var i = ds_list_size(active_things)
		
		repeat i {
			if active_things[| --i].is_ancestor(_type) {
				++n
			}
		}
		
		return n
	}
	
	/// @func nearest(x, y, z, type)
	/// @desc Returns the specified Thing or its children nearest to the given point.
	static nearest = function (_x, _y, _z, _type) {
		var _result = noone
		var _distance = infinity
		
		var i = ds_list_size(active_things)
		
		repeat i {
			with active_things[| --i] {
				if is_ancestor(_type) {
					var _newdist = point_distance_3d(_x, _y, _z, x, y, z)
					
					if _newdist < _distance {
						_result = id
						_distance = _newdist
					}
				}
			}
		}
		
		return _result
	}
	
	/// @func furthest(x, y, z, type)
	/// @desc Returns the specified Thing or its children farthest from the given point.
	static furthest = function (_x, _y, _z, _type) {
		var _result = noone
		var _distance = -infinity
		
		var i = ds_list_size(active_things)
		
		repeat i {
			with active_things[| --i] {
				if is_ancestor(_type) {
					var _newdist = point_distance_3d(_x, _y, _z, x, y, z)
					
					if _newdist > _distance {
						_result = id
						_distance = _newdist
					}
				}
			}
		}
		
		return _result
	}
	
	/// @desc Attempts to deactivate the area, clearing everything in the process.
	static deactivate = function () {
		if not active {
			exit
		}
		
		if ds_list_size(players) {
			exit
		}
		
		master = undefined
		
		var _cant_deactivate = false
		var i = ds_list_size(active_things)
		
		repeat i {
			var _thing = active_things[| --i]
			
			if not instance_exists(_thing) {
				ds_list_delete(active_things, i)
				
				continue
			}
			
			if _thing.f_persistent {
				_thing.f_new = false
				_cant_deactivate = true
				
				continue
			}
			
			instance_destroy(_thing, false)
		}
		
		if _cant_deactivate {
			print($"! Area.deactivate: Tried to deactivate area {slot} with {ds_list_size(active_things)} Things remaining")
			
			exit
		}
		
		ds_list_clear(particles)
		sounds.clear()
		active = false
		
		with level {
			if area_deactivated != undefined {
				area_deactivated(other)
			}
		}
	}
	
	static destroy = function () {
		var i = ds_list_size(active_things)
		
		repeat i {
			var _thing = active_things[| --i]
			
			if instance_exists(_thing) {
				instance_destroy(_thing, false)
			} else {
				ds_list_delete(active_things, i)
			}
		}
		
		ds_list_destroy(active_things)
		ds_list_destroy(particles)
		ds_list_destroy(players)
		sounds.destroy()
		ds_grid_destroy(bump_grid)
		
		var i = 0
		
		repeat ds_grid_width(bump_lists) {
			var j = 0
			
			repeat ds_grid_height(bump_lists) {
				ds_list_destroy(bump_lists[# i, j++])
			}
			
			++i
		}
		
		ds_grid_destroy(bump_lists)
	}
	
	static find_tag = function (_tag) {
		static things = []
		
		var i = 0
		var j = 0
		
		switch _tag {
			case ThingTags.PLAYERS:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if object_index == PlayerPawn or object_is_ancestor(object_index, PlayerPawn) {
							things[j++] = id
						}
					}
				}
			break
			
			case ThingTags.PLAYER_SPAWNS:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if object_index == PlayerSpawn or object_is_ancestor(object_index, PlayerSpawn) {
							things[j++] = id
						}
					}
				}
			break
			
			default:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if tag == _tag {
							things[j++] = id
						}
					}
				}
		}
		
		array_resize(things, j)
		
		return things
	}
	
	static exists = function (_thing) {
		if is_string(_thing) {
			var i = 0
			
			repeat ds_list_size(active_things) {
				if active_things[| i++].is_ancestor(_thing) {
					return true
				}
			}
			
			return false
		}
		
		if is_real(_thing) {
			return array_length(find_tag(_thing)) > 0
		}
		
		return instance_exists(_thing)
	}
}