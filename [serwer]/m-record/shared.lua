controlTable = { "fire", "aim_weapon", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "zoom_in", "zoom_out",
"change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "conversation_yes", "conversation_no",
"group_control_forwards", "group_control_back", "enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
"steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn", "sub_mission",
"handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
"special_control_down", "special_control_up" }

function table.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

function getPedWeapons(ped)
	local playerWeapons = {}
	if ped and isElement(ped) and getElementType(ped) == "ped" or getElementType(ped) == "player" then
		for i=2,9 do
			local wep = getPedWeapon(ped,i)
			if wep and wep ~= 0 then
				table.insert(playerWeapons,{wep,getPedTotalAmmo(ped,i)})
			end
		end
	else
		return false
	end
	return playerWeapons
end

function getPedControlStates(ped)
    local states = {}
    for _, control in ipairs(controlTable) do
        if getControlState(control) then
            table.insert(states, control)
        end
    end
    return states
end

function Vector3Comparator(v1, v2)
    if not v1 or not v2 then return false end
    return ('%.1f'):format(v1[1]) == ('%.1f'):format(v2[1]) and ('%.1f'):format(v1[2]) == ('%.1f'):format(v2[2]) and ('%.1f'):format(v1[3]) == ('%.1f'):format(v2[3])
end

function Vector3Distance(v1, v2)
    if not v1 or not v2 then return false end
    return math.sqrt((v1[1] - v2[1]) ^ 2 + (v1[2] - v2[2]) ^ 2 + (v1[3] - v2[3]) ^ 2)
end

function iter(s, e, func)
    local t = {}
    for i = s, e do
        table.insert(t, func(i))
    end
    return t
end

function map(array, func)
    local new_array = {}
    for i, v in ipairs(array) do
        new_array[i] = func(v)
    end
    return new_array
end