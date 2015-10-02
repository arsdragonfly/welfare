--5/1/2014 arsdragonfly
--Modified datastorage mod by minetest-technic
local welfare={}
welfare["data"]={}
welfare["data"]["registered_players"]={}
welfare["data"]["welfare_items"] = {}


welfare.save_data = function()
	local data = minetest.serialize( welfare["data"] )
	local path = minetest.get_worldpath().."/welfare.data"
	local file = io.open( path, "w" )
	if( file ) then
		file:write( data )
		file:close()
		return true
	else return nil
	end
end

welfare.load_data = function()
	local path = minetest.get_worldpath().."/welfare.data"
	local file = io.open( path, "r" )
	if( file ) then
		local data = file:read("*all")
		welfare["data"] = minetest.deserialize( data )
		file:close()
		return true
	else return nil
	end
end

welfare.get_container = function (player)
	local player_name = player:get_player_name()
	local container = welfare["data"]["registered_players"][player_name]
	if container == nil then
		welfare["data"]["registered_players"][player_name] = {}
		container = welfare["data"]["registered_players"][player_name]
		welfare.save_data()
	end
	return container
end

--Initialize

if ( welfare.load_data() == nil ) then
	welfare.save_data()
	welfare.load_data()
end

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	local registered = nil
	for __,tab in ipairs(welfare["data"]["registered_players"]) do
		if tab["player_name"] == player_name then registered = true break end
	end
	if registered == nil then
		print("creating new one")
		local new={}
		new["player_name"]=player_name
		table.insert(welfare["data"]["registered_players"],new)
		welfare.save_data()
	end
	local container = welfare.get_container(player)
	for __,itemstring in pairs(welfare["data"]["welfare_items"]) do
		if container[itemstring] == nil then
			player:get_inventory():add_item('main', itemstring)
			container[itemstring] = true
		end
	end

	-- TEST AREA:	
	--local test_container = welfare.get_container("dupa",player) test_container["var1"] = 1.23
	--test_container["table1"] = {}
	--test_container["table1"]["var2"] = "nowa"
	--test_container["table1"]["var3"] = "a string"

	--print("Testing:")
	--print(dump(test_container))
	-- END OF TEST AREA

end
)

minetest.register_on_leaveplayer(function(player)
	welfare.save_data()
end
)

minetest.register_on_shutdown(function()
	welfare.save_data() 
end
)
