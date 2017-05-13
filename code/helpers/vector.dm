var/list/vector_list = list()

/vector
	var/atom/movable/owner
	var/coord_x		//current x location (in pixel coordinates)
	var/coord_y		//current y location (in pixel coordinates)
	var/inc_x		//x increment per step
	var/inc_y		//y increment per step
	var/move_delay	//ticks between each move
	var/pixel_speed	//speed in pixels per tick

/*
Inputs:
	source = the atom being moved along the vector

	start = the starting location

	end = the target location (currently only used for calculating the vector direction)

	speed = distance travelled in turfs-per-second

	xo = pixel_x offset of the target location (optional)

	yo = pixel_y offset of the target location (optional)
*/
/vector/New(atom/movable/source, start, end, speed = 20, xo = 16, yo = 16)
	vector_list += src
	owner = source

	var/turf/src_turf = get_turf(start)
	var/turf/target_turf = get_turf(end)

	owner.ForceMove(src_turf)

	//convert to pixel coordinates
	var/start_loc_x = src_turf.x * TILE_WIDTH + (TILE_WIDTH / 2)
	var/start_loc_y = src_turf.y * TILE_HEIGHT + (TILE_HEIGHT / 2)

	var/target_loc_x = target_turf.x * TILE_WIDTH + xo
	var/target_loc_y = target_turf.y * TILE_HEIGHT + yo

	var/dist_x = target_loc_x - start_loc_x
	var/dist_y = target_loc_y - start_loc_y

	//convert turfs-per-second to pixels-per-tick
	pixel_speed = (speed * TILE_WIDTH) / world.fps

	//first we work out how far we move each movement
	if(abs(dist_x) > abs(dist_y))
		//x is dominant direction
		inc_x = TILE_WIDTH * sign(dist_x)
		inc_y = (dist_y / dist_x) * inc_x //multiply the x increment by the y to x ratio
	else
		//y is the dominant direction
		inc_y = TILE_HEIGHT * sign(dist_y)
		inc_x = (dist_x / dist_y) * inc_y //multiply the y increment by the x to y ratio

	//now we work out how many ticks between each move
	var/inc_h = hypotenuse(inc_x, inc_y) //true pixel distance travelled for a full move
	move_delay = inc_h / pixel_speed //ticks between each move - floored so there will be some variation, but should be minor

	coord_x = start_loc_x
	coord_y = start_loc_y

//call to kick off the vector movement
// allows the calling proc to continue and runs immediately after the parent proc sleeps or ends
/vector/proc/Initialize()
	set waitfor = 0

	while(owner)
		//increment our location in pixel space
		coord_x += inc_x
		coord_y += inc_y

		//convert our pixel space location to world coordinates and pixel offset
		var/world_x = coord_x / TILE_WIDTH
		var/loc_x = floor(world_x)
		var/pix_x = ((world_x - loc_x) * 32) - 16

		var/world_y = coord_y / TILE_WIDTH
		var/loc_y = floor(world_y)
		var/pix_y = ((world_y - loc_y) * 32) - 16

		var/turf/T = locate(loc_x, loc_y, owner.z)
		if(T)
			owner.appearance_flags = LONG_GLIDE
			owner.glide_size = 32
			if(!owner.Move(T))
				vector_list -= src
				return
			owner.pixel_x = pix_x
			owner.pixel_y = pix_y
		else
			vector_list -= src
			return

		wait_nt(move_delay)
	vector_list -= src
