/obj/item/clothing/mask/smokable/ecig
	name = "electronic cigarette"
	desc = "Device with modern approach to smoking."
	icon = 'icons/obj/ecig.dmi'
	var/active = 0
	//var/obj/item/weapon/cell/ec_cell = /obj/item/weapon/cell/device
	var/cartridge_type = /obj/item/weapon/reagent_containers/ecig_cartridge/med_nicotine
	var/obj/item/weapon/reagent_containers/ecig_cartridge/ec_cartridge
	w_class = ITEMSIZE_TINY
	slot_flags = SLOT_EARS | SLOT_MASK
	attack_verb = list("attacked", "poked", "battered")
	body_parts_covered = 0
	var/brightness_on = 1
	chem_volume = 0 //ecig has no storage on its own but has reagent container created by parent obj
	item_state = "ecigoff"
	var/icon_off
	var/icon_empty
	var/ecig_colors = list(null, COLOR_DARK_GRAY, COLOR_RED_GRAY, COLOR_BLUE_GRAY, COLOR_GREEN_GRAY, COLOR_PURPLE_GRAY)
	matter = list("copper" = 300, DEFAULT_WALL_MATERIAL = 630)

/obj/item/clothing/mask/smokable/ecig/New()
	..()
	ec_cartridge = new cartridge_type(src)

/obj/item/clothing/mask/smokable/ecig/simple
	name = "simple electronic cigarette"
	desc = "A cheap Lucky 1337 electronic cigarette, styled like a traditional cigarette."
	icon_state = "ccigoff"
	icon_off = "ccigoff"
	icon_empty = "ccigoff"
	icon_on = "ccigon"
	matter = list("copper" = 300, DEFAULT_WALL_MATERIAL = 430)
/obj/item/clothing/mask/smokable/ecig/util
	name = "electronic cigarette"
	desc = "A popular utilitarian model electronic cigarette, the ONI-55. Comes in a variety of colors."
	icon_state = "ecigoff1"
	icon_off = "ecigoff1"
	icon_empty = "ecigoff1"
	icon_on = "ecigon"
	matter = list("copper" = 300, DEFAULT_WALL_MATERIAL = 670)

/obj/item/clothing/mask/smokable/ecig/util/New()
	..()
	color = pick(ecig_colors)

/obj/item/clothing/mask/smokable/ecig/deluxe
	name = "deluxe electronic cigarette"
	desc = "A premium model eGavana MK3 electronic cigarette, shaped like a cigar."
	icon_state = "pcigoff1"
	icon_off = "pcigoff1"
	icon_empty = "pcigoff2"
	icon_on = "pcigon"
	matter = list("copper" = 500, DEFAULT_WALL_MATERIAL = 1230)

/obj/item/clothing/mask/smokable/ecig/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/C = loc
		if (src == C.wear_mask && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
			if (!active || !ec_cartridge || !ec_cartridge.reagents.total_volume)//no cartridge
				active=0//autodisable the cigarette
//				STOP_PROCESSING(SSobj, src)
				update_icon()
				return
			ec_cartridge.reagents.trans_to_mob(C, REM, CHEM_INGEST, 0.4) // Most of it is not inhaled... balance reasons.

/obj/item/clothing/mask/smokable/ecig/update_icon()
	if (active)
		item_state = icon_on
		icon_state = icon_on
		set_light(brightness_on)
	else if (ec_cartridge)
		set_light(0)
		item_state = icon_off
		icon_state = icon_off
	else
		icon_state = icon_empty
		item_state = icon_empty
		set_light(0)
	if(ismob(loc))
		var/mob/living/M = loc
		M.update_inv_wear_mask(0)
		M.update_inv_l_hand(0)
		M.update_inv_r_hand(1)


/obj/item/clothing/mask/smokable/ecig/attackby(var/obj/item/I, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/ecig_cartridge))
		if (ec_cartridge)//can't add second one
			to_chat(user, "<span class='notice'>A cartridge has already been installed.</span> ")
		else//fits in new one
			user.remove_from_mob(I)
			I.forceMove(src)//I.loc=src
			ec_cartridge = I
			update_icon()
			to_chat(user, "<span class='notice'>You insert [I] into [src].</span> ")

/obj/item/clothing/mask/smokable/ecig/attack_self(mob/user as mob)
	if (active)
		active=0
//		STOP_PROCESSING(SSobj, src)
		to_chat(user, "<span class='notice'>You turn off \the [src]. </span> ")
		update_icon()
	else
		if (!ec_cartridge)
			to_chat(user, "<span class='notice'>You can't use it with no cartridge installed!.</span> ")
			return
		active=1
//		START_PROCESSING(SSobj, src)
		to_chat(user, "<span class='notice'>You turn on \the [src]. </span> ")
		update_icon()

/obj/item/clothing/mask/smokable/ecig/attack_hand(mob/user as mob)//eject cartridge
	if(user.get_inactive_hand() == src)//if being hold
		if (ec_cartridge)
			active=0
			user.put_in_hands(ec_cartridge)
			to_chat(user, "<span class='notice'>You eject [ec_cartridge] from \the [src].</span> ")
			ec_cartridge = null
			update_icon()
	else
		..()

/obj/item/weapon/reagent_containers/ecig_cartridge
	name = "tobacco flavour cartridge"
	desc = "A small metal cartridge, used with electronic cigarettes, which contains an atomizing coil and a solution to be atomized."
	w_class = ITEMSIZE_TINY
	icon = 'icons/obj/ecig.dmi'
	icon_state = "ecartridge"
	matter = list("metal" = 50, "glass" = 10, "copper" = 5)
	volume = 20
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/ecig_cartridge/New()
	create_reagents(volume)

/obj/item/weapon/reagent_containers/ecig_cartridge/examine(mob/user as mob)//to see how much left
	..()
	to_chat(user, "The cartridge has [reagents.total_volume] units of liquid remaining.")

//flavours
/obj/item/weapon/reagent_containers/ecig_cartridge/blank
	name = "ecigarette cartridge"
	desc = "A small metal cartridge which contains an atomizing coil."

/obj/item/weapon/reagent_containers/ecig_cartridge/blanknico
	name = "flavorless nicotine cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says you can add whatever flavoring agents you want."
/obj/item/weapon/reagent_containers/ecig_cartridge/blanknico/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 10)

/obj/item/weapon/reagent_containers/ecig_cartridge/med_nicotine
	name = "tobacco flavour cartridge"
	desc =  "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its tobacco flavored."
/obj/item/weapon/reagent_containers/ecig_cartridge/med_nicotine/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 15)

/obj/item/weapon/reagent_containers/ecig_cartridge/high_nicotine
	name = "high nicotine tobacco flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its tobacco flavored, with extra nicotine."
/obj/item/weapon/reagent_containers/ecig_cartridge/high_nicotine/New()
	..()
	reagents.add_reagent("nicotine", 10)
	reagents.add_reagent("water", 10)

/obj/item/weapon/reagent_containers/ecig_cartridge/orange
	name = "orange flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its orange flavored."
/obj/item/weapon/reagent_containers/ecig_cartridge/orange/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("orangejuice", 5)

/obj/item/weapon/reagent_containers/ecig_cartridge/mint
	name = "mint flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its mint flavored."
/obj/item/weapon/reagent_containers/ecig_cartridge/mint/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("menthol", 5)

/obj/item/weapon/reagent_containers/ecig_cartridge/watermelon
	name = "watermelon flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its watermelon flavored."
/obj/item/weapon/reagent_containers/ecig_cartridge/watermelon/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("watermelonjuice", 5)

/obj/item/weapon/reagent_containers/ecig_cartridge/grape
	name = "grape flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its grape flavored."
/obj/item/weapon/reagent_containers/ecig_cartridge/grape/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("grapejuice", 5)

/obj/item/weapon/reagent_containers/ecig_cartridge/lemonlime
	name = "lemon-lime flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its lemon-lime flavored."
/obj/item/weapon/reagent_containers/ecig_cartridge/lemonlime/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("lemon lime", 5)

/obj/item/weapon/reagent_containers/ecig_cartridge/coffee
	name = "coffee flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its coffee flavored."
/obj/item/weapon/reagent_containers/ecig_cartridge/coffee/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("coffee", 5)

/obj/item/weapon/reagent_containers/ecig_cartridge/cannabis
	name = "herb flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label seems to be suspiciously scuffed off..."
/obj/item/weapon/reagent_containers/ecig_cartridge/cannabis/New()
	..()
	reagents.add_reagent("nicotine", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("cannabis", 5)