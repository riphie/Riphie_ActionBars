local A, L = ...

L.cfg = {
  enable = true,

  linkActionBars = false,

  bars = {
    MainMenuBar = true,
    MultiBarBottomLeft = true,
    MultiBarBottomRight = true,
    MultiBarRight = false,
    MultiBarLeft = true,
    MultiBar5 = false,
    MultiBar6 = false,
    MultiBar7 = false,
    StanceBar = true,
    PetActionBar = false,
  },
}

local _, class = UnitClass "player"

if class == "DEATHKNIGHT" then
  L.cfg.enable = false
end

if class == "HUNTER" then
  L.cfg.enable = false
end

if class == "MAGE" then
  L.cfg.enable = false
end

if class == "MONK" then
  L.cfg.enable = false
end

if class == "PALADIN" then
  L.cfg.enable = false
end

if class == "PRIEST" then
  L.cfg.enable = false
end
