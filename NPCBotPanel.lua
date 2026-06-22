-- NPCBotPanel v3.0 - Barra compacta con menús desplegables
-- Compatible con WoW 3.3.5a (AzerothCore + mod-npcbots)
-- Autor: NPCBotPanel Addon & Lleguito

-- ============================================================
-- LOCALIZATION
-- ============================================================
local L = {
    es = {
        title = "NPCBot",
        close = "Cerrar",
        lock = "Bloquear barra",
        unlock = "Desbloquear barra",
        locked_msg = "Barra bloqueada",
        unlocked_msg = "Barra desbloqueada",
        reset_msg = "Posición restablecida",
        loaded_msg = "cargado. Escribe |cffffffff/nbp|r o usa el icono del minimapa.",
        created_by = "Creado por Lleguito",
        command = "Comando:",
        tab_movement = "Movimiento",
        tab_combat = "Combate",
        tab_bonds = "Vínculos",
        tab_utility = "Utilidad",
        btn_follow = "Seguir",             desc_follow = "Bots te siguen",
        btn_follow_only = "Seguir Inact.", desc_follow_only = "Siguen pero sin actuar",
        btn_standstill = "Quedarse",       desc_standstill = "Aguantan posición",
        btn_stopfully = "Parada Total",    desc_stopfully = "Paran e ignoran todo",
        btn_walk = "Caminar",              desc_walk = "Alternar modo caminar",
        btn_nocast = "Sin Hechizos",       desc_nocast = "Alternar uso de hechizos",
        btn_nolongcast = "Sin Cast Lento", desc_nolongcast = "Alternar hechizos con cast",
        btn_nogossip = "Sin Gossip",       desc_nogossip = "Alternar menú de gossip",
        btn_unbind = "Desvincular",        desc_unbind = "Desvincular bot seleccionado",
        btn_rebind = "Revincular",         desc_rebind = "Llamar bot desvinculado",
        btn_hide = "Ocultar Bots",         desc_hide = "Desaparecen temporalmente",
        btn_show = "Mostrar Bots",         desc_show = "Vuelven a aparecer",
        btn_info = "Info",                 desc_info = "Ver estado de tus bots",
        btn_recall = "Recall",             desc_recall = "Llamar bots a tu posición",
        btn_teleport = "Teleportar",       desc_teleport = "Teleportar bots a ti",
        btn_kill = "Matar Bot",            desc_kill = "Matar bot (debug de estado)",
        btn_dist10 = "Dist: 10",           desc_dist10 = "Distancia de seguimiento 10",
        btn_dist20 = "Dist: 20",           desc_dist20 = "Distancia de seguimiento 20",
        btn_dist50 = "Dist: 50",           desc_dist50 = "Distancia de seguimiento 50",
        mm_click_left = "Click: Mostrar/Ocultar barra",
        mm_click_right = "Click Derecho: Escribe comando",
    },
    en = {
        title = "NPCBot",
        close = "Close",
        lock = "Lock bar",
        unlock = "Unlock bar",
        locked_msg = "Bar locked",
        unlocked_msg = "Bar unlocked",
        reset_msg = "Position reset",
        loaded_msg = "loaded. Type |cffffffff/nbp|r or use the minimap icon.",
        created_by = "Created by Lleguito",
        command = "Command:",
        tab_movement = "Movement",
        tab_combat = "Combat",
        tab_bonds = "Bonds",
        tab_utility = "Utility",
        btn_follow = "Follow",             desc_follow = "Bots follow you",
        btn_follow_only = "Follow Idle",   desc_follow_only = "Follow but do not act",
        btn_standstill = "Stay",           desc_standstill = "Hold position",
        btn_stopfully = "Full Stop",       desc_stopfully = "Stop and ignore everything",
        btn_walk = "Walk",                 desc_walk = "Toggle walking mode",
        btn_nocast = "No Spells",          desc_nocast = "Toggle spell casting",
        btn_nolongcast = "No Slow Cast",   desc_nolongcast = "Toggle spells with cast time",
        btn_nogossip = "No Gossip",        desc_nogossip = "Toggle gossip menu",
        btn_unbind = "Unbind",             desc_unbind = "Unbind selected bot",
        btn_rebind = "Rebind",             desc_rebind = "Summon unbound bot",
        btn_hide = "Hide Bots",            desc_hide = "Temporarily disappear",
        btn_show = "Show Bots",            desc_show = "Reappear",
        btn_info = "Info",                 desc_info = "View status of your bots",
        btn_recall = "Recall",             desc_recall = "Call bots to your position",
        btn_teleport = "Teleport",         desc_teleport = "Teleport bots to you",
        btn_kill = "Kill Bot",             desc_kill = "Kill bot (status debug)",
        btn_dist10 = "Dist: 10",           desc_dist10 = "Follow distance 10",
        btn_dist20 = "Dist: 20",           desc_dist20 = "Follow distance 20",
        btn_dist50 = "Dist: 50",           desc_dist50 = "Follow distance 50",
        mm_click_left = "Click: Show/Hide bar",
        mm_click_right = "Right Click: Type command",
    }
}

-- ============================================================
-- SAVED VARIABLES & DEFAULTS
-- ============================================================
NPCBotPanelDB = NPCBotPanelDB or {}

local function initDB()
    if NPCBotPanelDB.posX    == nil then NPCBotPanelDB.posX    = 0    end
    if NPCBotPanelDB.posY    == nil then NPCBotPanelDB.posY    = 200  end
    if NPCBotPanelDB.locked  == nil then NPCBotPanelDB.locked  = false end
    if NPCBotPanelDB.mmAngle == nil then NPCBotPanelDB.mmAngle = 45   end
    if NPCBotPanelDB.visible == nil then NPCBotPanelDB.visible = true  end
    if NPCBotPanelDB.lang    == nil then NPCBotPanelDB.lang    = "es"  end
end

-- ============================================================
-- CONSTANTES DE DISEÑO
-- ============================================================
local WHITE_TEX   = "Interface\\Buttons\\WHITE8x8"
local BAR_H       = 26          -- altura de la barra principal
local MENU_BTN_H  = 28          -- altura de cada botón en el desplegable
local MENU_BTN_W  = 148         -- ancho de los botones del desplegable
local TAB_PADDING = 12          -- padding horizontal de cada pestaña
local ICON_SIZE   = 16          -- icono dentro del desplegable

-- ============================================================
-- DATOS DE TABS (recarga con idioma activo)
-- ============================================================
local tabs = {}

local function loadTabsData()
    local str = L[NPCBotPanelDB.lang or "es"]
    tabs = {
        {
            name = str.tab_movement,
            icon = "Interface\\Icons\\Ability_Hunter_SniperShot",
            color = { 0.2, 0.9, 0.3 },
            buttons = {
                { label=str.btn_follow,      desc=str.desc_follow,      cmd=".npcbot command follow",      r=0.2,  g=0.9,  b=0.3,  icon="Interface\\Icons\\Ability_Hunter_SniperShot"   },
                { label=str.btn_follow_only, desc=str.desc_follow_only, cmd=".npcbot command follow only", r=0.3,  g=0.6,  b=1.0,  icon="Interface\\Icons\\Spell_Nature_Slow"           },
                { label=str.btn_standstill,  desc=str.desc_standstill,  cmd=".npcbot command standstill",  r=1.0,  g=0.5,  b=0.1,  icon="Interface\\Icons\\Spell_Nature_StoneClawTotem" },
                { label=str.btn_stopfully,   desc=str.desc_stopfully,   cmd=".npcbot command stopfully",   r=0.9,  g=0.2,  b=0.2,  icon="Interface\\Icons\\Ability_Golemstormbolt"      },
                { label=str.btn_walk,        desc=str.desc_walk,        cmd=".npcbot command walk",        r=0.7,  g=0.3,  b=1.0,  icon="Interface\\Icons\\Ability_Warrior_Endlessrage"  },
            },
        },
        {
            name = str.tab_combat,
            icon = "Interface\\Icons\\Spell_Holy_Silence",
            color = { 0.9, 0.2, 0.2 },
            buttons = {
                { label=str.btn_nocast,     desc=str.desc_nocast,     cmd=".npcbot command nocast",     r=0.9, g=0.2, b=0.2, icon="Interface\\Icons\\Spell_Holy_Silence"       },
                { label=str.btn_nolongcast, desc=str.desc_nolongcast, cmd=".npcbot command nolongcast", r=1.0, g=0.5, b=0.1, icon="Interface\\Icons\\Spell_Nature_SpiritArmor" },
                { label=str.btn_nogossip,   desc=str.desc_nogossip,   cmd=".npcbot command nogossip",   r=0.3, g=0.6, b=1.0, icon="Interface\\Icons\\INV_Misc_Note_01"         },
            },
        },
        {
            name = str.tab_bonds,
            icon = "Interface\\Icons\\Ability_Rogue_ShadowStrikes",
            color = { 1.0, 0.5, 0.1 },
            buttons = {
                { label=str.btn_unbind, desc=str.desc_unbind, cmd=".npcbot command unbind", r=1.0, g=0.5, b=0.1, icon="Interface\\Icons\\Ability_Rogue_ShadowStrikes" },
                { label=str.btn_rebind, desc=str.desc_rebind, cmd=".npcbot command rebind", r=0.2, g=0.9, b=0.3, icon="Interface\\Icons\\Spell_Nature_NaturesBlessing"},
                { label=str.btn_hide,   desc=str.desc_hide,   cmd=".npcbot hide",           r=0.7, g=0.3, b=1.0, icon="Interface\\Icons\\Ability_Vanish"              },
                { label=str.btn_show,   desc=str.desc_show,   cmd=".npcbot show",           r=0.2, g=0.9, b=0.3, icon="Interface\\Icons\\Ability_Stealth"              },
            },
        },
        {
            name = str.tab_utility,
            icon = "Interface\\Icons\\INV_Misc_QuestionMark",
            color = { 0.3, 0.6, 1.0 },
            buttons = {
                { label=str.btn_info,     desc=str.desc_info,     cmd=".npcbot info",            r=0.3,  g=0.6,  b=1.0,  icon="Interface\\Icons\\INV_Misc_QuestionMark"        },
                { label=str.btn_recall,   desc=str.desc_recall,   cmd=".npcbot recall",          r=0.2,  g=0.9,  b=0.3,  icon="Interface\\Icons\\Spell_Nature_Cyclone"          },
                { label=str.btn_teleport, desc=str.desc_teleport, cmd=".npcbot recall teleport", r=0.3,  g=0.6,  b=1.0,  icon="Interface\\Icons\\Spell_Arcane_PortalDarnassus"  },
                { label=str.btn_kill,     desc=str.desc_kill,     cmd=".npcbot kill",            r=0.9,  g=0.2,  b=0.2,  icon="Interface\\Icons\\Ability_Hunter_SniperShot"     },
                { label=str.btn_dist10,   desc=str.desc_dist10,   cmd=".npcbot distance 10",     r=1.0,  g=0.82, b=0.0,  icon="Interface\\Icons\\INV_Boots_Cloth_05"            },
                { label=str.btn_dist20,   desc=str.desc_dist20,   cmd=".npcbot distance 20",     r=1.0,  g=0.82, b=0.0,  icon="Interface\\Icons\\INV_Boots_Cloth_05"            },
                { label=str.btn_dist50,   desc=str.desc_dist50,   cmd=".npcbot distance 50",     r=1.0,  g=0.82, b=0.0,  icon="Interface\\Icons\\INV_Boots_Cloth_05"            },
            },
        },
    }
end

-- ============================================================
-- EJECUTAR COMANDO
-- ============================================================
local function executeCommand(cmd)
    SendChatMessage(cmd, "SAY")
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot]|r " .. cmd)
end

-- ============================================================
-- VARIABLES GLOBALES DE UI
-- ============================================================
local barFrame           -- la barra principal
local openMenuFrame      -- el menú desplegable actualmente abierto (o nil)
local openMenuTabIdx     -- índice del tab con el menú abierto
local tabButtons = {}    -- botones de la barra (referencias)
local langLblRef         -- referencia al FontString del botón de idioma
local updateLocalization -- declarada antes de uso

-- ============================================================
-- MENÚ DESPLEGABLE
-- ============================================================
local function closeOpenMenu()
    if openMenuFrame then
        openMenuFrame:Hide()
        -- Restaurar color del tab activo
        if openMenuTabIdx and tabButtons[openMenuTabIdx] then
            tabButtons[openMenuTabIdx].highlight:Hide()
        end
        openMenuFrame = nil
        openMenuTabIdx = nil
    end
end

local function buildDropdownMenu(tabIdx, anchorBtn)
    local tabData = tabs[tabIdx]
    if not tabData then return end

    local menuH = #tabData.buttons * MENU_BTN_H + 4

    local menu = CreateFrame("Frame", nil, UIParent)
    menu:SetWidth(MENU_BTN_W)
    menu:SetHeight(menuH)
    menu:SetFrameStrata("HIGH")
    menu:SetClampedToScreen(true)

    -- Fondo del menú
    local menuBg = menu:CreateTexture(nil, "BACKGROUND")
    menuBg:SetTexture(WHITE_TEX)
    menuBg:SetVertexColor(0.05, 0.05, 0.08, 0.96)
    menuBg:SetAllPoints()

    -- Borde exterior dorado
    local menuBorder = menu:CreateTexture(nil, "BACKGROUND")
    menuBorder:SetTexture(WHITE_TEX)
    menuBorder:SetVertexColor(0.7, 0.55, 0.0, 0.9)
    menuBorder:SetPoint("TOPLEFT",     menu, "TOPLEFT",    -1,  1)
    menuBorder:SetPoint("BOTTOMRIGHT", menu, "BOTTOMRIGHT", 1, -1)
    menuBorder:SetDrawLayer("BACKGROUND", -1)

    -- Línea de color del tab en la parte superior
    local topAccent = menu:CreateTexture(nil, "ARTWORK")
    topAccent:SetTexture(WHITE_TEX)
    topAccent:SetVertexColor(tabData.color[1], tabData.color[2], tabData.color[3], 1)
    topAccent:SetHeight(2)
    topAccent:SetPoint("TOPLEFT",  menu, "TOPLEFT",  0,  0)
    topAccent:SetPoint("TOPRIGHT", menu, "TOPRIGHT", 0,  0)

    -- Posicionar menú: debajo o arriba según espacio
    menu:ClearAllPoints()
    local anchorX = anchorBtn:GetLeft()
    local anchorYBottom = anchorBtn:GetBottom()
    local screenH = GetScreenHeight() / UIParent:GetEffectiveScale()

    -- ¿Cabe hacia abajo?
    if anchorYBottom - menuH > 0 then
        menu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", anchorX, anchorYBottom)
    else
        menu:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", anchorX, anchorYBottom + BAR_H + menuH)
    end

    -- Botones del menú
    for i, btnData in ipairs(tabData.buttons) do
        local btn = CreateFrame("Button", nil, menu)
        btn:SetHeight(MENU_BTN_H)
        btn:SetPoint("LEFT",  menu, "LEFT",  0, 0)
        btn:SetPoint("RIGHT", menu, "RIGHT", 0, 0)
        btn:SetPoint("TOP",   menu, "TOP",   0, -2 - (i - 1) * MENU_BTN_H)

        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
        btnBg:SetTexture(WHITE_TEX)
        btnBg:SetVertexColor(0.10, 0.10, 0.15, 1)
        btnBg:SetAllPoints()

        -- Acento de color lateral
        local accent = btn:CreateTexture(nil, "ARTWORK")
        accent:SetTexture(WHITE_TEX)
        accent:SetVertexColor(btnData.r, btnData.g, btnData.b, 1)
        accent:SetPoint("TOPLEFT",    btn, "TOPLEFT",    2, -3)
        accent:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 2,  3)
        accent:SetWidth(2)

        -- Icono
        local ico = btn:CreateTexture(nil, "ARTWORK")
        ico:SetTexture(btnData.icon)
        ico:SetSize(ICON_SIZE, ICON_SIZE)
        ico:SetPoint("LEFT", btn, "LEFT", 10, 0)
        ico:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        -- Texto
        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("LEFT", ico, "RIGHT", 6, 0)
        lbl:SetText(btnData.label)
        lbl:SetTextColor(0.92, 0.88, 0.72)

        btn:SetScript("OnEnter", function()
            local s = L[NPCBotPanelDB.lang or "es"]
            btnBg:SetVertexColor(0.20, 0.18, 0.28, 1)
            lbl:SetTextColor(btnData.r, btnData.g, btnData.b)
            GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine("|cffffd700" .. btnData.label .. "|r")
            GameTooltip:AddLine(btnData.desc, 1, 1, 1, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(s.command, 0.7, 0.7, 0.7)
            GameTooltip:AddLine("|cffffffff" .. btnData.cmd .. "|r")
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            btnBg:SetVertexColor(0.10, 0.10, 0.15, 1)
            lbl:SetTextColor(0.92, 0.88, 0.72)
            GameTooltip:Hide()
        end)

        local cmdCapture = btnData.cmd
        btn:SetScript("OnClick", function()
            executeCommand(cmdCapture)
            closeOpenMenu()
        end)
    end

    -- Cerrar menú si se hace clic fuera
    menu:EnableMouse(true)
    menu:SetScript("OnHide", function()
        GameTooltip:Hide()
    end)

    return menu
end

-- ============================================================
-- BARRA PRINCIPAL
-- ============================================================
local function buildBar()
    local str = L[NPCBotPanelDB.lang or "es"]

    -- ---- Medir ancho necesario ----
    -- Logo: icono (20) + texto + padding
    -- Cada tab: texto + padding
    -- Botones extra: lock (20) + close (20) + separadores
    -- Usamos ancho fijo calculado (290px es buen tamaño inicial)
    local BAR_W = 322

    barFrame = CreateFrame("Frame", "NPCBotPanelBarFrame", UIParent)
    barFrame:SetHeight(BAR_H)
    barFrame:SetWidth(BAR_W)
    barFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", NPCBotPanelDB.posX, NPCBotPanelDB.posY)
    barFrame:SetFrameStrata("MEDIUM")
    barFrame:SetClampedToScreen(true)
    barFrame:EnableMouse(true)
    barFrame:SetMovable(not NPCBotPanelDB.locked)
    if not NPCBotPanelDB.locked then
        barFrame:RegisterForDrag("LeftButton")
    end

    -- Fondo de la barra
    local barBg = barFrame:CreateTexture(nil, "BACKGROUND")
    barBg:SetTexture(WHITE_TEX)
    barBg:SetVertexColor(0.05, 0.05, 0.08, 0.95)
    barBg:SetAllPoints()

    -- Borde dorado
    local barBorder = barFrame:CreateTexture(nil, "BACKGROUND")
    barBorder:SetTexture(WHITE_TEX)
    barBorder:SetVertexColor(0.7, 0.55, 0.0, 0.85)
    barBorder:SetPoint("TOPLEFT",     barFrame, "TOPLEFT",    -1,  1)
    barBorder:SetPoint("BOTTOMRIGHT", barFrame, "BOTTOMRIGHT", 1, -1)
    barBorder:SetDrawLayer("BACKGROUND", -1)

    -- Línea dorada superior (decorativa)
    local topLine = barFrame:CreateTexture(nil, "ARTWORK")
    topLine:SetTexture(WHITE_TEX)
    topLine:SetVertexColor(1.0, 0.82, 0.0, 0.7)
    topLine:SetHeight(1)
    topLine:SetPoint("TOPLEFT",  barFrame, "TOPLEFT",  0, 0)
    topLine:SetPoint("TOPRIGHT", barFrame, "TOPRIGHT", 0, 0)

    -- ---- LOGO / ICONO (sin texto, tooltip al pasar) ----
    local logoBtn = CreateFrame("Button", nil, barFrame)
    logoBtn:SetSize(20, 20)
    logoBtn:SetPoint("LEFT", barFrame, "LEFT", 5, 0)

    local logoIco = logoBtn:CreateTexture(nil, "ARTWORK")
    logoIco:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01")
    logoIco:SetSize(18, 18)
    logoIco:SetPoint("CENTER", logoBtn, "CENTER", 0, 0)
    logoIco:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    logoBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cffffd700NPCBots Panel|r")
        GameTooltip:AddLine("v3.0 · by Lleguito", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    logoBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Separador tras el logo
    local sep0 = barFrame:CreateTexture(nil, "ARTWORK")
    sep0:SetTexture(WHITE_TEX)
    sep0:SetVertexColor(0.5, 0.40, 0.05, 0.6)
    sep0:SetWidth(1)
    sep0:SetPoint("TOPLEFT",    barFrame, "TOPLEFT",    28, -3)
    sep0:SetPoint("BOTTOMLEFT", barFrame, "BOTTOMLEFT", 28,  3)

    -- ---- BOTONES DE TAB ----
    local tabStartX = 32
    local currentX = tabStartX

    -- Reservamos los últimos 76px para lang+lock+close
    local tabAreaW = BAR_W - tabStartX - 76

    -- Calculamos cuánto ocupa cada tab
    local tabW = math.floor(tabAreaW / #tabs)

    tabButtons = {}

    for i, tabDef in ipairs(tabs) do
        local tb = CreateFrame("Button", nil, barFrame)
        tb:SetHeight(BAR_H)
        tb:SetWidth(tabW)
        tb:SetPoint("LEFT", barFrame, "LEFT", currentX + (i-1)*tabW, 0)

        -- Fondo del tab
        local tbBg = tb:CreateTexture(nil, "BACKGROUND")
        tbBg:SetTexture(WHITE_TEX)
        tbBg:SetVertexColor(0.0, 0.0, 0.0, 0.0)
        tbBg:SetAllPoints()
        tb.bg = tbBg

        -- Highlight (activo o hover)
        local tbHl = tb:CreateTexture(nil, "ARTWORK")
        tbHl:SetTexture(WHITE_TEX)
        tbHl:SetVertexColor(tabDef.color[1], tabDef.color[2], tabDef.color[3], 0.15)
        tbHl:SetAllPoints()
        tbHl:Hide()
        tb.highlight = tbHl

        -- Línea inferior de color cuando el menú está abierto
        local tbLine = tb:CreateTexture(nil, "ARTWORK")
        tbLine:SetTexture(WHITE_TEX)
        tbLine:SetVertexColor(tabDef.color[1], tabDef.color[2], tabDef.color[3], 1)
        tbLine:SetHeight(2)
        tbLine:SetPoint("BOTTOMLEFT",  tb, "BOTTOMLEFT",  2, 0)
        tbLine:SetPoint("BOTTOMRIGHT", tb, "BOTTOMRIGHT", -2, 0)
        tbLine:Hide()
        tb.line = tbLine

        -- Texto del tab
        local tbLbl = tb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tbLbl:SetPoint("CENTER", tb, "CENTER", 0, 0)
        tbLbl:SetText(tabDef.name)
        tbLbl:SetTextColor(0.72, 0.68, 0.55)
        tb.lbl = tbLbl

        -- Separador entre tabs
        if i > 1 then
            local sep = barFrame:CreateTexture(nil, "ARTWORK")
            sep:SetTexture(WHITE_TEX)
            sep:SetVertexColor(0.35, 0.28, 0.04, 0.5)
            sep:SetWidth(1)
            local sepX = currentX + (i-1)*tabW
            sep:SetPoint("TOPLEFT",    barFrame, "TOPLEFT",    sepX, -3)
            sep:SetPoint("BOTTOMLEFT", barFrame, "BOTTOMLEFT", sepX,  3)
        end

        local iCapture = i
        tb:SetScript("OnEnter", function(self)
            if openMenuTabIdx ~= iCapture then
                tbHl:Show()
                tbLbl:SetTextColor(tabDef.color[1], tabDef.color[2], tabDef.color[3])
            end
        end)
        tb:SetScript("OnLeave", function(self)
            if openMenuTabIdx ~= iCapture then
                tbHl:Hide()
                tbLbl:SetTextColor(0.72, 0.68, 0.55)
            end
        end)

        tb:SetScript("OnClick", function(self)
            if openMenuTabIdx == iCapture then
                -- Ya estaba abierto: cerrarlo
                closeOpenMenu()
            else
                -- Cerrar cualquier menú previo
                closeOpenMenu()
                -- Abrir este
                openMenuTabIdx = iCapture
                self.highlight:Show()
                self.line:Show()
                self.lbl:SetTextColor(tabDef.color[1], tabDef.color[2], tabDef.color[3])
                openMenuFrame = buildDropdownMenu(iCapture, self)
                PlaySound("igMainMenuOptionCheckBoxOn")
            end
        end)

        -- Sobreescribir closeOpenMenu para restaurar el tab
        tabButtons[i] = tb
        currentX = currentX  -- ya usamos (i-1)*tabW en SetPoint
    end

    -- Extender closeOpenMenu para restaurar estilos del tab
    local _originalClose = closeOpenMenu
    closeOpenMenu = function()
        if openMenuFrame then
            openMenuFrame:Hide()
            if openMenuTabIdx and tabButtons[openMenuTabIdx] then
                local tb = tabButtons[openMenuTabIdx]
                tb.highlight:Hide()
                tb.line:Hide()
                tb.lbl:SetTextColor(0.72, 0.68, 0.55)
            end
            openMenuFrame = nil
            openMenuTabIdx = nil
        end
    end

    -- ---- SEPARADOR antes de los botones de control ----
    local sepControl = barFrame:CreateTexture(nil, "ARTWORK")
    sepControl:SetTexture(WHITE_TEX)
    sepControl:SetVertexColor(0.5, 0.40, 0.05, 0.6)
    sepControl:SetWidth(1)
    sepControl:SetPoint("TOPRIGHT",    barFrame, "TOPRIGHT",    -74, -3)
    sepControl:SetPoint("BOTTOMRIGHT", barFrame, "BOTTOMRIGHT", -74,  3)

    -- ---- BOTÓN DE IDIOMA (ES / EN) ----
    local langBtn = CreateFrame("Button", nil, barFrame)
    langBtn:SetSize(28, 16)
    langBtn:SetPoint("RIGHT", barFrame, "RIGHT", -44, 0)

    local langBg = langBtn:CreateTexture(nil, "BACKGROUND")
    langBg:SetTexture(WHITE_TEX)
    langBg:SetVertexColor(0.12, 0.10, 0.02, 1)
    langBg:SetAllPoints()

    local langBorder = langBtn:CreateTexture(nil, "BACKGROUND")
    langBorder:SetTexture(WHITE_TEX)
    langBorder:SetVertexColor(0.5, 0.40, 0.05, 0.7)
    langBorder:SetPoint("TOPLEFT",     langBtn, "TOPLEFT",    -1,  1)
    langBorder:SetPoint("BOTTOMRIGHT", langBtn, "BOTTOMRIGHT", 1, -1)
    langBorder:SetDrawLayer("BACKGROUND", -1)

    local langLbl = langBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    langLbl:SetPoint("CENTER", langBtn, "CENTER", 0, 0)
    langLbl:SetText(NPCBotPanelDB.lang == "es" and "|cff00ccffES|r" or "|cff00ccffEN|r")
    langLblRef = langLbl  -- guardar referencia global

    langBtn:SetScript("OnClick", function()
        NPCBotPanelDB.lang = (NPCBotPanelDB.lang == "es") and "en" or "es"
        langLbl:SetText(NPCBotPanelDB.lang == "es" and "|cff00ccffES|r" or "|cff00ccffEN|r")
        updateLocalization()
        PlaySound("igMainMenuOptionCheckBoxOn")
    end)
    langBtn:SetScript("OnEnter", function()
        langBg:SetVertexColor(0.20, 0.17, 0.04, 1)
        GameTooltip:SetOwner(langBtn, "ANCHOR_TOP")
        GameTooltip:ClearLines()
        if NPCBotPanelDB.lang == "es" then
            GameTooltip:AddLine("|cffffd700Idioma|r")
            GameTooltip:AddLine("Cambiar a English", 1, 1, 1)
        else
            GameTooltip:AddLine("|cffffd700Language|r")
            GameTooltip:AddLine("Switch to Español", 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    langBtn:SetScript("OnLeave", function()
        langBg:SetVertexColor(0.12, 0.10, 0.02, 1)
        GameTooltip:Hide()
    end)

    -- Separador entre lang y lock
    local sepLang = barFrame:CreateTexture(nil, "ARTWORK")
    sepLang:SetTexture(WHITE_TEX)
    sepLang:SetVertexColor(0.5, 0.40, 0.05, 0.6)
    sepLang:SetWidth(1)
    sepLang:SetPoint("TOPRIGHT",    barFrame, "TOPRIGHT",    -42, -3)
    sepLang:SetPoint("BOTTOMRIGHT", barFrame, "BOTTOMRIGHT", -42,  3)

    -- ---- BOTÓN LOCK ----
    local lockBtn = CreateFrame("Button", nil, barFrame)
    lockBtn:SetSize(18, 18)
    lockBtn:SetPoint("RIGHT", barFrame, "RIGHT", -22, 0)
    local lockIco = lockBtn:CreateTexture(nil, "ARTWORK")
    lockIco:SetTexture("Interface\\Icons\\Ability_Warrior_ShieldWall")
    lockIco:SetAllPoints()
    lockIco:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    if NPCBotPanelDB.locked then
        lockIco:SetVertexColor(1, 0.5, 0.1)
    end
    lockBtn:SetScript("OnClick", function()
        NPCBotPanelDB.locked = not NPCBotPanelDB.locked
        local s = L[NPCBotPanelDB.lang or "es"]
        if NPCBotPanelDB.locked then
            barFrame:SetMovable(false)
            barFrame:RegisterForDrag()
            lockIco:SetVertexColor(1, 0.5, 0.1)
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.locked_msg)
        else
            barFrame:SetMovable(true)
            barFrame:RegisterForDrag("LeftButton")
            lockIco:SetVertexColor(1, 1, 1)
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.unlocked_msg)
        end
    end)
    lockBtn:SetScript("OnEnter", function()
        local s = L[NPCBotPanelDB.lang or "es"]
        GameTooltip:SetOwner(lockBtn, "ANCHOR_TOP")
        GameTooltip:SetText(NPCBotPanelDB.locked and s.unlock or s.lock)
        GameTooltip:Show()
    end)
    lockBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ---- BOTÓN CLOSE ----
    local closeBtn = CreateFrame("Button", nil, barFrame)
    closeBtn:SetSize(14, 14)
    closeBtn:SetPoint("RIGHT", barFrame, "RIGHT", -5, 0)
    local closeTex = closeBtn:CreateTexture(nil, "ARTWORK")
    closeTex:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeTex:SetAllPoints()
    closeBtn:SetScript("OnClick", function()
        closeOpenMenu()
        barFrame:Hide()
        NPCBotPanelDB.visible = false
    end)
    closeBtn:SetScript("OnEnter", function()
        local s = L[NPCBotPanelDB.lang or "es"]
        GameTooltip:SetOwner(closeBtn, "ANCHOR_TOP")
        GameTooltip:SetText(s.close)
        GameTooltip:Show()
    end)
    closeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ---- DRAG ----
    barFrame:SetScript("OnDragStart", function(self)
        closeOpenMenu()
        self:StartMoving()
    end)
    barFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        NPCBotPanelDB.posX = self:GetLeft() + self:GetWidth() / 2 - UIParent:GetWidth() / 2
        NPCBotPanelDB.posY = self:GetBottom()
    end)
end

-- ============================================================
-- ACTUALIZACIÓN DE LOCALIZACIÓN
-- ============================================================
updateLocalization = function()
    loadTabsData()
    -- Actualizar etiquetas de tabs
    local str = L[NPCBotPanelDB.lang or "es"]
    for i, tb in ipairs(tabButtons) do
        if tabs[i] then
            tb.lbl:SetText(tabs[i].name)
        end
    end
    -- Actualizar botón de idioma
    if langLblRef then
        langLblRef:SetText(NPCBotPanelDB.lang == "es" and "|cff00ccffES|r" or "|cff00ccffEN|r")
    end
    -- Cerrar menú abierto (puede tener textos del idioma anterior)
    closeOpenMenu()
end

-- ============================================================
-- BOTÓN MINIMAPA
-- ============================================================
local mmBtn

local function buildMinimapButton()
    mmBtn = CreateFrame("Button", "NPCBotPanelMiniBtn", Minimap)
    mmBtn:SetFrameStrata("MEDIUM")
    mmBtn:SetFrameLevel(9)
    mmBtn:SetSize(32, 32)

    local function mmUpdatePos()
        local angle  = math.rad(NPCBotPanelDB.mmAngle or 45)
        local radius = 80
        mmBtn:ClearAllPoints()
        mmBtn:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end
    mmUpdatePos()

    local mmBg = mmBtn:CreateTexture(nil, "BACKGROUND")
    mmBg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    mmBg:SetAllPoints()

    local mmIco = mmBtn:CreateTexture(nil, "ARTWORK")
    mmIco:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01")
    mmIco:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    mmIco:SetSize(20, 20)
    mmIco:SetPoint("CENTER", mmBtn, "CENTER", 1, -1)

    mmBtn:SetScript("OnEnter", function(self)
        local s = L[NPCBotPanelDB.lang or "es"]
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cffffd700NPCBot Panel|r")
        GameTooltip:AddLine(s.mm_click_left, 1, 1, 1)
        GameTooltip:AddLine(s.mm_click_right, 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    mmBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    mmBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    mmBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if barFrame:IsShown() then
                closeOpenMenu()
                barFrame:Hide()
                NPCBotPanelDB.visible = false
            else
                barFrame:Show()
                NPCBotPanelDB.visible = true
            end
            PlaySound("igMainMenuOptionCheckBoxOn")
        elseif button == "RightButton" then
            if not ChatFrame1EditBox:IsVisible() then
                ChatFrame1EditBox:Show()
                ChatFrame1EditBox:SetFocus()
            end
            ChatFrame1EditBox:SetText(".npcbot ")
            ChatFrame1EditBox:SetCursorPosition(100)
        end
    end)

    mmBtn:EnableMouse(true)
    mmBtn:SetMovable(true)
    mmBtn:RegisterForDrag("LeftButton")
    mmBtn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local cx, cy = Minimap:GetCenter()
            local mx, my = GetCursorPosition()
            local uiScale = UIParent:GetEffectiveScale()
            mx = mx / uiScale
            my = my / uiScale
            local angle = math.atan2(my - cy, mx - cx)
            NPCBotPanelDB.mmAngle = math.deg(angle)
            mmUpdatePos()
        end)
    end)
    mmBtn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
SLASH_NPCBOTPANEL1 = "/nbp"
SLASH_NPCBOTPANEL2 = "/npcbotpanel"
SlashCmdList["NPCBOTPANEL"] = function(msg)
    local s = L[NPCBotPanelDB.lang or "es"]
    msg = msg:match("^%s*(.-)%s*$"):lower()
    if msg == "reset" then
        barFrame:ClearAllPoints()
        barFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 200)
        NPCBotPanelDB.posX = 0
        NPCBotPanelDB.posY = 200
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.reset_msg)
    elseif msg == "lock" then
        NPCBotPanelDB.locked = true
        barFrame:SetMovable(false)
        barFrame:RegisterForDrag()
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.locked_msg)
    elseif msg == "unlock" then
        NPCBotPanelDB.locked = false
        barFrame:SetMovable(true)
        barFrame:RegisterForDrag("LeftButton")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.unlocked_msg)
    elseif msg == "es" or msg == "en" then
        NPCBotPanelDB.lang = msg
        updateLocalization()
    else
        if barFrame and barFrame:IsShown() then
            closeOpenMenu()
            barFrame:Hide()
            NPCBotPanelDB.visible = false
        elseif barFrame then
            barFrame:Show()
            NPCBotPanelDB.visible = true
        end
    end
end

-- ============================================================
-- EVENTOS DE CARGA
-- ============================================================
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
local addonLoaded = false

loader:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "NPCBotPanel" then
        initDB()
        loadTabsData()
        buildBar()
        buildMinimapButton()
        if NPCBotPanelDB.visible then
            barFrame:Show()
        else
            barFrame:Hide()
        end
        addonLoaded = true

    elseif event == "PLAYER_LOGIN" and addonLoaded then
        local s = L[NPCBotPanelDB.lang or "es"]
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r v3.0 " .. s.loaded_msg)
    end
end)
