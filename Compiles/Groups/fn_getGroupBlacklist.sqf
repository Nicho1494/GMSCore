/*
	GMSCore_fnc_getGroupBlacklist 

	Purpose: Set the list of blacklisted areas 

	Parameters:
		_group 

	Returns: _list 

	Copyright 2020 by Ghostrider-GRG-	
*/
#include "\GMSCore\Init\GMSCore_defines.hpp"
params[["_group",grpNull]];
if (isNull _group) exitWith 
{
	["GMSCore_fnc_getGroupBlacklist called with null group"] call GMSCore_fnc_log;
	[]
};
_group setVariable["GMS_blacklist",[]];
