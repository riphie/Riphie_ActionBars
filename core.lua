local A, L = ...
local cfg = L.cfg

local bar_names = {
  "MainMenuBar",
  "MultiBarBottomLeft",
  "MultiBarBottomRight",
  "MultiBarRight",
  "MultiBarLeft",
  "MultiBar5",
  "MultiBar6",
  "MultiBar7",
  "StanceBar",
  "PetActionBar",
}

local button_names = {
  "ActionButton",
  "MultiBarBottomLeftButton",
  "MultiBarBottomRightButton",
  "MultiBarRightButton",
  "MultiBarLeftButton",
  "MultiBar5Button",
  "MultiBar6Button",
  "MultiBar7Button",
  "StanceButton",
  "PetActionButton",
}

L.bars = {}
L.buttons = {}

L.dragonriding = false
L.bypass = nil

L.eventFrame = CreateFrame("Frame", A .. "EventFrame", UIParent)

function L:CheckBypass(bar_name)
  local dragonridingBypass = (L.dragonriding and bar_name == "MainMenuBar")
  local adHocBypass = (L.bypass == bar_name)

  return not (dragonridingBypass or adHocBypass)
end

function L:ApplyOnBar(bar, bar_name)
  if bar == nil then
    return
  end

  if bar_name == nil or (not L:CheckBypass(bar_name)) then
    bar:SetAlpha(1)
    return
  end

  if cfg.bars[bar_name] then
    bar:SetAlpha(0)
  else
    bar:SetAlpha(1)
  end
end

function L:SecureHook(frame, bar, bar_name)
  frame:HookScript("OnEnter", function()
    if cfg.enable then
      L:ShowOrHideBar("Show", bar, bar_name)
    end
  end)

  frame:HookScript("OnLeave", function()
    if cfg.enable then
      L:ShowOrHideBar("Hide", bar, bar_name)
    end
  end)
end

function L:ShowOrHideBar(transition, bar, bar_name)
  if cfg.linkActionBars then
    for _, linked_bar_name in ipairs(bar_names) do
      if cfg.bars[linked_bar_name] and L:CheckBypass(linked_bar_name) then
        if transition == "Show" then
          L.bars[linked_bar_name]:SetAlpha(1)
        else
          L.bars[linked_bar_name]:SetAlpha(0)
        end
      end
    end
  else
    if cfg.bars[bar_name] and L:CheckBypass(bar_name) then
      if transition == "Show" then
        bar:SetAlpha(1)
      else
        bar:SetAlpha(0)
      end
    end
  end
end

function L:HookBars()
  L:ResumeCallbacks()

  for bar_name, bar in pairs(L.bars) do
    L:ApplyOnBar(bar, bar_name)
    L:SecureHook(bar, bar, bar_name)

    for _, button in pairs(L.buttons[bar_name]) do
      L:SecureHook(button, bar, bar_name)
      L:SetBling(button.cooldown, false)
    end
  end
end

function L:SetBling(cooldown, flag)
  if not cooldown then
    return
  end

  cooldown:SetDrawBling(flag)
end

function L:SetBlingRender(bar_name, flag)
  if not L.buttons[bar_name] then
    return
  end

  for _, button in ipairs(L.buttons[bar_name]) do
    L:SetBling(button.cooldown, flag)
  end
end

function L:ResumeCallbacks()
  cfg.enable = true
end

function L:PauseCallbacks()
  cfg.enable = false
end

function L:ShowBars()
  L:PauseCallbacks()

  for bar_name, bar in pairs(L.bars) do
    bar:SetAlpha(1)
    L:SetBlingRender(bar_name, true)
  end
end

function L:HideBars()
  L:ResumeCallbacks()

  for bar_name, bar in pairs(L.bars) do
    L:ApplyOnBar(bar, bar_name)
    L:SetBlingRender(bar_name, false)
  end
end

function L:Dragonriding()
  if not cfg.enable then
    return
  end

  if IsMounted() and HasBonusActionBar() then
    L.dragonriding = true
    L.bars["MainMenuBar"]:SetAlpha(1)
  elseif L.dragonriding then
    L.dragonriding = false
    L:ApplyOnBar(L.bars["MainMenuBar"], "MainMenuBar")
  end
end

function L:GetFlyoutParent()
  if SpellFlyout:IsShown() then
    local parent = SpellFlyout:GetParent()
    local parent_name = parent:GetName() or ""

    if string_find(parent_name, "([Bb]utton)%d") then
      local index = (function(array, value)
        for i, v in ipairs(array) do
          if v == value then
            return i
          end
        end

        return nil
      end)(button_names, string_gsub(parent_name, "%d", ""))

      if index then
        return bar_names[index]
      end
    end
  end

  return nil
end

function L:HandleFlyoutShow()
  if not cfg.enable then
    return
  end

  L.bypass = L:GetFlyoutParent()
  L.bars[L.bypass]:SetAlpha(1)
end

function L:HandleFlyoutHide()
  if not cfg.enable then
    return
  end

  local prev_bypass = L.bypass

  if prev_bypass then
    L.bypass = nil
    L:ShowOrHideBar("Hide", L.bars[prev_bypass], prev_bypass)
  end
end

function L:OnInit()
  for _, barName in ipairs(bar_names) do
    L.bars[barName] = _G[barName]
  end

  for i, button_name in ipairs(button_names) do
    L.buttons[bar_names[i]] = {}

    if i <= 8 then
      for j = 1, 12 do
        L.buttons[bar_names[i]][j] = _G[button_name .. j]
      end
    else
      for j = 1, 10 do
        L.buttons[bar_names[i]][j] = _G[button_name .. j]
      end
    end
  end

  table.insert(L.buttons["MainMenuBar"], _G["MainMenuBarVehicleLeaveButton"])
end

function L:OnEnable()
  L.eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
  L.eventFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
  L.eventFrame:RegisterEvent("ACTIONBAR_HIDEGRID")

  QuickKeybindFrame:HookScript("OnShow", function()
    L:ShowBars()
  end)
  QuickKeybindFrame:HookScript("OnHide", function()
    L:HideBars()
  end)

  EditModeManagerFrame:HookScript("OnShow", function()
    C_Timer.After(0.05, function()
      L:ShowBars()
    end)
  end)
  EditModeManagerFrame:HookScript("OnHide", function()
    C_Timer.After(0.05, function()
      L:HideBars()
    end)
  end)

  SpellFlyout:HookScript("OnShow", function()
    L:HandleFlyoutShow()
  end)
  SpellFlyout:HookScript("OnHide", function()
    L:HandleFlyoutHide()
  end)

  C_Timer.After(0.05, function()
    L:Dragonriding()
    L:HookBars()
  end)
end

L.eventFrame:RegisterEvent("ADDON_LOADED")
L.eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" then
    if cfg.enable then
      L:OnInit()
      L:OnEnable()
    end
  elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
    L:Dragonriding()
  elseif event == "ACTIONBAR_SHOWGRID" then
    L:ShowBars()
  elseif event == "ACTIONBAR_HIDEGRID" then
    L:HideBars()
  end
end)
