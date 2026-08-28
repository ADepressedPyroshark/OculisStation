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

//Adds miscreant to team
/datum/antagonist/miscreant/proc/add_miscreant(datum/mind/miscreant_mind)
	if(!can_be_converted(miscreant_mind.current))
		return FALSE

	miscreant_mind.add_memory(/datum/memory/recruited_by_head_miscreant, protagonist = miscreant_mind.current, antagonist = owner.current)
	miscreant_mind.add_antag_datum(/datum/antagonist/miscreant,miscreant_team)
	return TRUE

/datum/antagonist/miscreant/leader
	name = "\improper Miscreant Leader"
	pref_flag = ROLE_MISCREANT_LEADER
	antag_hud_name = "miscreant_leader"


/datum/team/miscreant
	name = "\improper Band of Miscreants"
	var/max_miscreants = 4 //maximum number of miscreants that can be assigned to this team
	var/flavor_text = "If you see this miscreant flavor text, report it as a bug."
	var/ooc_text = "If you see this miscreant ooc text, report it as a bug."


/datum/team/miscreant/New(starting_members)
	. = ..()

	return TRUE

/datum/team/miscreant/proc/objective_ui()
	return

/// Control how many more people we can recruit
/datum/team/miscreant/proc/set_miscreants_left(remaining_miscreants)
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

