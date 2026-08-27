#define MISCREANT_OBJECTIVES_FILE "oculis/miscreant_objectives.json"


/datum/antagonist/miscreant
	name = "\improper Miscreant"
	roundend_category = "miscreants"
	antagpanel_category = "Miscreants"
	pref_flag = ROLE_MISCREANT
	preview_outfit = /datum/outfit/miscreant
	antag_moodlet = /datum/mood_event/miscreant
	can_assign_self_objectives = TRUE
	default_custom_objective = "Perform an overcomplicated heist on valuable Nanotrasen assets."
	hud_icon = 'modular_oculis/modules/miscreants/icons/miscreants_hud.dmi'
	antag_hud_name = "miscreant"

	var/datum/team/miscreant/miscreant_team

/datum/antagonist/rev/can_be_owned(datum/mind/new_owner)
	if(new_owner.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
		return FALSE
	if(new_owner.current && HAS_MIND_TRAIT(new_owner.current, TRAIT_UNCONVERTABLE))
		return FALSE
	return ..()

/datum/antagonist/miscreant/proc/can_be_converted(mob/living/candidate)
	if(!candidate.mind)
		return FALSE
	if(!can_be_owned(candidate.mind))
		return FALSE
	var/mob/living/carbon/C = candidate //Check to see if the potential miscreant is implanted
	if(!istype(C)) //Can't convert simple animals
		return FALSE
	return TRUE

/datum/antagonist/miscreant/proc/add_miscreant(datum/mind/miscreant_mind)
	if(!can_be_converted(miscreant_mind.current))
		return FALSE

	miscreant_mind.add_memory(/datum/memory/recruited_by_head_miscreant, protagonist = miscreant_mind.current, antagonist = owner.current)
	miscreant_mind.add_antag_datum(/datum/antagonist/miscreant,miscreant_team)
	return TRUE

/datum/antagonist/miscreant/create_team(datum/team/miscreants/new_team)
	if(!new_team)
		team = new()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/miscreant/get_team()
	return team

/datum/antagonist/miscreant/on_gain()
	objectives += team.objectives
	finalize_miscreant()

	if (team.miscreants_left <= 0)
		return ..()

	var/mob/living/carbon/carbon_owner = owner.current
	if (!istype(carbon_owner))
		return ..()

	grant_conversion_skills()
	return ..()

/datum/antagonist/miscreant/on_removal()
	remove_conversion_skills()
	return ..()

/// Give us the ability to add another miscreant
/datum/antagonist/miscreant/proc/grant_conversion_skills()
	var/datum/action/cooldown/miscreant_handshake/shaker = new

	shaker.Grant(owner)
	shaker_ref = WEAKREF(shaker)

/// Take away the ability to add more miscreants
/datum/antagonist/miscreant/proc/remove_conversion_skills()
	var/datum/action/cooldown/miscreant_handshake/shaker = shaker_ref?.resolve()
	if (!isnull(shaker))
		QDEL_NULL(shaker)
	shaker = null

/datum/antagonist/miscreant/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)

	final_icon.Blend(make_assistant_icon("Business Hair"), ICON_UNDERLAY, -8, 0)
	final_icon.Blend(make_assistant_icon("CIA"), ICON_UNDERLAY, 8, 0)

	// Apply the miscreant HUD, but scale up the preview icon a bit beforehand.
	// Otherwise, the M gets cut off.
	final_icon.Scale(64, 64)

	var/icon/miscreant_icon = icon('modular_oculis/modules/miscreants/icons/miscreants_hud.dmi', "miscreant")
	miscreant_icon.Scale(48, 48)
	miscreant_icon.Crop(1, 1, 64, 64)
	miscreant_icon.Shift(EAST, 10)
	miscreant_icon.Shift(NORTH, 16)
	final_icon.Blend(miscreant_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/miscreant/proc/make_assistant_icon(hairstyle)
	var/mob/living/carbon/human/dummy/consistent/assistant = new
	assistant.set_hairstyle(hairstyle, update = TRUE)

	var/icon/assistant_icon = render_preview_outfit(/datum/outfit/job/assistant/consistent, assistant)
	assistant_icon.ChangeOpacity(0.5)

	qdel(assistant)

	return assistant_icon

/datum/antagonist/miscreants/proc/finalize_miscreant()
	play_stinger()
	team.update_name()

/datum/team/miscreants
	name = "\improper Squad of Miscreants"
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

/// Adds a new miscreant to the squad
/datum/team/miscreants/proc/add_miscreant(mob/living/new_miscreant, source)
#ifndef TESTING
	if (isnull(new_miscreant) || isnull(new_miscreant.mind) || !GET_CLIENT(new_miscreant) || new_miscreant.mind.has_antag_datum(/datum/antagonist/miscreant))
		return FALSE
#else
	if (isnull(new_miscreant) || new_miscreant.mind.has_antag_datum(/datum/antagonist/miscreant))
		return FALSE
#endif

	set_max_miscreants(max_miscreants - 1)
	for (var/datum/mind/miscreant_mind as anything in members)
		if (miscreant_mind == new_miscreant.mind)
			continue

		to_chat(miscreant_mind, span_notice("[span_bold("[new_miscreant.real_name]")] has joined the miscreant band!"))
		if (max_miscreants == 0)
			to_chat(miscreant_mind, span_notice("You cannot recruit any more miscreants."))

	new_miscreant.mind.add_antag_datum(/datum/antagonist/miscreant, src)

	return TRUE

/// Control how many more people we can recruit
/datum/team/miscreants/proc/set_miscreants_left(remaining_miscreants)
	if (max_miscreants == remaining_miscreants)
		return

	if (max_miscreants == 0 && remaining_miscreants > 0)
		for (var/datum/mind/miscreant_mind as anything in members)
			var/datum/antagonist/miscreant/miscreant_datum = miscreant_mind.has_antag_datum(/datum/antagonist/miscreant)
			miscreant_datum?.grant_conversion_skills()

	else if (max_miscreants > 0 && remaining_miscreants <= 0)
		for (var/datum/mind/miscreant_mind as anything in members)
			var/datum/antagonist/miscreant/miscreant_datum = miscreant_mind.has_antag_datum(/datum/antagonist/miscreant)
			miscreant_datum?.remove_conversion_skills()
	max_miscreants = remaining_micreants


#undef MISCREANT_OBJECTIVES_FILE

