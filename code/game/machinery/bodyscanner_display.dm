/obj/machinery/body_scan_display
	name = "Body Scan Display"
	desc = "A wall-mounted display linked to a body scanner."
	icon = 'icons/obj/modular_telescreen.dmi'
	icon_state = "operating"
	var/icon_state_unpowered = "telescreen"
	anchored = TRUE
	density = 0
	var/base_idle_power_usage = 75
	var/base_active_power_usage = 300
	w_class = ITEM_SIZE_HUGE
	var/list/bodyscans = list()
	var/selected = 0
	var/list/connected_consoles = list()


/obj/machinery/body_scan_display/proc/add_new_scan(var/list/scan)
	bodyscans += list(scan.Copy())
	updateUsrDialog()

/obj/machinery/body_scan_display/OnTopic(mob/user as mob, href_list)
	if(..())
		return 1
	if(href_list["view"])
		var/selection = text2num(href_list["view"])
		var/sanitized = sanitize_integer(selection, 1, bodyscans.len)
		if(sanitized)
			selected = sanitized
			return TOPIC_REFRESH
		return TOPIC_HANDLED
	if(href_list["delete"])
		var/index = text2num(href_list["delete"])
		if(selected  == index)
			selected = 0
		bodyscans -= list(bodyscans[index])		
		return TOPIC_REFRESH

/obj/machinery/body_scan_display/attack_ai(user as mob)
	return attack_hand(user)

/obj/machinery/body_scan_display/attack_hand(mob/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/body_scan_display/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=1)
	var/list/data = list()
	data["scans"] = bodyscans
	data["selected"] = selected

	if(selected > 0)
		data["scan_header"] = display_medical_data_header(bodyscans[selected], user.get_skill_value(SKILL_MEDICAL))
		data["scan_health"] = display_medical_data_health(bodyscans[selected], user.get_skill_value(SKILL_MEDICAL))
		data["scan_body"] = display_medical_data_body(bodyscans[selected], user.get_skill_value(SKILL_MEDICAL))
	else
		data["scan_header"] = "&nbsp;"
		data["scan_health"] = "&nbsp;"
		data["scan_body"] = "&nbsp;"
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "body_scan_display.tmpl", "Body Scan Display Console", 600, 800)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/body_scan_display/proc/add_console(var/obj/machinery/body_scanconsole/console)
	connected_consoles += console

/obj/machinery/body_scan_display/proc/remove_console(var/obj/machinery/body_scanconsole/console)
	connected_consoles -= console

/obj/machinery/body_scan_display/Destroy()
	. = ..()
	for(var/obj/machinery/body_scanconsole/console in connected_consoles)
		console.remove_display(src)