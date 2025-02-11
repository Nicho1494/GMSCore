/*
	GMSCore_fnc_unitKilled 

	Purpose: called when the MPKilled eventhander fires for the unit   

	Parameters: per https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#MPKilled 

	Returns: none 

	Copyright 2020 by Ghostrider-GRG-
*/

#include "\GMSCore\Init\GMSCore_defines.hpp"
if !(local (_this select 0)) exitWith {};
params["_unit","_killer","_instigator"];
//[format["GMSCore_fnc_unitKilled: _unit = %1 | _killer = %2 | _instigator %3",_unit,_killer,_instigator]] call GMSCore_fnc_log;
//[format["GMSCore_fnc_unitKilled: count (group _unit) getVariable[GMS_aiKilledCode,[]] = %1",count ((group _unit) getVariable[GMS_aiKilledCode,[]])]] call GMSCore_fnc_log;
{_this call _x} forEach ((group _unit) getVariable[GMS_aiKilledCode,[]]);  // Run any external code to be executed upon AI Death.
private _cleanupTimer = (group _unit) getVariable[GMS_bodyCleanupTime,600];
[_unit,diag_tickTime + _cleanupTimer] call GMSCore_fnc_addToDeletionCue;
[_unit] call GMSCore_fnc_removeAllEventHandlers;
[_unit] call GMSCore_fnc_removeAllMPEventHandlers;
_unit disableAI "ALL";
private _group = group _unit;
//private _removeLauncher = _group getVariable[GMS_removeLauncher,true];
if (_group getVariable[GMS_removeLauncher,true]) then 
{
	_unit call GMSCore_fnc_removeLauncher;
};
//private _removeNVG = _group getVariable[GMS_removeNVG,true];
if (_group getVariable[GMS_removeNVG,true]) then 
{
	_unit call GMSCore_fnc_removeNVG;
};
private _veh = [_group] call GMSCore_fnc_getGroupVehicle;
//[format["GMSCore_fnc_unitKilled: (vehicle _unit = %1 | _veh classname %2 | {alive _x} count (crew (vehicle _unit)) = %3",_veh,typeOf _veh,{alive _x} count (crew _veh)]] call GMSCore_fnc_log;
if !(isNull _veh) then 
{
	if (local _unit) then 
	{
		if !([typeOf (vehicle _unit)] call GMSCore_fnc_isDrone) then 
		{
			_unit action ["Eject",vehicle _unit];  // can probably remoteexec this from the server 
		};
	};
	private _alive = {alive _x} count (crew _veh);
	//[format["GMSCore_fnc_unitKilled: vehicle crew = %1 || alive vehicle crew = %2",crew _veh, _alive]] call GMSCore_fnc_log;
	if (_alive == 0) then 
	{
		private _accessAllowed = _veh getVariable [GMS_allowAccess,true];
		//[format["GMSCore_fnc_unitKilled: _veh = %1 | _accessAllowed = %2",_veh,_accessAllowed]] call GMSCore_fnc_log;
		if (_accessAllowed) then 
		{
			_veh enableRopeAttach true;
			_veh enableCoPilot true;
			private _setFuelTo = _veh getVariable[GMS_removeFuel,0.2];
			_veh setFuel _setFuelTo;
			private _disable = _veh getVariable[GMS_disableVehicle,0.5];
			if ( (damage _veh) < _damage) then {_veh setDamage _damage};  
			_veh lock 0;
			if (GMSCore_modType isEqualTo "Exile") then (_veh setVariable ["ExileIsPersistent", false]);
			private _deleteEmptyVeh = _veh getVariable["GMS_deleteEmptyVehicle",300];
			GMSCore_monitoredEmptyVehicles pushBack [_veh, diag_tickTime + _deleteEmptyVeh];			
		};
	};
};

if (units (group _unit) isEqualTo []) then 
{
	deleteGroup (group _unit);
} else {
	if ([group _unit] call GMSCore_fnc_updateGroupHitKilledTimer) then // This only allows updates every 15 sec to reduce server load.
	{
		#define searchDistance (group _unit) getVariable [GMS_patrolAlertDistance,500] // Tied to the alertDistance for the group
		#define bumpKnowsAbout (group _unit) getVariable [GMS_patrolIntelligence,0.5] // Tied to intelligence fot the group
		[group _source, serachDistance, bumpKnowsAbout] call GMSCore_fnc_allertNearbyGroups;
		[group _unit, _killer] call GMSCore_fnc_huntPlayerGroup;
	};
};
[_unit] joinSilent GMSCore_graveyardGroup;
