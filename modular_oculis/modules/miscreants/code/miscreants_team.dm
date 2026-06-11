#define MISCREANT_OBJECTIVES_FILE "oculis/miscreant_objectives.json"

/datum/team/miscreants
	name = "\improper Band of Miscreants"
	var/max_miscreants = 4 //maximum number of miscreants that can be assigned to this team
	var/flavor_text = "If you see this miscreant flavor text, report it as a bug."
	var/ooc_text = "If you see this miscreant ooc text, report it as a bug."


/datum/team/miscreants/New(forced_max = 0, custom_name, custom_flavor, custom_objective, custom_ooc)
	. = ..()
	if(forced_max > 0)
		max_miscreants = forced_max
	else
		max_miscreants = clamp(round(GLOB.alive_player_list.len * 0.1, 1), 1, 4) //if no value is specified, make the team size 1/5th of the current pop, but never fewer than 1 nor more than 4

	var/selected_random_scenario = pick_list(MISCREANT_OBJECTIVES_FILE, "scenarios")

	if(custom_name)
		name = "\improper [custom_name]"
	else
		name = "\improper [selected_random_scenario["group_name"]]"

	if(custom_flavor)
		flavor_text = custom_flavor
	else
		flavor_text = selected_random_scenario["flavor_text"]

	var/datum/objective/miscreant/goal = new/datum/objective/miscreant
	if(custom_objective)
		goal.explanation_text = "[custom_objective]"
	else
		goal.explanation_text = "[selected_random_scenario["objective"]]"
	add_objective(goal)

	if(custom_ooc)
		ooc_text = custom_ooc
	else
		ooc_text = selected_random_scenario["ooc_notes"]


#undef MISCREANT_OBJECTIVES_FILE
