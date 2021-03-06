var/list/stored_shock_by_ref = list()

/mob/living/proc/apply_stored_shock_to(var/mob/living/target)
	if(stored_shock_by_ref["\ref[src]"])
		target.electrocute_act(stored_shock_by_ref["\ref[src]"]*0.9, src)
		stored_shock_by_ref["\ref[src]"] = 0

/datum/species/proc/has_fine_manipulation(var/mob/living/carbon/human/H)
	return has_fine_manipulation

/datum/species/proc/toggle_stance(var/mob/living/carbon/human/H)
	if(!H.incapacitated())
		H.pulling_punches = !H.pulling_punches
		to_chat(H, "<span class='notice'>You are now [H.pulling_punches ? "pulling your punches" : "not pulling your punches"].</span>")

/datum/species/proc/get_offset_overlay_image(var/spritesheet, var/mob_icon, var/mob_state, var/color, var/slot)

	// If we don't actually need to offset this, don't bother with any of the generation/caching.
	if(!spritesheet && equip_adjust.len && equip_adjust[slot] && LAZYLEN(equip_adjust[slot]))

		// Check the cache for previously made icons.
		var/image_key = "[mob_icon]-[mob_state]-[color]"
		if(!equip_overlays[image_key])

			var/icon/final_I = new(icon_template)
			var/list/shifts = equip_adjust[slot]

			// Apply all pixel shifts for each direction.
			for(var/shift_facing in shifts)
				var/list/facing_list = shifts[shift_facing]
				var/use_dir = text2num(shift_facing)
				var/icon/equip = new(mob_icon, icon_state = mob_state, dir = use_dir)
				var/icon/canvas = new(icon_template)
				canvas.Blend(equip, ICON_OVERLAY, facing_list["x"]+1, facing_list["y"]+1)
				final_I.Insert(canvas, dir = use_dir)
			equip_overlays[image_key] = overlay_image(final_I, color = color, flags = RESET_COLOR)
		return equip_overlays[image_key]
	return overlay_image(mob_icon, mob_state, color, RESET_COLOR)

/datum/species/proc/water_act(var/mob/living/carbon/human/H, var/depth)
	if(!isnull(water_soothe_amount) && depth >= 40)
		if(H.getHalLoss())
			H.adjustHalLoss(-(water_soothe_amount))
			if(prob(5))
				to_chat(H, "<span class='notice'>The water ripples gently over your skin in a soothing balm.</span>")

/datum/species/proc/is_available_for_join()
	if(!(spawn_flags & SPECIES_CAN_JOIN))
		return FALSE
	else if(!isnull(max_players))
		var/player_count = 0
		for(var/mob/living/carbon/human/H in GLOB.living_mob_list_)
			if(H.client && H.key && H.species == src)
				player_count++
				if(player_count >= max_players)
					return FALSE
	return TRUE

/datum/species/proc/check_background(var/datum/job/job, var/datum/preferences/prefs)
	. = TRUE
	if(istype(job) && istype(prefs) && job.required_education > EDUCATION_TIER_NONE)
		var/has_sufficient_education = FALSE
		for(var/culturetag in prefs.cultural_info)
			var/decl/cultural_info/culture = SSculture.get_culture(prefs.cultural_info[culturetag])
			if(culture.get_education_tier() >= job.required_education)
				has_sufficient_education = TRUE
				break
		. = has_sufficient_education