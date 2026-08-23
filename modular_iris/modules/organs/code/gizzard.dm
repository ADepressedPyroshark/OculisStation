/obj/item/organ/wings/gizzard
	name = "Natural wings"
	desc = "This should help you fly"
	icon_state = "eggsac"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_GIZZARD
	w_class = WEIGHT_CLASS_BULKY
	organ_flags = ORGAN_ORGANIC | ORGAN_EDIBLE | ORGAN_VIRGIN
	use_mob_sprite_as_obj_sprite = FALSE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings/functional/gizzard
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)

/obj/item/organ/wings/gizzard/handle_flight(mob/living/carbon/human/human)
	. = ..()
	if(HAS_TRAIT_FROM(human, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
		human.adjust_stamina_loss(8)

/obj/item/organ/wings/gizzard/grind_results()
	return null
