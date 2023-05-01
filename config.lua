local A, L = ...

local LibStub = LibStub
local LSM = LibStub("LibSharedMedia-3.0")

L.cfg = {
  enable = false,

  linkActionBars = false,

  bars = {
    MainMenuBar = true,
    MultiBarBottomLeft = true,
    MultiBarBottomRight = true,
    MultiBarRight = false,
    MultiBarLeft = false,
    MultiBar5 = false,
    MultiBar6 = false,
    MultiBar7 = false,
    StanceBar = true,
    PetActionBar = true,
  },
}

local _, class = UnitClass("player")

if class == "DEMONHUNTER" then
  L.cfg.enable = true
end

if class == "EVOKER" then
  L.cfg.enable = true
end

if class == "ROGUE" then
  L.cfg.enable = true
end

if class == "WARRIOR" then
  L.cfg.enable = true
end
