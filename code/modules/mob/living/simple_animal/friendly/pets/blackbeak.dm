/mob/living/simple_animal/blackbeak
	name = "\improper blackbeak"
	real_name = "blackbeak"
	desc = "A tiny penguin, that was adopted as the pet of the Blackshield's guardhouse by the Sergeant Evans."
	icon = 'icons/mob/blackbeak.dmi'
	icon_state = "blackbeak"
	item_state = "blackbeak"
	icon_living = "blackbeak"
	icon_dead = "blackbeak_dead"
	icon_rest = "blackbeak_dead"
	can_nap = TRUE
	speak = list("Peep!","PEEP!","Peep?")
	speak_emote = list("peeps","peeps","pips")
	emote_hear = list("peeps","peaps","pips")
	emote_see = list("runs in a circle", "shakes", "gakks at something")
	eat_sounds = list('sound/effects/creatures/nibble1.ogg','sound/effects/creatures/nibble2.ogg')
	pass_flags = PASSTABLE
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 20
	health = 20
	melee_damage_upper = 0
	melee_damage_lower = 0
	attacktext = "pecked"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps on"
	density = 0
	layer = MOB_LAYER
	mob_size = MOB_MINISCULE
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = FALSE
	universal_understand = TRUE
	holder_type = /obj/item/weapon/holder/blackbeak
	digest_factor = 0.05
	min_scan_interval = 2
	max_scan_interval = 20
	seek_speed = 1
	speed = 1
	can_pull_size = ITEM_SIZE_TINY
	can_pull_mobs = MOB_PULL_NONE

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	meat_amount = 1

	var/soft_squeaks = list('sound/effects/creatures/mouse_squeaks_1.ogg',
	'sound/effects/creatures/mouse_squeaks_2.ogg',
	'sound/effects/creatures/mouse_squeaks_3.ogg',
	'sound/effects/creatures/mouse_squeaks_4.ogg')
	var/last_softsqueak = null//Used to prevent the same soft squeak twice in a row
	var/squeals = 5//Spam control.
	var/maxSqueals = 5//SPAM PROTECTION
	var/last_squealgain = 0// #TODO-FUTURE: Remove from life() once something else is created
	var/squeakcooldown = 0


/mob/living/simple_animal/blackbeak/New()
	..()
	nutrition = max_nutrition

/mob/living/simple_animal/blackbeak/Life()
	if(..())

		if(client)
			walk_to(src,0)

			//Player-animals don't do random speech normally, so this is here
			//Player-controlled mice will still squeak, but less often than NPC mice
			if (stat == CONSCIOUS && prob(speak_chance*0.05))
				squeak_soft(0)

			if (squeals < maxSqueals)
				var/diff = world.time - last_squealgain
				if (diff > 600)
					squeals++
					last_squealgain = world.time


//Pixel offsetting as they scamper around
/mob/living/simple_animal/blackbeak/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	if((. = ..()))
		if (prob(50))
			var/new_pixelx = pixel_x
			new_pixelx += rand(-2,2)
			new_pixelx = CLAMP(new_pixelx, -10, 10)
			animate(src, pixel_x = new_pixelx, time = 1)
		else
			var/new_pixely = pixel_y
			new_pixely += rand(-2,2)
			new_pixely = CLAMP(new_pixely, -4, 14)
			animate(src, pixel_y = new_pixely, time = 1)

/mob/living/simple_animal/blackbeak/Initialize()
	. = ..()
	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide

/mob/living/simple_animal/blackbeak/speak_audio()
	squeak_soft(0)

/mob/living/simple_animal/blackbeak/attack_hand(mob/living/carbon/human/M as mob)
	if (src.stat == DEAD)//If the mouse is dead, we don't pet it, we just pickup the corpse on click
		get_scooped(M, usr)
		return
	else
		..()

//Plays a random selection of four sounds, at a low volume
//This is triggered randomly periodically by any mouse, or manually
/mob/living/simple_animal/blackbeak/proc/squeak_soft(var/manual = 1)
	if (stat != DEAD) //Soft squeaks are allowed while sleeping
		var/list/new_squeaks = last_softsqueak ? soft_squeaks - last_softsqueak : soft_squeaks
		var/sound = pick(new_squeaks)

		last_softsqueak = sound
		playsound(src, sound, 5, 1, -4.6)

		if (manual)
			log_say("[key_name(src)] peeps softly! ")


/mob/living/simple_animal/blackbeak/Crossed(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>\icon[src] peeps!</span>")
			poke(1) //Wake up if stepped on
			if (prob(95))
				squeak_soft(0)

	if(!health)
		return


	..()

/mob/living/simple_animal/blackbeak/death()
	layer = MOB_LAYER
	..()

//Mice can bite mobs, deals 1 damage, and stuns the mouse for a second
/mob/living/simple_animal/mouse/AltClickOn(A)
	if (!can_click()) //This has to be here because anything but normal leftclicks doesn't use a click cooldown. It would be easy to fix, but there may be unintended consequences
		return
	melee_damage_upper = melee_damage_lower //We set the damage to 1 so we can hurt things
	attack_sound = pick(list('sound/effects/creatures/nibble1.ogg', 'sound/effects/creatures/nibble2.ogg'))
	UnarmedAttack(A, Adjacent(A))
	melee_damage_upper = 0 //Set it back to zero so we're not biting with every normal click
	setClickCooldown(DEFAULT_ATTACK_COOLDOWN*2) //Unarmed attack already applies a cooldown, but it's not long enough


/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/cannot_use_vents()
	return
