/datum/station_trait/carp_infestation
	name = "Carp infestation"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Dangerous fauna is present in the area of this station."
	trait_to_give = STATION_TRAIT_CARP_INFESTATION

/datum/station_trait/distant_supply_lines
	name = "Distant supply lines"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Due to the distance to our normal supply lines, cargo orders are more expensive."
	blacklist = list(/datum/station_trait/strong_supply_lines)

/datum/station_trait/distant_supply_lines/on_round_start()
	SSeconomy.pack_price_modifier *= 1.2

/datum/station_trait/random_spawns
	name = "Drive-by landing"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Sorry for that, we missed your station by a few miles, so we just launched you towards your station in pods. Hope you don't mind!"
	trait_to_give = STATION_TRAIT_RANDOM_ARRIVALS

/datum/station_trait/empty_maint
	name = "Cleaned out maintenance"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Our workers cleaned out most of the junk in the maintenace areas."
	blacklist = list(/datum/station_trait/filled_maint)
	trait_to_give = STATION_TRAIT_EMPTY_MAINT


/datum/station_trait/overflow_job_bureacracy
	name = "Overflow bureacracy mistake"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	var/list/jobs_to_use = list("Clown", "Bartender", "Cook", "Botanist", "Cargo Technician", "Mime", "Janitor")
	var/chosen_job

/datum/station_trait/overflow_job_bureacracy/New()
	. = ..()
	chosen_job = pick(jobs_to_use)
	RegisterSignal(SSjob, COMSIG_SUBSYSTEM_POST_INITIALIZE, .proc/set_overflow_job_override)

/datum/station_trait/overflow_job_bureacracy/get_report()
	return "[name] - It seems for some reason we put out the wrong job-listing for the overflow role this shift...I hope you like [chosen_job]s."

/datum/station_trait/overflow_job_bureacracy/proc/set_overflow_job_override(datum/source, new_overflow_role)
	SSjob.set_overflow_role(chosen_job)

/datum/station_trait/slow_shuttle
	name = "Slow Shuttle"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to distance to our supply station, the cargo shuttle will have a slower flight time to your cargo department."
	blacklist = list(/datum/station_trait/quick_shuttle)

/datum/station_trait/slow_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 1.5

/datum/station_trait/bot_languages
	name = "Bot Language Matrix Malfunction"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Your station's friendly bots have had their language matrix fried due to an event, resulting in some strange and unfamiliar speech patterns."

/datum/station_trait/bot_languages/New()
	. = ..()
	/// What "caused" our robots to go haywire (fluff)
	var/event_source = pick(list("an ion storm", "a syndicate hacking attempt", "a malfunction", "issues with your onboard AI", "an intern's mistakes", "budget cuts"))
	report_message = "Your station's friendly bots have had their language matrix fried due to [event_source], resulting in some strange and unfamiliar speech patterns."

/datum/station_trait/bot_languages/on_round_start()
	. = ..()
	//All bots that exist round start have their set language randomized.
	for(var/mob/living/simple_animal/bot/found_bot in GLOB.alive_mob_list)
		/// The bot's language holder - so we can randomize and change their language
		var/datum/language_holder/bot_languages = found_bot.get_language_holder()
		bot_languages.selected_language = bot_languages.get_random_spoken_language()
