//Miscreant Handshake alert!
/atom/movable/screen/alert/give/secret_handshake
	icon_state = "default"

/atom/movable/screen/alert/give/secret_handshake/setup(mob/living/carbon/taker, mob/living/carbon/offerer, obj/item/receiving)
	name = "[offerer] is offering a Handshake"
	desc = "[offerer] wants to teach you the Secret Handshake for their Miscreant squad and induct you! Click on this alert to accept."
	icon_state = "template"
	cut_overlays()
	add_overlay(receiving)
	src.receiving = receiving
	src.offerer = offerer
	RegisterSignal(taker, COMSIG_MOVABLE_MOVED, .proc/check_in_range, override = TRUE) //Override to prevent runtimes when people offer a item multiple times
