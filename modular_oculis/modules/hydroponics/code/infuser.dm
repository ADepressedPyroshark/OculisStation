
/obj/item/circuitboard/machine/infuser
	name = "Plant Chemical Infuser (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/splicer
	req_components = list(
		/datum/stock_part/servo = 1,
	)

/obj/item/seeds
	///infusion damage
	var/infusion_damage = 0

/obj/machinery/infuser
	name = "Plant Chemical Infuser"
	desc = "Infuses seeds with chemicals."
	icon = 'modular_oculis/modules/hydroponics/icons/infuser.dmi'
	base_icon_state = "splicer"
	icon_state = "splicer"
	circuit = /obj/item/circuitboard/machine/infuser
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.5
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5

	var/obj/item/seeds/seed
	var/obj/item/reagent_containers/cup/beaker/held_beaker

	var/working = FALSE

	var/work_timer = null

	var/potential_damage = 0



/obj/machinery/splicer/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/seeds))
		if(!seed)
			if(!user.transferItemToLoc(I, src))
				return
			seed = I

	else if(istype(I, /obj/item/reagent_containers/cup/beaker))
		if(!held_beaker)
			if(!user.transferItemToLoc(I, src))
				return
			held_beaker = I
			return

/obj/machinery/splicer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/splicer/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, base_icon_state, base_icon_state, tool)

/obj/machinery/splicer/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/splicer/update_icon_state()
	. = ..()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]_broken"
	else if((machine_stat & NOPOWER) || !anchored)
		icon_state = "[base_icon_state]_off"
	else if(working)
		icon_state = "[base_icon_state]_working"
	else
		icon_state = "[base_icon_state]"

/obj/machinery/splicer/update_overlays()
	. = ..()
	if(panel_open)
		. += "[base_icon_state]_open"

/obj/machinery/splicer/set_anchored(anchorvalue)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/machinery/splicer/on_set_panel_open(old_value)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/splicer/ui_data(mob/user)
	. = ..()

	var/has_seed = FALSE
	var/has_beaker = FALSE
	var/list/data = list()

	if(seed)
		data["seed"] = list(seed.return_all_data() + stats)
		has_seed = TRUE
		data["damage_taken"] = seed.infusion_damage
		data["potential_damage"] = potential_damage
		data["combined_damage"] = (potential_damage + seed.infusion_damage)
	if(held_beaker)
		data["held_beaker"] = held_beaker.reagents
		has_beaker = TRUE


	data["seed"] = has_seed
	data["held_beaker"] = has_beaker

	data["working"] = working

	data["timeleft"] = work_timer ? timeleft(work_timer) : null

	return data

/obj/machinery/splicer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotanySplicer", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/splicer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject_seed")
			eject_seed(seed)
			seed = null
			return TRUE
		if("eject_beaker")
			eject_beaker(held_beaker)
			return TRUE
		if("infuse")
			infuse()
			return TRUE

/obj/machinery/splicer/proc/eject_seed(obj/item/seeds/ejected_seed)
	if (ejected_seed)
		if(Adjacent(usr) && !HAS_SILICON_ACCESS(usr))
			if (!usr.put_in_hands(ejected_seed))
				ejected_seed.forceMove(drop_location())
		else
			ejected_seed.forceMove(drop_location())
		. = TRUE

/obj/machinery/splicer/proc/eject_beaker()
	if (held_beaker)
		if(Adjacent(usr) && !HAS_SILICON_ACCESS(usr))
			if (!usr.put_in_hands(held_beaker))
				held_beaker.forceMove(drop_location())
		else
			held_beaker.forceMove(drop_location())
		held_beaker = null
		potential_damage = 0
		. = TRUE



/obj/machinery/splicer/proc/calculate_stats_for_infusion()
	if(!held_beaker)
		return
	for(var/reagent in held_beaker.reagents.reagent_list)
		var/datum/reagent/listed_reagent = reagent
		total_stats += listed_reagent.generate_infusion_values(held_beaker.reagents)
	stats = total_stats
	potential_damage = stats["damage"]

/obj/machinery/splicer/proc/infuse()
	if(!held_beaker || !seed) /// Checks if we have a beaker and a seed to infuse
		return
	potential_damage = held_beaker.reagents.total_volume / 10 /// Every 10 units of reagents in the beaker will cause 1 damage to the seed.
	seed.infusion_damage += min(potential_damage, 100 - seed.infusion_damage)

	if(seed.infusion_damage >= 100) /// If the seed has taken too much damage, it gets deleted.
		to_chat(usr, span_warning("[seed] has become too damaged from infusion and disintegrated!"))
		qdel(seed)
		seed = null
		stats = list()
		potential_damage = 0
		return

	var/list/successful_reagents = list()


	if(held_beaker.reagents && held_beaker.reagents.reagent_list.len > 0)
		var/list/current_reagent_instances = held_beaker.reagents.reagent_list.Copy()

		for (var/datum/reagent/reagent_instance in current_reagent_instances)
			if(!reagent_instance)
				continue

			var/reagent_id_path = reagent_instance.type
			if (!(reagent_instance.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
				to_chat(usr, span_warning("[reagent_instance.name] cannot be infused into plants!"))
				continue

			var/volume = reagent_instance.volume
			if (volume <= 0)
				continue

			if(volume >= 100)
				var/random_rate = rand(3, 25) / 100

				var/datum/plant_gene/reagent/existing_gene = null
				for(var/datum/plant_gene/gene_check in seed.genes)
					if(istype(gene_check, /datum/plant_gene/reagent))
						var/datum/plant_gene/reagent/reagent_gene = gene_check
						if(reagent_gene.reagent_id == reagent_id_path)
							existing_gene = reagent_gene
							break

				if(existing_gene)
					/// Add to existing gene's rate
					to_chat(usr, span_notice("Increased [reagent_instance.name] rate in [seed] from [round(existing_gene.rate * 100)]% to [round(existing_gene.rate * 100) + round(random_rate * 100)]%."))
					existing_gene.rate += random_rate
				else
					/// Create a new gene with the random rate
					var/datum/plant_gene/reagent/new_gene = new /datum/plant_gene/reagent(reagent_id_path, random_rate)
					if(new_gene.can_add(seed))
						seed.genes += new_gene
						to_chat(usr, span_notice("Successfully infused [reagent_instance.name] into [seed] with a rate of [round(new_gene.rate * 100)]%."))
					else
						/// Skips adding the gene mutation if it failed to add
						to_chat(usr, span_warning("Could not add new gene for [reagent_instance.name] to [seed]."))
						qdel(new_gene)
						continue

				successful_reagents += reagent_instance
			else
				to_chat(usr, span_notice("Attempted to infuse [reagent_instance.name] into [seed], but it failed. Infusion requires a volume of 100 units."))


		seed.reagents_from_genes()
	else
		to_chat(usr, span_warning("The beaker is empty! Nothing to infuse."))

	seed.check_infusions(successful_reagents)
	if(held_beaker && held_beaker.reagents)
		held_beaker.reagents.remove_all(held_beaker.reagents.total_volume)
	successful_reagents = list()
	potential_damage = 0

	to_chat(usr, span_notice("[seed] infusion process complete."))
