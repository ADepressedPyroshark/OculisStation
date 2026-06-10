//Yes I'm using Familes to do this, sue me.

/// Miscreant secret handshakes.
/obj/item/slapper/secret_handshake
	name = "Secret Handshake"
	icon_state = "recruit"
	icon = 'modular_oculis/modules/miscreants/icons/miscreant_actions.dmi'
	/// References the active miscreant gamemode handler (if one exists), for adding new miscreant members to.
	var/datum/miscreant_handler/handler


/// Adds the user to the family that this package corresponds to, dispenses the free_clothes of that family, and adds them to the handler if it exists.
/obj/item/slapper/secret_handshake/proc/add_to_squad(mob/living/user, original_name)
	var/datum/antagonist/gang/swappin_sides = new gang_to_use()
	swappin_sides.original_name = original_name
	swappin_sides.handler = handler
	user.mind.add_antag_datum(swappin_sides, team_to_use)
	var/policy = get_policy(ROLE_FAMILIES)
	if(policy)
		to_chat(user, policy)
	team_to_use.add_member(user.mind)
	swappin_sides.equip_gangster_in_inventory()
	if (!isnull(handler) && !handler.gangbangers.Find(user.mind)) // if we have a handler and they're not tracked by it
		handler.gangbangers += user.mind

/// Checks if the user is trying to use the package of the squad they are in, and if not, adds them to the squad, with some differing processing depending on whether the user is already a family member.
/obj/item/slapper/secret_handshake/proc/attempt_join_gang(mob/living/user)
	if(!user?.mind)
		return
	var/datum/antagonist/miscreant/is_miscreant = user.mind.has_antag_datum(/datum/antagonist/gang)
	var/real_name_backup = user.real_name
	if(is_miscreant)
		return
	add_to_squad(user, real_name_backup)

/obj/item/slapper/secret_handshake/on_offer_taken(mob/living/carbon/offerer, mob/living/carbon/taker)
	. = TRUE
	if (!(null in taker.held_items))
		to_chat(taker, span_warning("You can't get taught the secret handshake if [offerer] has no free hands!"))
		return

	if(HAS_TRAIT(taker, TRAIT_MINDSHIELD))
		to_chat(taker, "You attended a seminar on not signing up for a gang and are not interested.")
		return

	offerer.visible_message(span_notice("[taker] is taught the secret handshake by [offerer]!"), span_nicegreen("All right! You've taught the secret handshake to [taker]!"), span_hear("You hear a bunch of weird shuffling and flesh slapping sounds!"), ignored_mobs=taker)
	to_chat(taker, span_nicegreen("You get taught the secret handshake by [offerer]!"))
	var/datum/antagonist/gang/owner_gang_datum = offerer.mind.has_antag_datum(/datum/antagonist/gang)
	handler = owner_gang_datum.handler
	gang_to_use = owner_gang_datum.type
	team_to_use = owner_gang_datum.my_gang
	attempt_join_gang(taker)
	qdel(src)
