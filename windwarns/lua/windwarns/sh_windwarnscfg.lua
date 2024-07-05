--[[ 
Free WindWarns system by voltage: https://github.com/voltageeee
Credits to: https://github.com/darkfated/mantle for providing a very useful gui library.
For support, please contact me on discord: voltageee
Thanks for using my addon! Hope you like it.
--]]

---------------------------------------------------------------------------
------------------------CONFIGURATION FILE---------------------------------
---------------------------------------------------------------------------

windwarns.admsys = 'sam' // Your admin system. May be 'sam', 'ulx', 'badmin', 'serverguard' or 'default' for fadmin. (Don't forge the '' symbols)
windwarns.fatalwarnscount = 3 // How much warns should player receive before getting punished?
windwarns.punishment = 'demotion' // What kind of punishment does player receive when getting the fatal amount of warns? 'demotion' for... demotion, 'ban' will ban the player for the specified amount of time.
windwarns.bantime = '1d' // How long will the player get banned for, if 'punishment' is set to 'ban'?
windwarns.banreason = 'You reached the fatal amount of warns!' // Reason used for banning if 'punishment' is set to 'ban'
windwarns.chatcmd = '!windwarns' // Set your admin chat command here.
windwarns.profilecmd = '!windwarnsprofile' // Set your profile chat command here.
windwarns.prefix = '[WindWarns]' // Prefix used in chat
windwarns.prefixcolor = Color(0, 255, 0) // Prefix color
windwarns.logging = true // Turn on the logginh? Logs are saved in data/windwarns_logs.txt

windwarns.accessgroups = { // Add the groups whom have access to the warn menu here. Note: Last one doesn't have a comma!
    ['superadmin'] = true,
    ['founder'] = true,
    ['root'] = true
}

windwarns.superiourgroups = { // Add the groups who can remove their own warns here
    ['superadmin'] = true,
    ['founder'] = true,
    ['root'] = true
}
