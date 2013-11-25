-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

ProbablyEngine.raid = {
  roster = { },
  roster_fast = { }
}


ProbablyEngine.raid.acquireTank = function()
  if UnitExists('focus') then
    return 'focus'
  else
    return 'player'
  end
end

ProbablyEngine.raid.build = function()
  ProbablyEngine.raid.roster = {}
  if UnitInRaid("player") then
    for i = 1, 40 do
      local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i);
      if online and UnitExists('raid' .. i)  then
        ProbablyEngine.raid.roster['raid' .. i] = UnitHealth('raid' .. i)
      end
    end
  elseif UnitInParty("player") then
    for i = 1, GetNumGroupMembers() do
      local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i);
      if online and UnitExists('party' .. i) then
        ProbablyEngine.raid.roster['party' .. i] = UnitHealth('party' .. i)
      end
    end
  else
    ProbablyEngine.raid.roster['player'] = UnitHealth('player')
  end
end


ProbablyEngine.raid.lowestHP = function()
  local lowestTarget = false
  local lowestHP = 100
  for target, health in pairs(ProbablyEngine.raid.roster) do
    local max = UnitHealthMax(target)
    local per = math.abs(math.floor(health/max*100))
    if per < lowestHP and health ~= 0 then
      lowestHP = per
      lowestTarget = target
    end
  end
  if lowestTarget and lowestHP ~= 100 then
    return lowestTarget
  end
  return false
end

ProbablyEngine.raid.needsHealing = function(threshold)
  if not threshold then threshold = 80 end
  local needsHealing = 0
  for target, health in pairs(ProbablyEngine.raid.roster) do
    local max = UnitHealthMax(target)
    local per = math.abs(math.floor(health/max*100))
    if per <= threshold and health ~= 0 then
      needsHealing = needsHealing + 1
    end
  end
  return needsHealing
end

ProbablyEngine.raid.tank = function()
  local possibleTank = false
  local highestHP = 100
  for target, health in pairs(ProbablyEngine.raid.roster) do
    local max = UnitHealthMax(target)
    if max > highestHP and health ~= 0 then
      highestHP = max
      possibleTank = target
    end
  end
  return possibleTank
end
