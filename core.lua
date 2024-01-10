function Jump()
	JumpOrAscendStart();
end

function StopJump()
	AscendStop();
end

function Cast(spellName, targetGUID)
	target = GetGUIDTarget(targetGUID);
	if (HasSpell(spellName)) then
		if (not IsMoving()) then
			if (IsSpellInRange(target, spellName)) then
				if (not IsSpellOnCD(spellName)) then
					if (not IsAutoCasting(spellName)) then
						if (IsInLineOfSight(target)) then
							FaceTarget(target);			
							CastSpell(spellName, target);				
							return true;
						end
					end
				end
			end			
		end
	end
	return false;
end

function Buff(spellName, player)
	if (IsStanding()) then
		if (not IsMoving()) then
			if (IsInLineOfSight(player)) then
				if (HasSpell(spellName)) then
					if (not IsSpellOnCD(spellName)) then
						if (not IsAutoCasting(spellName)) then
							if (not HasBuff(player, spellName)) then
								CastSpell(spellName, player);
								return true;
							end
						end
					end
				end
			end
		end
	end
	return false;
end