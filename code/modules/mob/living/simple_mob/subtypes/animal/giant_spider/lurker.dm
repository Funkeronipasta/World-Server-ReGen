// Lurkers are somewhat similar to Hunters, however the big difference is that Lurkers have an imperfect cloak.
// Their AI will try to do hit and run tactics, striking the enemy when its "cloaked", for bonus damage and a stun.
// They keep attacking until the stun ends, then retreat to cloak again and repeat the cycle.
// Hitting the spider before it does its ambush attack will break the cloak and make the spider flee.

/mob/living/simple_mob/animal/giant_spider/lurker
	desc = "Translucent and white, it makes you shudder to look at it. This one has incandescent red eyes."
	icon_state = "lurker"
	icon_living = "lurker"
	icon_dead = "lurker_dead"

	maxHealth = 100
	health = 100

	poison_per_bite = 5

	movement_cooldown = 5

	melee_damage_lower = 10
	melee_damage_upper = 10
	poison_chance = 30
	poison_type = "cryptobiolin"
	poison_per_bite = 1

	player_msg = "You have an imperfect, but automatic stealth. If you attack something while 'hidden', then \
	you will do bonus damage, stun the target, and unstealth for a period of time.<br>\
	Getting attacked will also break your stealth."

	ai_holder_type = /datum/ai_holder/simple_mob/melee/hit_and_run

	var/cloaked = FALSE
	var/cloaked_alpha = 45			// Lower = Harder to see.
	var/cloaked_bonus_damage = 30	// This is added on top of the normal melee damage.
	var/cloaked_weaken_amount = 3	// How long to stun for.
	var/cloak_cooldown = 10 SECONDS	// Amount of time needed to re-cloak after losing it.
	var/last_uncloak = 0			// world.time


/mob/living/simple_mob/animal/giant_spider/lurker/proc/cloak()
	if(cloaked)
		return
	animate(src, alpha = cloaked_alpha, time = 1 SECOND)
	cloaked = TRUE


/mob/living/simple_mob/animal/giant_spider/lurker/proc/uncloak()
	last_uncloak = world.time // This is assigned even if it isn't cloaked already, to 'reset' the timer if the spider is continously getting attacked.
	if(!cloaked)
		return
	animate(src, alpha = initial(alpha), time = 1 SECOND)
	cloaked = FALSE


// Check if cloaking if possible.
/mob/living/simple_mob/animal/giant_spider/lurker/proc/can_cloak()
	if(stat)
		return FALSE
	if(last_uncloak + cloak_cooldown > world.time)
		return FALSE

	return TRUE


// Called by things that break cloaks, like Technomancer wards.
/mob/living/simple_mob/animal/giant_spider/lurker/break_cloak()
	uncloak()


/mob/living/simple_mob/animal/giant_spider/lurker/is_cloaked()
	return cloaked


// Cloaks the spider automatically, if possible.
/mob/living/simple_mob/animal/giant_spider/lurker/handle_special()
	if(!cloaked && can_cloak())
		cloak()


// Applies bonus base damage if cloaked.
/mob/living/simple_mob/animal/giant_spider/lurker/apply_bonus_melee_damage(atom/A, damage_amount)
	if(cloaked)
		return damage_amount + cloaked_bonus_damage
	return ..()

// Applies stun, then uncloaks.
/mob/living/simple_mob/animal/giant_spider/lurker/apply_melee_effects(atom/A)
	if(cloaked)
		if(isliving(A))
			var/mob/living/L = A
			L.Weaken(cloaked_weaken_amount)
			to_chat(L, span("danger", "\The [src] ambushes you!"))
			playsound(L, 'sound/weapons/spiderlunge.ogg', 75, 1)
	uncloak()
	..() // For the poison.

// Force uncloaking if attacked.
/mob/living/simple_mob/animal/giant_spider/lurker/bullet_act(obj/item/projectile/P)
	. = ..()
	break_cloak()

/mob/living/simple_mob/animal/giant_spider/lurker/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	. = ..()
	break_cloak()