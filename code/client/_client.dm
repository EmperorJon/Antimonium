/client
	fps = 60
	parent_type = /datum // MAGIC!!!!

/client/New()
	..()

	clients += src

	// Apply main window styling.
	winset(src, "chatoutput", {"style=\"
		BODY {font: 0.5em : 'Courier New', sans-serif; font-size: 5%; margin-left: 0.2em; color: [PALE_GREY]}
		.warning {color: [PALE_RED]}
		.danger {color: [DARK_RED]}
		.notice {color: [PALE_BLUE]}
		.speech {color: [BRIGHT_BLUE]}
		.alert {color: [BRIGHT_ORANGE]}
		\""})

	winset(src, "output", {"style=\"
		BODY {font: 1em : 'Courier New', sans-serif; margin-left: 0.2em}
		.warning {color: [PALE_RED]}
		.danger {color: [DARK_RED]}
		.notice {color: [DARK_BLUE]}
		.speech {color: [DARK_BLUE]}
		.alert {color: [BRIGHT_ORANGE]}
		\""})

	// Update UI positioning for initial screen.
	view_x = round(world.view/2)
	view_y = round(world.view/2)

	// Load preferences.
	LoadData()
	if(!key_binds)
		ResetKeybinds()
	interface = new(src)

	// Retrieve our extant role (for relogging) or make a blank one.
	for(var/thing in all_roles)
		var/datum/role/crole = thing
		if(crole.ckey == ckey)
			role = crole
			role.mob = mob
			mob.role = role
			break
	if(!role)
		role = new(src)

	// Initialize admin datums.
	AdminSetup()

	// Display the welcome splash and MOTD.
	DoClientWelcome(src)

/client/Del()
	. = ..()
	clients -= src