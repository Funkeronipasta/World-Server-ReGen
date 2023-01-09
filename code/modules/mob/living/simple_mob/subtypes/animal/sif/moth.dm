//Very similar to frostflies, but with a non-lethal gas and less damaging, but less easy to protect from, projectiles.

/mob/living/simple_mob/animal/sif/tymisian
	name = "Tymisian Moth"
	desc = "A huge, fuzzy insect with a disorienting dust."
	tt_desc = "B Lepidoptera cinereus"

	faction = "spiders" //Hostile to most mobs, not all.

	icon_state = "moth"
	icon_living = "moth"
	icon_dead = "moth_dead"
	icon_rest = "moth_dead"
	icon = 'icons/mob/animal.dmi'

	maxHealth = 80
	health = 80

	hovering = TRUE

	movement_cooldown = 0.5

	melee_damage_lower = 5
	melee_damage_upper = 10
	base_attack_cooldown = 1.5 SECONDS
	attacktext = list("nipped", "bit", "pinched")

	special_attack_cooldown = 10 SECONDS
	special_attack_min_range = 0
	special_attack_max_range = 6

	var/energy = 100
	var/max_energy = 100

	var/datum/effect/effect/system/smoke_spread/mothspore/smoke_spore

	say_list_type = /datum/say_list/tymisian
	ai_holder_type = /datum/ai_holder/simple_mob/ranged/kiting/threatening/frostfly //Uses frostfly AI, since so similar mechanically

/datum/say_list/tymisian
	speak = list("Zzzz.", "Rrr...", "Zzt?")
	emote_see = list("grooms itself","sprinkles dust from its wings", "rubs its mandibles")
	emote_hear = list("chitters", "clicks", "rattles")

	say_understood = list("Ssst.")
	say_cannot = list("Zzrt.")
	say_maybe_target = list("Rr?")
	say_got_target = list("Rrrrt!")
	say_threaten = list("Kszsz.","Kszzt...","Kzzi!")
	say_stand_down = list("Sss.","Zt.","! clicks.")
	say_escalate = list("Rszt!")

	threaten_sound = 'sound/effects/spray3.ogg'
	stand_down_sound = 'sound/effects/squelch1.ogg'


/obj/effect/effect/smoke/elemental/mothspore
	name = "spore cloud"
	desc = "A dust cloud filled with disorienting bacterial spores."
	color = "#80AB82"

/obj/effect/effect/smoke/elemental/mothspore/affect(mob/living/L) //Similar to a very weak flash, but depends on breathing instead of eye protection.
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.stat != DEAD)
			if(C.needs_to_breathe())
				var/spore_strength = 5
				if(ishuman(C))
					var/mob/living/carbon/human/H = C
					H.Confuse(spore_strength)
					H.eye_blurry = max(H.eye_blurry, spore_strength)
					H.adjustHalLoss(10 * (spore_strength / 5))

/datum/effect/effect/system/smoke_spread/mothspore
	smoke_type = /obj/effect/effect/smoke/elemental/mothspore

/mob/living/simple_mob/animal/sif/tymisian/do_special_attack(atom/A)
	. = TRUE
	switch(a_intent)
		if(I_DISARM)
			if(energy < 20)
				return FALSE

			energy -= 20

			if(smoke_spore)
				smoke_spore.set_up(7,0,src)
				smoke_spore.start()
				return TRUE

			return FALSE

/mob/living/simple_mob/animal/sif/tymisian/initialize()
	..()
	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide

/mob/living/simple_mob/animal/sif/tymisian/handle_special()
	..()

	if(energy < max_energy)
		energy++

/mob/living/simple_mob/animal/sif/tymisian/Stat()
	..()
	if(client.statpanel == "Status")
		statpanel("Status")
		if(emergency_shuttle)
			var/eta_status = emergency_shuttle.get_status_panel_eta()
			if(eta_status)
				stat(null, eta_status)
		stat("Energy", energy)

/mob/living/simple_mob/animal/sif/tymisian/should_special_attack(atom/A)
	if(energy >= 20)
		return TRUE
	return FALSE
