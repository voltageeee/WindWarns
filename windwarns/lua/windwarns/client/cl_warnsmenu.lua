AddCSLuaFile('windwarns/sh_windwarnscfg.lua')

local config_pop_actions = {
    {
        'Choose a player',
        function()
            Mantle.ui.player_selector(function(pl)
                player_selected_func(pl)
                player_selected = true
                warned_player = pl
            end)
        end
    },
    {
        'Add a reason',
        function()
            Mantle.ui.text_box('Reason', 'Please, specify a reason for warning.', function(s)
                reason_func(s)
                reason_entered = true
                warnin_reason = s
            end)
        end
    }
}

function windwarns.openmenu()
    local frame = vgui.Create('DFrame')
    Mantle.ui.frame(frame, 'Warning Menu', ScrW()*0.32, ScrH()*0.2, true)
    frame:Center()
    frame:MakePopup()
    frame.OnRemove = function()
        player_selected = false 
        reason_entered = false
        warned_player = nil 
        warnin_reason = nil
    end
    
    
    for i, action in ipairs(config_pop_actions) do
        local btn_action = vgui.Create('DButton', frame)
        Mantle.ui.btn(btn_action)
        btn_action:Dock(TOP)
        btn_action:DockMargin(0, 0, 0, 4)
        btn_action:SetText(action[1])
        btn_action.DoClick = function()
            action[2]()
        end
    end

    function player_selected_func(pl)
        local player_nickname = vgui.Create('DLabel', frame)
        player_nickname:SetFont('Fated.24')
        player_nickname:SetText('Player: ' .. pl:Nick())
        player_nickname:SetContentAlignment(5)
        player_nickname:SizeToContents()
        player_nickname:SetTextColor(Color(255,255,255))
        player_nickname:SetPos(ScrW()*0.098, ScrH()*0.1)
    end

    function reason_func(reason)
        local reason_text = vgui.Create('DLabel', frame)
        reason_text:SetFont('Fated.24')
        reason_text:SetText('Reason: ' .. reason)
        reason_text:SetContentAlignment(5)
        reason_text:SizeToContents()
        reason_text:SetTextColor(Color(255,255,255))
        reason_text:SetPos(ScrW()*0.122, ScrH()*0.12)
    end

    btn_addwarning = vgui.Create('DButton', frame)
    Mantle.ui.btn(btn_addwarning)
    btn_addwarning:SetPos(ScrW()*0.113, ScrH()*0.15)
    btn_addwarning:SetSize(ScrW()*0.1, ScrH()*0.03)
    btn_addwarning:SetText('Warn a player')
    btn_addwarning.DoClick = function()
        if player_selected and reason_entered then
            chat.AddText(Color(0, 255, 0), '[WindWarns] ', Color(255, 255, 255), 'Seems good!')
        else 
            chat.AddText(Color(0, 255, 0), '[WindWarns] ', Color(255, 255, 255), 'Something is missing...')
        end
    end
end

concommand.Add('test_windwarns_ui', windwarns.openmenu)