/*
	GMSCore_fnc_spawnPatrolAircraft

	Purpose: spawn and initialize an aircraft or UAV to be used for AI patrols 
			This is a special case because additional stuff needs to be done to be sure 
			the aircraft is flying and has a pilot right off the bat. 
			Note that there is a small movement of 300 meters specified at spawnin. 

	Parameters: 

	Returns:
		_aircraft, the vehicle configured 

	Copyright 2020 by Ghostrider-GRG-

	Notes: TODO: 
*/
#include "\GMSCore\Init\GMSCore_defines.hpp"
params[
	["_className",""],
	["_group",grpNull],		
	["_pos",[0,0,0]],
	["_dir",0],
	["_height",0],	
	["_disable",0],  // damage value set to this value if less than this value when all crew are dead
	["_removeFuel",0.2],  // uel set to this value when all crew dead
	["_releaseToPlayers",true],
	["_deleteTimer",300],
	["_vehHitCode",[]],
	["_vehKilledCode",[]]
];

if !(isClass(configFile >> "CfgVehicles" >> _className)) exitWith
{
	[format["GMSCore_fnc_spawnPatrolAircraft called with invalid classname %1",_className],"error"] call GMSCore_fnc_log;
	objNull
};
if !(_className isKindOf "Air") exitWith 
{
	[format["GMSCore_fnc_spawnPatrolAircraft: class name %1 is not kindOf 'Air'",_className],"error"] call GMSCore_fnc_log;
	objNull
};

private _spawnPos = [_pos select 0, _pos select 1, 600];
private _aircraft = createVehicle[_className,_spawnPos,[],0,"FLY"];
if !(isNull _aircraft) then 
{
	[_aircraft,_disable,_removeFuel,_releaseToPlayers,_deleteTimer] call GMSCore_fnc_initializePatrolVehicle;
	_group setVariable[GMS_flyinHeight,_height];
	_group addVehicle _aircraft;
	if (_aircraft isKindOf "Plane") then {
		_group setVariable[GMS_flyinVariation,40];
		_group setVariable[GMS_flyinHeight,100];

	};
	if (_aircraft isKindOf "Helicopter") then {
		_group setVariable[GMS_flyinVariation,25];
		_group setVariable[GMS_flyinHeight,50];	
		[_group,_aircraft] call GMSCore_fnc_setGroupVehicle;		
	};
	{
		_x moveInAny _aircraft;
	} forEach (units _group);
	//[format["GMSCore_fnc_spawnPatrolAircraft: _vehHitCode = %1",_vehHitCode]] call GMSCore_fnc_log;
	_aircraft setVariable[GMS_vehHitCode,_vehHitCode];
	_aircraft setVariable[GMS_vehKilledCode,_vehKilledCode];
	_aircraft setVariable["GMS_group",_group];
	_aircraft enableDynamicSimulation false;
	_aircraft enableSimulationGlobal true;
	(currentPilot _aircraft)  doMove (_pos getPos[1000,random(359)]); 
	_aircraft enableCoPilot true;
};
_aircraft