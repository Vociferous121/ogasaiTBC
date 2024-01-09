extra_functions = {}

function IsStealth() local localObj = GetLocalPlayer(); if (not localObj == nil) and (not localObj == 0) then if (HasBuff(localObj, "Stealth")) or (HasBuff(localObj, "Shadowmeld")) or (HasBuff(localObj, "Prowl")) then return true; end end return false; end

function IsShapeshift() local localObj = GetLocalPlayer(); if (not localObj == nil) and (not localObj == 0) then if (HasBuff(localObj, "Bear Form")) or (HasBuff(localObj, "Cat Form")) or (HasBuff(localObj, "Dire Bear Form")) or (HasBuff(localObj, "Ghost Wolf")) then return true; end end return false; end

function CastStealth() local localObj = GetLocalPlayer(); if (HasSpell("Stealth")) and (not localObj == nil) and (not localObj == 0)then if (not HasBuff(localObj, "Stealth")) and (not HasBuff(localObj, "Shadowmeld")) and (not IsSpellOnCD("Stealth")) then Cast("Stealth", localObj); return true; end end return false; end

function IsShadowmeld() local localObj = GetLocalPlayer(); if (not localObj == 0) and (not localObj == nil) then if (HasBuff(localObj, "Shadowmeld")) then return true; end end return false; end

function CastShadowmeld() local localObj = GetLocalPlayer(); if (not localObj == nil) and (not localObj == 0) then if (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not HasBuff(localObj, "Shadowmeld")) and (not IsShapeshift()) then return true; end end return false; end

function CastBearForm() local localObj = GetLocalPlayer(); if (not localObj == nil) and (not localObj == 0) then if (not IsShapeshift()) and (HasSpell("Cat Form")) and (not IsSpellOnCD("Cat Form")) then Cast("Cat Form", localObj); end end return false end

function CastCatForm() local localObj = GetLocalPlayer(); if (not localObj == nil) and (not localObj == 0) then if (not IsShapeshift()) and (HasSpell("Cat Form")) and (not IsSpellOnCD("Cat Form")) then CastSpellByName("Cat Form"); return true; end end return false; end

function PlayerHasTarget() local localObj = GetLocalPlayer(); if (not localObj == nil) and (not localObj == 0) then if (not GetUnitsTarget(localObj) == 0) and (not GetUnitsTarget(localObj) == nil) then return true; end end return false; end

function PetHasTarget() local pet = GetPet(); if (not pet == 0) and (not pet == nil) then if (not GetUnitsTarget(pet) == nil) and (not GetUnitsTarget(pet) == 0) then return true; end end return false; end