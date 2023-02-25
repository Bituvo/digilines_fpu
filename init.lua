loca max_expression_length = tonumber(minetest.settings:get("digilines_fpu_max_expression_length")) or 128

function error_function(err)
    minetest.log("warning", err)
end

function evaluate(expression)
    if #expression < max_expression_length then
        if expression:match("^[-.\\+*^\\/()%d ]+$") then
            local result = loadstring("return " .. expression)

            if result then
                successful, returned, _ = xpcall(result, error_function)

                if successful then
                    result = tostring(returned)
                    if result:sub(-2) == ".0" then
                        result = result:sub(1, -3)
                    end

                    return tonumber(result)
                end
            end
        end
    end
end

minetest.register_node("digilines_fpu:fpu", {
    description = "Digilines FPU",
    groups = {cracky=3},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec","field[channel;Channel;${channel}")
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local name = sender:get_player_name()
        if minetest.is_protected(pos,name) and not minetest.check_player_privs(name,{protection_bypass=true}) then
            minetest.record_protection_violation(pos,name)
            return
        end
        local meta = minetest.get_meta(pos)
        if fields.channel then meta:set_string("channel",fields.channel) end
    end,

    tiles = {
        "digilines_fpu_top.png",
        "jeija_microcontroller_bottom.png",
        "jeija_microcontroller_sides.png",
        "jeija_microcontroller_sides.png",
        "jeija_microcontroller_sides.png",
        "jeija_microcontroller_sides.png"
    },
    inventory_image = "digilines_fpu_top.png",
    drawtype = "nodebox",
    selection_box = {
        type = "fixed",
        fixed = {-8/16, -8/16, -8/16, 8/16, -5/16, 8/16},
    },
    node_box = {
        type = "fixed",
        fixed = {
            {-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
            {-5/16, -7/16, -5/16, 5/16, -6/16, 5/16},
            {-3/16, -6/16, -3/16, 3/16, -5/16, 3/16},
        }
    },
    paramtype = "light",
    sunlight_propagates = true,
    digiline = {
        receptor = {},
        effector = {
            action = function(pos, node, channel, msg)
                local meta = minetest.get_meta(pos)
                if meta:get_string("channel") ~= channel then return end
                if type(msg) ~= "string" then return end

                result = evaluate(msg)
                if result then
                    digiline:receptor_send(pos, digiline.rules.default, channel, result)
                end
            end
        }
    }
})

minetest.register_craft({
    output = "digilines_fpu:fpu",
    recipe = {
        {"digilines:wire_std_00000000", "mesecons_gates:diode_off", "mesecons:wire_00000000_off"},
        {"", "mesecons_luacontroller:luacontroller0000", "mesecons:wire_00000000_off"}
    }
})
