params [ "_unit" ];

// Filters disabled 
if (GRLIB_filter_arsenal == 0) exitWith {};
private _removed = if (isNil "F_blockedItems") then { [] } else { [_unit] call F_blockedItems };

if !([handgunWeapon _unit] call is_allowed_item) then {_unit removeWeapon (handgunWeapon _unit)};
if !([primaryWeapon _unit] call is_allowed_item) then {_unit removeWeapon (primaryWeapon _unit)};
if !([secondaryWeapon _unit] call is_allowed_item) then {_unit removeWeapon (secondaryWeapon _unit)};
if !([uniform _unit] call is_allowed_item) then {removeUniform _unit};
if !([vest _unit] call is_allowed_item) then {removeVest _unit};
if !([headgear _unit] call is_allowed_item) then {removeHeadgear _unit};
if !([backpack _unit] call is_allowed_item) then {removeBackpack _unit};
if !([binocular _unit] call is_allowed_item) then {_unit removeWeapon (binocular _unit)};
if !([hmd _unit] call is_allowed_item) then {_unit unlinkItem (hmd _unit)};
{ if !([_x] call is_allowed_item) then {_unit unlinkItem _x} } forEach assignedItems _unit;
{ if !([_x] call is_allowed_item) then {_unit removePrimaryWeaponItem _x} } forEach primaryWeaponItems _unit;
{ if !([_x] call is_allowed_item) then {_unit removeItem _x} } forEach ((vestItems _unit)+(uniformItems _unit)+(backpackItems _unit)+(items _unit));

[_unit] call F_correctLaserBatteries;
[_unit] call F_correctHEGL;
[_unit] call F_correctUAVT;

if (count _removed > 0 && {_unit == player}) then {
    ["Arsenal", format ["Removed (not allowed by the arsenal filter): %1", _removed joinString ", "], "warn", 10] call HPC_fnc_toast;
};
// Only point out the undercover role for a kit that was civilian by choice, not one the filter stripped.
if (GRLIB_player_spawned && {GRLIB_Undercover_mode == 1} && {count _removed == 0}) then {
    if ([_unit] call F_checkCivUnit && side _unit != GRLIB_side_civilian && uniform _unit != "") then {
        [format ["%1 loadout is compatible with the Civilian undercover role.", name _unit]] call HPC_fnc_info;
    };
};
