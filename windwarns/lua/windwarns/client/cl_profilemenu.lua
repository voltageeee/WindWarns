AddCSLuaFile('windwarns/sh_windwarnscfg.lua')

local scrw, scrh = ScrW(), ScrH()

local playermenu_buttons = {
    button1 = { 
        title = "Add warn",
        func = function(plr)
            Mantle.ui.text_box('Reason', 'Please, specify a reason for warning.', function(s)
                net.Start('windwarns.addwarn')
                net.WriteEntity(plr)
                net.WriteString(s)
                net.SendToServer()
                frame:Remove()
                windwarns.playermenu(plr)
            end)
        end,
    },

    button2 = { 
        title = "Remove warn",
        func = function(plr)
            Mantle.ui.text_box('Reason', 'Please, specify a warn number.', function(s)
                net.Start('windwarns.removewarn')
                net.WriteEntity(plr)
                net.WriteString(s)
                net.SendToServer()
                frame:Remove()
                windwarns.playermenu(plr)
            end)
        end,
    },

    button3 = { 
        title = "Purge warns",
        func = function(plr)
            net.Start('windwarns.purgewarns')
            net.WriteEntity(plr)
            net.SendToServer()
            frame:Remove()
            windwarns.playermenu(plr)
        end,
    },
}

hook.Add('OnPlayerChat', 'windwarns.chatcmd', function(plr, str)
    str = string.lower(str)

    if str == windwarns.chatcmd then
        windwarns.menu()
        return true
    elseif str == windwarns.profilecmd then
        windwarns.playermenu(LocalPlayer(), true)
        return true
    end
end)

function windwarns.menu()
    if windwarns.accessgroups[LocalPlayer():GetUserGroup()] then
        Mantle.ui.player_selector(function(plr)
            windwarns.playermenu(plr)
        end)
    else 
        chat.AddText(Color(0, 255, 0), windwarns.prefix, Color(255, 255, 255), ' No access!')
        return
    end
end

function windwarns.playermenu(plr, localmenu)

    if not windwarns.accessgroups[LocalPlayer():GetUserGroup()] and not localmenu then
        chat.AddText(windwarns.prefixcolor, windwarns.prefix, Color(255, 255, 255), ' No access!')
        return
    end

    net.Start('windwarns.getplayerdata')
    net.WriteEntity(plr)
    if localmenu then
        net.WriteBool(true)
    end
    net.SendToServer()

    net.Receive('windwarns.getplayerdata', function(len)
        warns_table = net.ReadTable()
        warns_amount = table.Count(warns_table)
    end)

    timer.Simple(0.1, function() // Waiting till we will get updated information with net.Receive up there. Removing this timer will result in an error after first time opening the warn menu.
        frame = vgui.Create('DFrame')
        Mantle.ui.frame(frame, plr:Nick() .. ' profile', scrw*0.2, scrh*0.4 + warns_amount*25, true)
        frame:Center()
        frame:MakePopup()

        local frameavatar = vgui.Create('AvatarImage', frame)
        frameavatar:SetSize(124, 124)
        frameavatar:SetPos(scrw*0.07, scrh*0.05)
        frameavatar:SetPlayer(plr, 124)

        warns_label = vgui.Create('DLabel', frame)
        warns_label:SetPos(scrw*0.056, scrh*0.17)
        warns_label:SetText('Amount of warns: ' .. warns_amount)
        warns_label:SetFont('Fated.24')
        warns_label:SizeToContents()
        warns_label:SetTextColor(Color(255, 255, 255))

        for k, warn in pairs(warns_table) do
            if warns_amount >= 1 then
                local warn_lenght = string.len(warn.reason)
                warn_label = vgui.Create('DLabel', frame)
                warn_label:SetPos(scrw*0.069 - warn_lenght*5, scrh*0.17 + k*30)
                warn_label:SetText('Warn ' .. k .. ' reason: ' ..  warn.reason)
                warn_label:SetFont('Fated.24')
                warn_label:SizeToContents()
                warn_label:SetTextColor(Color(255, 255, 255))
            end
        end

        if not localmenu then
            for k, v in pairs(playermenu_buttons) do
                local button = vgui.Create('DButton', frame)
                Mantle.ui.btn(button)
                button:Dock(BOTTOM)
                button:DockMargin(0, 0, 0, 4)
                button:SetText(v.title)
                button.DoClick = function()
                    v.func(plr)
                end
            end
        end
    end)
end

concommand.Add('ebanatstvo', function(plr)
    windwarns.playermenu(plr, false)
end)