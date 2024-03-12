local animations = {
    { dictionary = "creatures@rottweiler@amb@sleep_in_kennel@", animation = "sleep_in_kennel", name = "Lie Down" },
    { dictionary = "creatures@rottweiler@amb@world_dog_barking@idle_a", animation = "idle_a", name = "Bark" },
    { dictionary = "creatures@rottweiler@amb@world_dog_sitting@base", animation = "base", name = "Sit Down" },
    { dictionary = "creatures@rottweiler@amb@world_dog_sitting@idle_a", animation = "idle_a", name = "Scratch" },
    { dictionary = "creatures@rottweiler@indication@", animation = "indicate_high", name = "Attract Attention" },
    { dictionary = "creatures@rottweiler@melee@", animation = "dog_takedown_from_back", name = "Attack" },
    { dictionary = "creatures@rottweiler@melee@streamed_taunts@", animation = "taunt_02", name = "Taunt" },
    { dictionary = "creatures@rottweiler@swim@", animation = "swim", name = "Swim" },
    { dictionary = "creatures@rottweiler@amb@", animation = "hump_loop_chop", name = "Mating = Male" },
    { dictionary = "creatures@rottweiler@amb@", animation = "hump_loop_ladydog", name = "Mating = Female" },
}

local dogModels = {
    "a_c_shepherd", "a_c_rottweiler", "a_c_husky", "a_c_poodle", "a_c_pug", "a_c_westy", "a_c_retriever"
}

local emotePlaying = false

function isDog()
    local playerModel = GetEntityModel(PlayerPedId())
    for _, model in ipairs(dogModels) do
        if GetHashKey(model) == playerModel then
            return true
        end
    end
    return false
end

function cancelEmote()
    ClearPedTasksImmediately(PlayerPedId())
    emotePlaying = false
end

function playAnimation(dictionary, animation)
    if emotePlaying then
        cancelEmote()
    end
    RequestAnimDict(dictionary)
    while not HasAnimDictLoaded(dictionary) do
        Citizen.Wait(1)
    end
    TaskPlayAnim(PlayerPedId(), dictionary, animation, 8.0, 0.0, -1, 1, 0, false, false, false)
    emotePlaying = true
end

lib.registerMenu({
    id = 'dogmenu',
    title = 'K-9 Interactions',
    options = (function()
        local opts = {}
        for i, anim in ipairs(animations) do
            table.insert(opts, {
                label = anim.name,
                close = false,
                args = {anim.dictionary, anim.animation},
                onSelected = function(args)
                    playAnimation(args[1], args[2])
                end,
            })
        end
        return opts
    end)(),
    position = 'top-right',
    onClose = function()
    end
}, function(selected, scrollIndex, args)
    playAnimation(args[1], args[2])
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 244) and isDog() then
            lib.showMenu('dogmenu')
        elseif emotePlaying and (IsControlPressed(0, 32) or IsControlPressed(0, 33) or IsControlPressed(0, 34) or IsControlPressed(0, 35)) then
            cancelEmote()
        end
    end
end)
