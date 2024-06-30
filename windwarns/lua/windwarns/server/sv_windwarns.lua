include('windwarns/sh_windwarnscfg.lua')

util.AddNetworkString('windwarns.addwarn')
util.AddNetworkString('windwarns.removewarn')
util.AddNetworkString('windwarns.getplayerdata')
util.AddNetworkString('windwarns.purgewarns')

if windwarns.logging then
    if file.Exists('windwarns_logs.txt', 'DATA') then
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' Logging file found, no need to create a new one.\n')
    else 
        file.Write('windwarns_logs.txt', '')
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), " Didn't find the logging file, creating a new one...\n")
    end
end

function windwarns.log(logstring)
    if windwarns.logging then
        local timestring = os.date( "%H:%M:%S - %d/%m/%Y: " , os.time() )
        file.Append('windwarns_logs.txt', logstring .. '\n')
    else 
        return
    end
end


hook.Add('PlayerInitialSpawn', 'windwarns.plrinitialize', function(plr)
    local IsWindwarnsUser = tobool(plr:GetPData('windwarns.isuser', false))

    if not IsWindwarnsUser then
        local UserWarns = util.TableToJSON({})
        plr:SetPData('windwarns.warns', UserWarns)
        plr:SetPData('windwarns.isuser', true)
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' Player ' .. plr:Nick() .. ' registered in the warn system.\n')
        windwarns.log(' Player ' .. plr:Nick() .. ' registered in the warn system.\n')
    else 
        local WarnsTable = plr:GetPData('windwarns.warns')
        local UserWarns = util.JSONToTable(WarnsTable)
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' Player ' .. plr:Nick() .. ' initialized in the warn system, he has ' .. table.Count(UserWarns) .. ' warns.\n')
        windwarns.log(' Player ' .. plr:Nick() .. ' initialized in the warn system, he had ' .. table.Count(UserWarns) .. ' warns at the time.')
    end
end)

function windwarns.banplayer(plr)
    if windwarns.admsys == 'sam' then
        return RunConsoleCommand('sam', 'banid', plr:SteamID(), windwarns.bantime, windwarns.banreason)
    elseif windwarns.admsys == 'ulx' then
        return RunConsoleCommand('ulx', 'banid', plr:SteamID(), windwarns.bantime, windwarns.banreason)
    elseif windwarns.admsys == 'serverguard' then
        return RunConsoleCommand('ulx', 'banid', plr:SteamID(), windwarns.bantime, windwarns.banreason)
    elseif windwarns.admsys == 'default' then
        return RunConsoleCommand('fadmin', 'ban', plr:SteamID(), '720', windwarns.banreason)
    end
end

function windwarns.punishplayer(plr)
    local WarnsTable = plr:GetPData('windwarns.warns')
    local UserWarns = util.JSONToTable(WarnsTable)
    local WarnsCount = table.Count(UserWarns)

    if WarnsCount >= windwarns.fatalwarnscount and windwarns.punishment == 'demotion' then
        plr:SetUserGroup('user')
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' Player ' .. plr:Nick() .. ' reached the fatal amount of warns and was punished with a demotion.\n')
        windwarns.log(' Player ' .. plr:Nick() .. ' reached the fatal amount of warns and was punished with a demotion.')
    elseif WarnsCount >= windwarns.fatalwarnscount and windwarns.punishment == 'ban' then
        windwarns.banplayer(plr)
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' Player ' .. plr:Nick() .. ' reached the fatal amount of warns and was punished with a ban.\n')
        windwarns.log(' Player ' .. plr:Nick() .. ' reached the fatal amount of warns and was punished with a ban.')
    end
end

net.Receive('windwarns.addwarn', function(len,plr)
    if not windwarns.accessgroups[plr:GetUserGroup()] then
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Sent a request to warn system without having a proper access. He may have been trying to exploit nets.\n')
        windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Sent a request to warn system without having a proper access. He may have been trying to exploit nets.')
        return
    end

    local trgt = net.ReadEntity()
    local warn_reason = net.ReadString()
    local trgt_warnstablejson = trgt:GetPData('windwarns.warns', nil)
    local trgt_warnstable = util.JSONToTable(trgt_warnstablejson)

    local new_warn = {
        reason = warn_reason,
    }
    table.insert(trgt_warnstable, new_warn)

    local trgt_warnscount = table.Count(trgt_warnstable)
    local new_warnstable = util.TableToJSON(trgt_warnstable)

    if not windwarns.superiourgroups[plr:GetUserGroup()] and trgt == plr then
        plr:SendLua("chat.AddText(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' You can not target yourself!')")
        windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Tried to warn himself without having a proper access!')
        return
    end

    trgt:SetPData('windwarns.warns', new_warnstable)

    if trgt_warnscount >= windwarns.fatalwarnscount then
        windwarns.punishplayer(trgt)
    end

    windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Warned ' .. trgt:Nick() .. '(' .. trgt:SteamID() .. ') With a reason: ' .. warn_reason)
    trgt:SendLua("chat.AddText(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' You have been warned!')")
end)

net.Receive('windwarns.removewarn', function(len,plr)
    if not windwarns.accessgroups[plr:GetUserGroup()] then
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Sent a request to warn system without having a proper access. He may have been trying to exploit nets.\n')
        windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Sent a request to warn system without having a proper access. He may have been trying to exploit nets.\n')
        return
    end

    local trgt = net.ReadEntity()
    local warn_number = tonumber(net.ReadString())
    local trgt_warnstablejson = trgt:GetPData('windwarns.warns', nil)
    local trgt_warnstable = util.JSONToTable(trgt_warnstablejson)

    table.remove(trgt_warnstable, warn_number)

    local new_warnstable = util.TableToJSON(trgt_warnstable)

    if not windwarns.superiourgroups[plr:GetUserGroup()] and trgt == plr then
        plr:SendLua("chat.AddText(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' You can not target yourself!')")
        windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Tried to remove his warn without having a proper access!')
        return
    end

    trgt:SetPData('windwarns.warns', new_warnstable)

    windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Removed ' .. trgt:Nick() .. '(' .. trgt:SteamID() .. ') warn.')
    trgt:SendLua("chat.AddText(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' Someone removed one of your warns!')")
end)

net.Receive('windwarns.purgewarns', function(len,plr)
    if not windwarns.accessgroups[plr:GetUserGroup()] then
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Sent a request to warn system without having a proper access. He may have been trying to exploit nets.\n')
        windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Sent a request to warn system without having a proper access. He may have been trying to exploit nets.\n')
        return
    end

    local trgt = net.ReadEntity()
    local newwarns = util.TableToJSON({})

    if not windwarns.superiourgroups[plr:GetUserGroup()] and trgt == plr then
        plr:SendLua("chat.AddText(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' You can not target yourself!')")
        windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Tried to purge his warns without having a proper access!')
        return
    end

    trgt:SetPData('windwarns.warns', newwarns)

    windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Purged ' .. trgt:Nick() .. '(' .. trgt:SteamID() .. ') warns.')
    trgt:SendLua("chat.AddText(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' Someone purged your warns!')")
end)

net.Receive('windwarns.getplayerdata', function(len, plr)
    if not windwarns.accessgroups[plr:GetUserGroup()] then
        MsgC(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Sent a request to the warn system without having a proper access. He may have been trying to exploit nets.\n')
        windwarns.log(' User ' .. plr:Nick() .. '(' .. plr:SteamID() .. ') Sent a request to warn system without having a proper access. He may have been trying to exploit nets.\n')
        return
    end

    local trgt = net.ReadEntity()
    local LocalMenu = net.ReadBool()
    if LocalMenu then
        trgt_warns_json = plr:GetPData('windwarns.warns', nil)
        trgt_warns = util.JSONToTable(trgt_warns_json)
    else 
        trgt_warns_json = trgt:GetPData('windwarns.warns', nil)
        trgt_warns = util.JSONToTable(trgt_warns_json)
    end

    net.Start('windwarns.getplayerdata')
    net.WriteTable(trgt_warns)
    net.Send(plr)
end)
