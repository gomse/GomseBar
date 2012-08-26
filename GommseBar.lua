-- 전역 변수 및 상수 선언.
local GOMMSEBAR_VERSION			= "1.5";
local GOMMSEBAR_NAME			= "곰세바";
local GOMMSEBAR_AUTHOR			= "곰세 (라그나로스-호드)";

local GOMMSEBAR_UPDATE_RATE		= 1.0;
local CHARACTER_MAX_LEVEL		= 85;

-- 단축키 정의.
BINDING_HEADER_GOMMSEBAR = GOMMSEBAR_NAME;
BINDING_NAME_GOMMSEBAR_COLLECTGARBAGE = "메모리 정리";


function GommseBar_Print( msg )
	if ( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage( "|cFF00FFFF<"..GOMMSEBAR_NAME..">: |cFFFFFFFF"..msg );
	end
end

function GommseBar_OnLoad( self )
	-- 이벤트 등록.
	self:RegisterEvent( "VARIABLES_LOADED" );

	-- 명령어 설정.
	SlashCmdList["GOMMSEBAR"] = GommseBar_SlashHandler;
	SLASH_GOMMSEBAR1 = "/gommsebar";
	SLASH_GOMMSEBAR2 = "/"..GOMMSEBAR_NAME;

	-- 변수 초기화.
	GommseBarFrame.timeSinceLastUpdate = 0;
	GommseBarFrame.tooltipTimer = 0;
end

function GommseBar_SlashHandler( msg )
	if ( string.find( msg, "툴팁" ) ) then
		GommseBar_CmdTooltip( msg );
	elseif ( string.find( msg, "배경" ) ) then
		GommseBar_CmdBackground( msg );
	elseif ( string.find( msg, "정보" ) ) then
		GommseBar_CmdInfo( msg );
	elseif ( string.find( msg, "초기화" ) ) then
		GommseBar_Reset();
		GommseBar_Print( "모두 초기화 되었습니다." );
	else
		GommseBar_Print( "--- 도움말 ---" );
		GommseBar_Print( "/"..GOMMSEBAR_NAME.." |cFFFFBB00툴팁 [없음/상단/하단] |cFFFFFFFF- 툴팁 표시 위치를 설정." );
		GommseBar_Print( "/"..GOMMSEBAR_NAME.." |cFFFFBB00배경 [없음/자동/경험치/평판] |cFFFFFFFF- 배경을 설정합니다." );
		GommseBar_Print( "/"..GOMMSEBAR_NAME.." |cFFFFBB00초기화 |cFFFFFFFF- 모든 설정을 초기화합니다." );
		GommseBar_Print( "/"..GOMMSEBAR_NAME.." |cFFFFBB00정보 |cFFFFFFFF- 애드온 정보 출력." );
	end
end

function GommseBar_CmdTooltip( msg )
	local _, _, cmd, arg = string.find( msg, "(.[^%s]+) (.+)" );

	if ( arg == "없음" ) then
		GommseBar_SavedVar.tooltip = 0;
		GommseBar_Print( "툴팁을 표시하지 않습니다." );
	elseif ( arg == "하단" ) then
		GommseBar_SavedVar.tooltip = 1;
		GommseBar_Print( "툴팁을 하단에 표시합니다." );
	elseif ( arg == "상단" ) then
		GommseBar_SavedVar.tooltip = 2;
		GommseBar_Print( "툴팁을 상단에 표시합니다." );
	else
		GommseBar_Print( "/"..GOMMSEBAR_NAME.." 툴팁 [없음/상단/하단]으로 툴팁이 표시되는 위치를 설정할 수 있습니다." );
	end
end

function GommseBar_CmdBackground( msg )
	local _, _, cmd, arg = string.find( msg, "(.[^%s]+) (.+)" );

	if ( arg == "없음" ) then
		GommseBar_SavedVar.background = 0;
		GommseBar_Print( "배경을 표시하지 않습니다." );
	elseif ( arg == "자동" ) then
		GommseBar_SavedVar.background = 1;
		GommseBar_Print( "배경을 자동으로 표시합니다." );
	elseif ( arg == "경험치" ) then
		GommseBar_SavedVar.background = 2;
		GommseBar_Print( "배경에 경험치바를 표시합니다." );
	elseif ( arg == "평판" ) then
		GommseBar_SavedVar.background = 3;
		GommseBar_Print( "배경에 평판바를 표시합니다." );
	else
		GommseBar_Print( "/"..GOMMSEBAR_NAME.." 배경 [없음/자동/경험치/평판]으로 배경을 설정할 수 있습니다." );
	end

	GommseBarStatusBar_Update();
end

function GommseBar_CmdInfo( msg )
	local tooltip		= "알 수 없음.";
	local background	= "알 수 없음.";

	if ( GommseBar_SavedVar.tooltip == 0 ) then		tooltip = "없음.";
	elseif ( GommseBar_SavedVar.tooltip == 1 ) then	tooltip = "하단.";
	elseif ( GommseBar_SavedVar.tooltip == 2 ) then	tooltip = "상단.";
	end

	if ( GommseBar_SavedVar.background == 0 ) then		background = "없음.";
	elseif ( GommseBar_SavedVar.background == 1 ) then	background = "자동.";
	elseif ( GommseBar_SavedVar.background == 2 ) then	background = "경험치.";
	elseif ( GommseBar_SavedVar.background == 3 ) then	background = "평판.";
	end

	GommseBar_Print( "--- 정보 ---" );
	GommseBar_Print( "|cFFFFBB00툴팁: |cFFFFFFFF"..tooltip );
	GommseBar_Print( "|cFFFFBB00배경: |cFFFFFFFF"..background );
	GommseBar_Print( "|cFFFFBB00제작: |cFFFFFFFF"..GOMMSEBAR_AUTHOR );
end

function GommseBar_Reset()
	GommseBar_SavedVar				= {};
	GommseBar_SavedVar.ver			= GOMMSEBAR_VERSION;
	GommseBar_SavedVar.tooltip		= 1;	-- 하단
	GommseBar_SavedVar.background	= 1;	-- 자동

	GommseBarFrame:ClearAllPoints();
	GommseBarFrame:SetPoint( "TOP", "UIParent", "TOP", 0, 0 );

	GommseBarStatusBar_Update();
end

function GommseBar_CheckSavedVar()
	if ( ( not GommseBar_SavedVar ) or ( GommseBar_SavedVar.ver ~= GOMMSEBAR_VERSION ) ) then
		GommseBar_Reset();
		return false;
	end

	return true;
end

function GommseBar_OnEvent( event )
	if ( event == "VARIABLES_LOADED" ) then
		GommseBar_OnVarLoaded();
	end
end

function GommseBar_OnVarLoaded()
	if ( GommseBar_CheckSavedVar() ) then
		GommseBarStatusBar_Update();
	end

	if ( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage( "|cFF00FFFF"..GOMMSEBAR_NAME.." v"..GOMMSEBAR_VERSION.." (명령어: /gommsebar, /"..GOMMSEBAR_NAME..")" );
	end
end

function GommseBar_OnUpdate( elapsed )
	GommseBarFrame.timeSinceLastUpdate = GommseBarFrame.timeSinceLastUpdate + elapsed;

	if ( GommseBarFrame.timeSinceLastUpdate > GOMMSEBAR_UPDATE_RATE ) then
		GommseBarFrame.timeSinceLastUpdate = 0.0;

		GommseBar_UpdateClock();
		GommseBar_UpdateTooltip();
	end
end

function GommseBar_OnMouseDown( button )
	if ( ( button == "LeftButton" ) and ( IsShiftKeyDown() ) ) then
		GommseBarFrame:StartMoving();
	elseif ( ( button == "RightButton" ) and ( IsShiftKeyDown() ) ) then
		GommseBarFrame:ClearAllPoints();
		GommseBarFrame:SetPoint( "TOP", "UIParent", "TOP", 0, 0 );
--	elseif ( button == "LeftButton" ) then
	elseif ( button == "RightButton" ) then
		GommseBar_CollectGarbage();
	end
end

function GommseBar_OnMouseUp( button )
	GommseBarFrame:StopMovingOrSizing();
end

function GommseBar_OnEnter()
	GommseBarTooltip_Show();
	GommseBarFrame.tooltipTimer = 0;
end

function GommseBar_OnLeave()
	GommseBarTooltip_Hide();
	GommseBarFrame.tooltipTimer = 0;
end

function GommseBar_UpdateClock()
	local hour, minute	= GetGameTime();
	local apmFormat		= TEXT( TIME_TWELVEHOURAM );

	-- 24시간제를 12시간제로 표시.
	if ( hour >= 12 ) then
		hour		= hour - 12;
		apmFormat	= TEXT( TIME_TWELVEHOURPM );
	end

	-- 시간이 0이면 12시로 보정.
	if ( hour == 0 ) then
		hour = 12;
	end

	GommseBarText:SetText( format( apmFormat, hour, minute ) );
end

function GommseBar_UpdateTooltip()
	if ( MouseIsOver( GommseBarFrame ) ) then
		GommseBarTooltip_Show();

		GommseBarFrame.tooltipTimer = GommseBarFrame.tooltipTimer + 1;
		if ( GommseBarFrame.tooltipTimer >= 3 ) then
			GommseBarTooltip:AddLine( "\n\n제작: |cFFFFFFFF"..GOMMSEBAR_AUTHOR );
			GommseBarTooltip:Show();
		end
	end
end

function GommseBarTooltip_OnLoad( self )
	self:SetOwner( UIParent, "ANCHOR_NONE" );
	self:SetPoint( "TOP", "GommseBarFrame", "BOTTOM", 0, 0 );
	self:SetBackdropBorderColor( TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b );
	self:SetBackdropColor( TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b ); 
end

function GommseBarTooltip_Show()
	GommseBarTooltip:SetOwner( UIParent, "ANCHOR_NONE" );

	if ( GommseBar_SavedVar.tooltip == 0 ) then
		return;
	elseif ( GommseBar_SavedVar.tooltip == 1 ) then
		GommseBarTooltip:SetPoint( "TOP", "GommseBarFrame", "BOTTOM", 0, 0 );
	elseif ( GommseBar_SavedVar.tooltip == 2 ) then
		GommseBarTooltip:SetPoint( "BOTTOM", "GommseBarFrame", "TOP", 0, 0 );
	end

	GommseBarTooltip:SetBackdropBorderColor( TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b );
	GommseBarTooltip:SetBackdropColor( 0, 0, 0 ); 
--	GommseBarTooltip:SetBackdropColor( TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b ); 

	GommseBarTooltip:SetText( "|cFF00FFFF"..GOMMSEBAR_NAME.." v"..GOMMSEBAR_VERSION.."\n\n" );

	GommseBarTooltip_AddProperty();
--	GommseBarTooltip_AddItemLevel();
	GommseBarTooltip_AddXP();
	GommseBarTooltip_AddReputation();
	GommseBarTooltip_AddENV();

	GommseBarTooltip:Show();
end

function GommseBarTooltip_Hide()
	if ( GommseBarTooltip:IsShown() ) then
		GommseBarTooltip:Hide();
	end
end

function GommseBarTooltip_AddProperty()
	GommseBarTooltip:AddLine( "자산" );
	GommseBarTooltip_AddBagSpace();
	GommseBarTooltip_AddMoney();
	GommseBarTooltip_AddRepairStatus();
--	GommseBarTooltip:AddLine( "\n" );
end

function GommseBarTooltip_AddBagSpace()
	local used	= 0;
	local total	= 0;

	for i = 0, 4 do
		local size = GetContainerNumSlots( i );

		for j = 1, size do
			if ( GetContainerItemInfo( i, j ) ) then
				used = used + 1;
			end
		end

		total = total + size;
	end

	local free = total - used;
	GommseBarTooltip:AddLine( "|cFFFFFFFF소지품: "..used.." / "..total );
end

function GommseBarTooltip_AddMoney()
	local money		= GetMoney();
	local moneyText	= "없음";

	if ( money > 0 ) then
		local gold   = floor( money / 10000 );
		local silver = floor( ( money - gold * 10000 ) / 100 );
		local copper = money - gold * 10000 - silver * 100;

		if ( gold == 0 ) then
			moneyText = silver.."s "..copper.. "c";
		else
			moneyText = gold.."g "..silver.."s "..copper.."c";
		end
	end

	GommseBarTooltip:AddLine( "|cFF00FF00소지금: "..moneyText );
end

function GommseBarTooltip_AddRepairStatus()
	local repairCostText = "없음";
	local tRepairCost = 0;
	local duraPer = 100;
	local duraVal = 0;
	local duraMax = 0;

	local SLOT_STATUS	= {};
	SLOT_STATUS[1]		= { slot = "Head" };
	SLOT_STATUS[2]		= { slot = "Shoulder" };
	SLOT_STATUS[3]		= { slot = "Chest" };
	SLOT_STATUS[4]		= { slot = "Waist" };
	SLOT_STATUS[5]		= { slot = "Legs" };
	SLOT_STATUS[6]		= { slot = "Feet" };
	SLOT_STATUS[7]		= { slot = "Wrist" };
	SLOT_STATUS[8]		= { slot = "Hands" };
	SLOT_STATUS[9]		= { slot = "MainHand" };
	SLOT_STATUS[10]		= { slot = "SecondaryHand" };
	SLOT_STATUS[11]		= { slot = "Ranged" };

	GommseBarRepairTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );

	for i = 1, 11 do
		local slotName	= SLOT_STATUS[i].slot.."Slot";
		local id		= GetInventorySlotInfo( slotName );

		-- 해당 슬롯의 아이템으로 툴팁을 설정.
		local hasItem, _, repairCost = GommseBarRepairTooltip:SetInventoryItem( "player", id );
		if ( hasItem ) then
			if ( repairCost ) then
				tRepairCost = tRepairCost + repairCost;
			end

			-- 툴팁에서 내구도 부분을 찾는다.
			for j = 1, 30 do
				local field = getglobal( "GommseBarRepairTooltipTextLeft"..j );
				if ( field ~= nil ) then
					local text = field:GetText();
					if ( text ) then
						local _, _, dVal, dMax = string.find( text, "^내구도 (%d+) / (%d+)$" );
						if ( dVal ) then
							duraVal = duraVal + tonumber( dVal );
							duraMax = duraMax + tonumber( dMax );
						end
					end
				end
			end
		end
	end

	if ( tRepairCost ) then
		local gold   = floor( tRepairCost / 10000 );
		local silver = floor( ( tRepairCost - gold * 10000 ) / 100 );
		local copper = tRepairCost - gold * 10000 - silver * 100;

		if ( gold == 0 ) then
			repairCostText = silver.."s "..copper.. "c";
		else
			repairCostText = gold.."g "..silver.."s "..copper.."c";
		end

		if ( gold == 0 ) and ( silver == 0 ) and ( copper == 0 ) then
			repairCostText = "없음";
		end
	end

	if ( duraVal ) then
		duraPer = ceil( duraVal / duraMax * 100 * 10 ) / 10;
	end

	GommseBarTooltip:AddLine( "|cFFFF0000수리비: "..repairCostText.." (내구도:"..duraPer.."%)" );
end

function GommseBarTooltip_AddXP()
	if( UnitLevel("player") == CHARACTER_MAX_LEVEL ) then
		return;
	end

	local curExp	= UnitXP( "player" );
	local maxExp	= UnitXPMax( "player" );
	local expPer	= ceil( curExp / maxExp * 100 * 10 ) / 10;
	local restExp	= GetXPExhaustion();

	local restText = "없음";
	if ( restExp ) then
		local restPer = floor( ( restExp * 100 ) / UnitXPMax( "player" ) );
		restText = restExp.." ("..restPer.."%)";
	end

	GommseBarTooltip:AddLine( "경험치" );
	GommseBarTooltip:AddLine( "|cFFFFFFFF현재 경험치: "..curExp.."/"..maxExp.." ("..expPer.."%)" );
	GommseBarTooltip:AddLine( "|cFF00FF00휴식 경험치: "..restText );
--	GommseBarTooltip:AddLine( "\n" );
end

function GommseBarTooltip_AddReputation()
	local idText	= { "매우 적대적", "적대적", "약간 적대적", "중립적", "약간 우호적", "우호적", "매우 우호적", "확고한 동맹" };
	local value		= nil;
	local maxVal	= nil;
	local id		= nil;
	local name		= nil;

	for i = 1, GetNumFactions() do
		local facName, desc, stdId, bottomVal, topVal, earnedVal, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo( i );
		if isWatched then
			value	= earnedVal - bottomVal;
			maxVal	= topVal - bottomVal;
			name	= facName;
			id		= stdId;
		end
	end

	if ( value ) then
		local valPer = ceil( value / maxVal * 1000 ) / 10;
		GommseBarTooltip:AddLine( "\n평판");
		GommseBarTooltip:AddLine( "|cFFFFFFFF".. name ..": ".. value .. "/" .. maxVal .." (".. valPer .."%) - ".. idText[id] );
	--	GommseBarTooltip:AddLine( "\n" );
	end
end

function GommseBarTooltip_AddENV()
	local netIn, netOut, latency = GetNetStats();

	local fps		= string.format( "%02dfps", GetFramerate() );
	local network	= string.format( "%dms", latency );
	local memory	= string.format( "%.2fMB", gcinfo() / 1024 );

	GommseBarTooltip:AddLine( "\n게임 환경" );
	GommseBarTooltip:AddLine( "|cFFFFFFFF"..fps.." / "..network.." / "..memory );
end

function GommseBar_GetItemLevel( unit )
	local slotName = {
		"Head","Neck","Shoulder","Back","Chest","Wrist",
		"Hands","Waist","Legs","Feet","Finger0","Finger1",
		"Trinket0","Trinket1","MainHand","SecondaryHand","Ranged","Ammo"
	};
	local total, item = 0, 0;

	for i in pairs(slotName) do
		local slot = GetInventoryItemLink(unit, GetInventorySlotInfo(slotName[i] .. "Slot"));
		if ( slot ~= nil ) then
			item = item + 1;
			total = total + select(4, GetItemInfo(slot))
		end
	end

	if ( item > 0 ) then
		return floor( total / item );
	end

	return 0;
end

function GommseBarTooltip_AddItemLevel()
	local level = GommseBar_GetItemLevel("player");
	GommseBarTooltip:AddLine( "\n아이템 레벨: |cFFFFFFFF"..level.." (착용)" );
end

function GommseBar_CollectGarbage()
	local old = gcinfo();

	collectgarbage( 'collect' );

	local new		= gcinfo();
	local erased	= old - new;

	GommseBar_Print( "누수 메모리 "..string.format( "%.2fMB", erased / 1024 ).." 가 정리되었습니다." );
end

function GommseBarStatusBar_OnLoad( self )
	self:RegisterEvent( "VARIABLES_LOADED" );
	self:RegisterEvent( "PLAYER_ENTERING_WORLD" );
	self:RegisterEvent( "PLAYER_XP_UPDATE" );
	self:RegisterEvent( "PLAYER_UPDATE_RESTING" );
	self:RegisterEvent( "UPDATE_FACTION" );

	self:SetFrameLevel( GommseBarFrame:GetFrameLevel() - 1 );
end

function GommseBarStatusBar_OnEvent( event )
	if ( GommseBar_CheckSavedVar() ) then
		GommseBarStatusBar_Update();
	end
end

function GommseBarStatusBar_ShowReputation()
	local curVal	= nil;
	local maxVal	= nil;
	local id		= nil;

	for i = 1, GetNumFactions() do
		local facName, desc, stdId, bottomVal, topVal, earnedVal, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo( i );
		if isWatched then
			curVal	= earnedVal - bottomVal;
			maxVal	= topVal - bottomVal;
			name	= facName;
			id		= stdId;
		end
	end

	if ( curVal ) then
		GommseBarStatusBar:SetMinMaxValues( 0, maxVal );
		GommseBarStatusBar:SetValue( curVal );

		if ( id <= 3 ) then
			GommseBarStatusBar:SetStatusBarColor( 1.0, 0.0, 0.0, 1.0 );	-- 적대 (빨간색)
		elseif ( id == 4 ) then
			GommseBarStatusBar:SetStatusBarColor( 1.0, 1.0, 0.0, 1.0 );	-- 중립 (노란색)
		else
			GommseBarStatusBar:SetStatusBarColor( 0.0, 1.0, 0.0, 1.0 );	-- 우호 (녹색)
		end

		return true;
	end

	return false;
end

function GommseBarStatusBar_ShowExp()
	if ( UnitLevel( "player" ) ~= CHARACTER_MAX_LEVEL ) then
		GommseBarStatusBar:SetMinMaxValues( 0, UnitXPMax( "player" ) );
		GommseBarStatusBar:SetValue( UnitXP( "player" ) );

		if( GetXPExhaustion() ) then
			GommseBarStatusBar:SetStatusBarColor( 0.0, 0.0, 1.0, 1.0 );
		else
			GommseBarStatusBar:SetStatusBarColor( 1.0, 0.0, 1.0, 1.0 );
		end

		return true;
	end

	return false;
end

function GommseBarStatusBar_Update()
	GommseBarStatusBar:SetStatusBarColor( 0.0, 0.0, 0.0, 0.0 );

	if( GommseBar_SavedVar.background == 1 ) then
		local isShowReputation = GommseBarStatusBar_ShowReputation();
		if ( not isShowReputation ) then
			GommseBarStatusBar_ShowExp();
		end
	elseif ( GommseBar_SavedVar.background == 2 ) then
		GommseBarStatusBar_ShowExp();
	elseif ( GommseBar_SavedVar.background == 3 ) then
		GommseBarStatusBar_ShowReputation();
	end
end
