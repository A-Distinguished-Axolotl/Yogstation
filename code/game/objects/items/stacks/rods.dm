GLOBAL_LIST_INIT(rod_recipes, list ( \
	new/datum/stack_recipe("grille", /obj/structure/grille, 2, time = 10, one_per_turf = TRUE, on_floor = FALSE), \
	new/datum/stack_recipe("table frame", /obj/structure/table_frame, 2, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("scooter frame", /obj/item/scooter_frame, 10, time = 25, one_per_turf = 0), \
	new/datum/stack_recipe("linen bin", /obj/structure/bedsheetbin/empty, 2, time = 5, one_per_turf = 0), \
	new/datum/stack_recipe("railing", /obj/structure/railing, 3, time = 18, window_checks = TRUE), \
	// yogs start
	null, \
	new/datum/stack_recipe("fore port spacepod frame", /obj/item/pod_parts/pod_frame/fore_port, 15, time = 30, one_per_turf = 0), \
	new/datum/stack_recipe("fore starboard spacepod frame", /obj/item/pod_parts/pod_frame/fore_starboard, 15, time = 30, one_per_turf = 0), \
	new/datum/stack_recipe("aft port spacepod frame", /obj/item/pod_parts/pod_frame/aft_port, 15, time = 30, one_per_turf = 0), \
	new/datum/stack_recipe("aft starboard spacepod frame", /obj/item/pod_parts/pod_frame/aft_starboard, 15, time = 30, one_per_turf = 0), \
	// yogs end
	))

/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building or something."
	singular_name = "metal rod"
	icon_state = "rods"
	item_state = "rods"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_NORMAL
	force = 9
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=1000)
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	novariants = TRUE
	matter_amount = 2

/obj/item/stack/rods/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to stuff \the [src] down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide!"))//it looks like theyre ur mum
	return BRUTELOSS

/obj/item/stack/rods/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()

	recipes = GLOB.rod_recipes
	update_icon()

/obj/item/stack/rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER)
		if(get_amount() < 2)
			to_chat(user, span_warning("You need at least two rods to do this!"))
			return

		if(W.use_tool(src, user, 0, volume=40))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			user.visible_message("[user.name] shaped [src] into metal with [W].", \
						 span_notice("You shape [src] into metal with [W]."), \
						 span_italics("You hear welding."))
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_held_item()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(new_item)

	else if(istype(W, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = W
		if(amount != 1)
			to_chat(user, span_warning("You must use a single rod!"))
		else if(S.w_class > WEIGHT_CLASS_SMALL)
			to_chat(user, span_warning("The ingredient is too big for [src]!"))
		else
			var/obj/item/reagent_containers/food/snacks/customizable/A = new/obj/item/reagent_containers/food/snacks/customizable/kebab(get_turf(src))
			A.initialize_custom_food(src, S, user)
	else
		return ..()

/obj/item/stack/rods/cyborg
	materials = list()
	is_cyborg = 1
	cost = 250

/obj/item/stack/rods/cyborg/update_icon()
	return

/obj/item/stack/rods/ten
	amount = 10

/obj/item/stack/rods/twentyfive
	amount = 25

/obj/item/stack/rods/fifty
	amount = 50
