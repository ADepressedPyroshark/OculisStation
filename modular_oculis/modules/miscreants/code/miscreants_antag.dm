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
	/// Ref used to easily retrieve the action used when removing the quirk from silicons
	var/datum/weakref/shaker_ref

	VAR_PRIVATE
		datum/team/miscreants/team

/datum/antagonist/miscreants/get_team()
	return team

/datum/antagonist/miscreants/create_team(datum/team/miscreants/new_team)
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
