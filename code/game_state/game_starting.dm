/datum/game_state/starting
	ident = GAME_STARTING

/datum/game_state/starting/Start()

	to_chat(world, "<h3><span class='notice'><b>The game is starting!</b></span></h3>")

	// Get a list of everyone who is readied up.
	var/list/players_to_allocate_roles = list()
	for(var/thing in new_players)
		var/mob/abstract/new_player/player = thing
		if(player.ready)
			players_to_allocate_roles += player

	// No players? No round.
	if(!isnull(config["enforce_minimum_player_count"]) && players_to_allocate_roles.len < config["enforce_minimum_player_count"])
		to_chat(world, "<h3><b>Could not start round - no readied players!</b></h3>")
		SwitchGameState(/datum/game_state/waiting)
		return

	// Assign a job datum to each readied player at random until we've
	// populated all mandatory job slots.
	players_to_allocate_roles = shuffle(players_to_allocate_roles)
	var/list/players_to_spawn = list()
	var/list/remaining_jobs = low_priority_jobs.Copy()

	for(var/thing in high_priority_jobs)
		var/datum/job/job = thing
		while(job.filled_slots < job.minimum_slots && players_to_allocate_roles.len)
			var/mob/abstract/new_player/player = pick(players_to_allocate_roles)
			players_to_allocate_roles -= player
			players_to_spawn[player] = job
			job.filled_slots++
		if(!players_to_allocate_roles.len)
			break
		high_priority_jobs -= job
		// If there's still room in this job, we can populate it with overflow players later.
		if(job.filled_slots < job.maximum_slots)
			remaining_jobs += job

	// If we can't staff the mandatory jobs, fail out.
	if(config["enforce_minimum_job_slots"] && high_priority_jobs.len)
		to_chat(world, "<h3><b>Could not start round - not enough players to populate mandatory roles!</b></h3>")
		SwitchGameState(/datum/game_state/waiting)
		return

	// Assign role-overriding antagonists here, when they exist.

	// If we still have players to give jobs, assign them the low priority roles at random.
	if(players_to_allocate_roles.len)
		while(remaining_jobs.len)
			var/datum/job/job = pick(remaining_jobs)
			if(job.filled_slots < job.maximum_slots && players_to_allocate_roles.len)
				var/mob/abstract/new_player/player = pick(players_to_allocate_roles)
				players_to_allocate_roles -= player
				players_to_spawn[player] = job
				job.filled_slots++
			if(job.filled_slots >= job.maximum_slots)
				remaining_jobs -= job

	// If we STILL have leftover players, assign them the default latejoin role.
	if(players_to_allocate_roles.len)
		for(var/thing in players_to_allocate_roles)
			var/mob/abstract/new_player/player = thing
			players_to_spawn[player] = default_latejoin_role
	players_to_allocate_roles.Cut()

	// Assign role-independant antagonists here, when they exist.

	// Apply job templates and spawn/equip the mobs.
	for(var/thing in players_to_spawn)
		var/datum/job/job = players_to_spawn[thing]
		var/mob/spawned_player = job.Equip(thing)
		job.Welcome(spawned_player)
		job.Place(spawned_player)

	SwitchGameState(/datum/game_state/running)

/datum/game_state/starting/OnLogin(var/client/player)
	to_chat(world, "<h3><span class='notice'><b>The game is starting!</b></span></h3>")
