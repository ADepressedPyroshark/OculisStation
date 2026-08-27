 //Miscreant memory thing

/datum/memory/recruited_by_head_miscreant

/datum/memory/recruited_by_head_miscreant/get_names()
	return list("[protagonist_name] is converted into a miscreant by [antagonist_name]")

/datum/memory/recruited_by_head_miscreant/get_starts()
	return list(
		"[antagonist_name] teaches [protagonist_name] their miscreant squad's secret handshake, inducting them into the squad.",
		"[protagonist_name] is brought into [antagonist_name]'s life of schemes and mischief.",
	)
