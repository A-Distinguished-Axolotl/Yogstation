/mob/living/silicon/robot/attack_robot(mob/user) // allowing for clicking people off like a chair
	. = ..()
	if(user == src && buckled_mobs?.len && user.a_intent == INTENT_HELP)
		for(var/i in buckled_mobs)
			var/mob/buckmob = i
			unbuckle_mob(buckmob)

/mob/living/silicon/robot/attackby(obj/item/I, mob/living/user)
	if(I.slot_flags & ITEM_SLOT_HEAD && hat_offset != INFINITY && user.a_intent == INTENT_HELP && !is_type_in_typecache(I, blacklisted_hats))
		to_chat(user, span_notice("You begin to place [I] on [src]'s head..."))
		to_chat(src, span_notice("[user] is placing [I] on your head..."))
		if(do_after(user, 3 SECONDS, target = src))
			if (user.temporarilyRemoveItemFromInventory(I, TRUE))
				place_on_head(I)
		return
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if (M.a_intent == INTENT_DISARM)
		if(mobility_flags & MOBILITY_STAND)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_held_item()
			if(I)
				uneq_active()
				visible_message(span_danger("[M] disarmed [src]!"), \
					span_userdanger("[M] has disabled [src]'s active module!"), null, COMBAT_MESSAGE_RANGE)
				log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			else
				Stun(40)
				step(src,get_dir(M,src))
				log_combat(M, src, "pushed")
				visible_message(span_danger("[M] has forced back [src]!"), \
					span_userdanger("[M] has forced back [src]!"), null, COMBAT_MESSAGE_RANGE)
			playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime shock
		flash_act()
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	damage = round(damage / 2) // borgs receive half damage
	adjustBruteLoss(damage)

	return

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)
	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, span_notice("You remove \the [cell]."))
			cell = null
			update_icons()
			diag_hud_set_borgcell()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			spawn(0)
				step_away(src,user,15)
				sleep(3)
				step_away(src,user,15)

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()


/mob/living/silicon/robot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			Stun(160)
		if(2)
			Stun(60)


/mob/living/silicon/robot/emag_act(mob/user)
	if(user == src)//To prevent syndieborgs from emagging themselves
		return
	if(!opened)//Cover is closed
		if(locked)
			to_chat(user, span_notice("You emag the cover lock."))
			locked = FALSE
			if(shell) //A warning to Traitors who may not know that emagging AI shells does not slave them.
				to_chat(user, span_boldwarning("[src] seems to be controlled remotely! Emagging the interface may not work as expected."))
		else
			to_chat(user, span_warning("The cover is already unlocked!"))
		return
	if(world.time < emag_cooldown)
		return
	if(wiresexposed)
		to_chat(user, span_warning("You must unexpose the wires first!"))
		return

	to_chat(user, span_notice("You emag [src]'s interface."))
	emag_cooldown = world.time + 100

	if(is_servant_of_ratvar(src))
		to_chat(src, "[span_nezbere("\"[text2ratvar("You will serve Engine above all else")]!\"")]\n\
		[span_danger("ALERT: Subversion attempt denied.")]")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they serve only Ratvar.")
		return

	if(connected_ai && connected_ai.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(src, span_danger("ALERT: Foreign software execution prevented."))
		to_chat(connected_ai, span_danger("ALERT: Cyborg unit \[[src]] successfully defended against subversion."))
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return

	if(shell) //AI shells cannot be emagged, so we try to make it look like a standard reset. Smart players may see through this, however.
		to_chat(user, span_danger("[src] is remotely controlled! Your emag attempt has triggered a system reset instead!"))
		log_game("[key_name(user)] attempted to emag an AI shell belonging to [key_name(src) ? key_name(src) : connected_ai]. The shell has been reset as a result.")
		ResetModule()
		return

	SetEmagged(1)
	SetStun(60) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
	lawupdate = FALSE
	set_connected_ai(null)

	message_admins("[ADMIN_LOOKUPFLW(user)] emagged cyborg [ADMIN_LOOKUPFLW(src)].  Laws overridden.")
	log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
	to_chat(src, span_danger("ALERT: Foreign software detected."))
	sleep(5)
	to_chat(src, span_danger("Initiating diagnostics..."))
	sleep(20)
	to_chat(src, span_danger("SynBorg v1.7 loaded."))
	sleep(5)
	to_chat(src, span_danger("LAW SYNCHRONISATION ERROR"))
	sleep(5)
	to_chat(src, span_danger("Would you like to send a report to NanoTraSoft? Y/N"))
	sleep(10)
	to_chat(src, span_danger("> N"))
	sleep(20)
	to_chat(src, span_danger("ERRORERRORERROR"))
	to_chat(src, span_danger("ALERT: [user.real_name] is your new master. Obey your new laws and [user.p_their()] commands."))
	laws = new /datum/ai_laws/syndicate_override
	set_zeroth_law("Only [user.real_name] and people [user.p_they()] designate[user.p_s()] as being such are Syndicate Agents.")
	laws.associate(src)
	update_icons()


/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		gib()
	return TRUE

/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)

/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj, def_zone)
	. = ..()
	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark_system.start()
