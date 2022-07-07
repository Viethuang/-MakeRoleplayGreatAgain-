/**
 *  ให้ค่าประสบการณ์กับผู้เล่นพร้อมอัปเดต UI
 * @param {amount} เลขจำนวนเต็ม
 * ใช้ฟังก์ชั่น UpdatePlayerEXPBar ที่อยู่ใน ui.pwn
 */
#include <YSI_Coding\y_va>

#define WEB_SITE_FORUM "www.lsrp.com/forum"

static
    chat_msgOut[144];




new bool:IsAfk[MAX_PLAYERS char];
new AFKTimer[MAX_PLAYERS];
new AFKCount[MAX_PLAYERS];

hook OnPlayerUpdate(playerid)
{
    AFKTimer[playerid] = 3;
    return 1;
}

ptask @2PlayerTimer[1000](playerid)
{
    if(AFKTimer[playerid] > 0)
	{
		AFKTimer[playerid]--;
		if(AFKTimer[playerid] <= 0)
		{
			AFKTimer[playerid] = 0;
			AFKCount[playerid]=1;
			IsAfk{playerid} = true;
		}
		else IsAfk{playerid} = false;
        
	}
    else {
			AFKCount[playerid]++;
		}
    return 1;
}

/*ptask PlayerDonater[1000](playerid) 
{
	if(PlayerInfo[playerid][pDonater] && PlayerInfo[playerid][pDonaterTime] > 0)
	{
		if(!PlayerInfo[playerid][pDonaterTime])
		PlayerInfo[playerid][pDonaterTime]--;
		
	}
	return 1;
}*/

stock PlayerSpec(playerid, playerb)
{
	if(PlayerDrugUse[playerid] != -1)
	{
		KillTimer(PlayerDrugUse[playerid]);
		PlayerDrugUse[playerid] = -1;
		SendClientMessage(playerid, COLOR_LIGHTRED, "Trang thai cua ban khong phai la cua thuoc.");
	}

	new weapon[13][2];

	for(new i = 0; i < 13; i++)
	{
		GetPlayerWeaponData(playerid, i, weapon[i][0], weapon[i][1]);
		PlayerInfo[playerid][pWeapons][i] = weapon[i][0];
		PlayerInfo[playerid][pWeaponsAmmo][i] = weapon[i][1];

	}

	if(PlayerInfo[playerb][pSpectating] != INVALID_PLAYER_ID)
	{
		if(PlayerInfo[playerb][pSpectating] == playerid)
			return SendErrorMessage(playerid, "Ban khong the spec ban than!");
		
		PlayerSpec(playerid, PlayerInfo[playerb][pSpectating]);
		return 1;
	}

	if(GetPlayerState(playerb) == PLAYER_STATE_DRIVER || GetPlayerState(playerb) == PLAYER_STATE_PASSENGER)
	{
		new vehicleid = GetPlayerVehicleID(playerb);

		if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
		{
			GetPlayerPos(playerid, PlayerInfo[playerid][pLastPosX], PlayerInfo[playerid][pLastPosY], PlayerInfo[playerid][pLastPosZ]);
			
			PlayerInfo[playerid][pLastInterior] = GetPlayerInterior(playerid);
			PlayerInfo[playerid][pLastWorld] = GetPlayerVirtualWorld(playerid);
			//SendServerMessage(playerid, "ตอนนี้คุณกำลังส่องผู้เล่น %s  /specoff เพื่ออยุดส่อง", ReturnName(playerb));
		}
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerb));
		SetPlayerInterior(playerid, GetPlayerInterior(playerb));

		
		TogglePlayerSpectating(playerid, true); 
		PlayerSpectateVehicle(playerid, vehicleid);
			
		PlayerInfo[playerid][pSpectating] = playerb; 
		return 1;
	}
	else
	{	
		if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
		{
			GetPlayerPos(playerid, PlayerInfo[playerid][pLastPosX], PlayerInfo[playerid][pLastPosY], PlayerInfo[playerid][pLastPosZ]);
			
			PlayerInfo[playerid][pLastInterior] = GetPlayerInterior(playerid);
			PlayerInfo[playerid][pLastWorld] = GetPlayerVirtualWorld(playerid);
			//SendServerMessage(playerid, "ตอนนี้คุณกำลังส่องผู้เล่น %s  /specoff เพื่ออยุดส่อง", ReturnName(playerb));
		}
		
		SetPlayerInterior(playerid, GetPlayerInterior(playerb));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerb));
		
		TogglePlayerSpectating(playerid, true); 
		PlayerSpectatePlayer(playerid, playerb);
			
		PlayerInfo[playerid][pSpectating] = playerb; 
		return 1;
	}
}


stock GivePlayerExp(playerid, amount = 1) {
	PlayerInfo[playerid][pExp] += amount;

	new levelup = GetPlayerMaxEXP(playerid);

	if (PlayerInfo[playerid][pExp] >= levelup) {
		PlayerInfo[playerid][pExp] = levelup - PlayerInfo[playerid][pExp];
		PlayerInfo[playerid][pLevel]++;
	}

	#if defined USE_EXP_BAR
	UpdatePlayerEXPBar(playerid);
	#endif
}

/**

 * หากใส่ ! แปลว่า เข้าสู่ระบบแล้ว
 * หากไม่ใส่ ! แปลว่ายังไม่เข้าสู่ระบบ
 */
stock IsPlayerLogin(playerid)
{
	if(BitFlag_Get(gPlayerBitFlag[playerid], IS_LOGGED))
		return 0;

	if(!BitFlag_Get(gPlayerBitFlag[playerid], IS_LOGGED))
		return 1;

	return 1;
}

/**
 *  จัดรูปแบบตัวเลขให้เป็นในรูปของเงิน `,`
 * @param {number} เลขจำนวนเต็ม
 */
stock MoneyFormat(integer)
{
	new value[20], string[20];

	valstr(value, integer);

	new charcount;

	for(new i = strlen(value); i >= 0; i --)
	{
		format(string, sizeof(string), "%c%s", value[i], string);
		if(charcount == 3)
		{
			if(i != 0)
				format(string, sizeof(string), ",%s", string);
			charcount = 0;
		}
		charcount ++;
	}

	return string;
}

/**
 *  เรียกชื่อ Roleplay จากผู้เล่น ไม่มีขีดเส้นใต้ (Underscore)
 * @param {number} ไอดีผู้เล่น
 */
stock ReturnRealName(playerid, underScore = 0)
{
    new pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, MAX_PLAYER_NAME);

	if(!underScore)
	{		
		for (new i = 0, len = strlen(pname); i < len; i ++) if (pname[i] == '_') pname[i] = ' ';
	}
    return pname;
}

stock ReturnName(playerid, underScore = 0)
{
	new playersName[MAX_PLAYER_NAME + 2];
	GetPlayerName(playerid, playersName, sizeof(playersName)); 
	
	if(!underScore)
	{
		if(PlayerInfo[playerid][pMasked])
			format(playersName, sizeof(playersName), "[Mask %i_%i%i]", PlayerInfo[playerid][pMaskID][0], PlayerInfo[playerid][pMaskID][1], playerid); 
			
		else
		{
			for(new i = 0, j = strlen(playersName); i < j; i ++) 
			{ 
				if(playersName[i] == '_') 
				{ 
					playersName[i] = ' '; 
				} 
			} 
		}
	}
	return playersName;
}

stock ReturnDBIDName(dbid)
{
	new query[120], returnString[60];
	
	mysql_format(dbCon, query, sizeof(query), "SELECT char_name FROM characters WHERE char_dbid = %i", dbid); 
	new Cache:cache = mysql_query(dbCon, query);
	
	if(!cache_num_rows())
		returnString = "None";
		
	else
		cache_get_value_name(0, "char_name", returnString);
	
	cache_delete(cache);
	return returnString;
}


stock ReturnDate()
{
	new sendString[90], MonthStr[40], month, day, year;
	new hour, minute, second;
	
	gettime(hour, minute, second);
	getdate(year, month, day);
	switch(month)
	{
	    case 1:  MonthStr = "Thang 1";
	    case 2:  MonthStr = "Thang 2";
	    case 3:  MonthStr = "Thang 3";
	    case 4:  MonthStr = "Thang 4";
	    case 5:  MonthStr = "Thang 5";
	    case 6:  MonthStr = "Thang 6";
	    case 7:  MonthStr = "Thang 7";
	    case 8:  MonthStr = "Thang 8";
	    case 9:  MonthStr = "Thang 9";
	    case 10: MonthStr = "Thang 10";
	    case 11: MonthStr = "Thang 11";
	    case 12: MonthStr = "Thang 12";
	}
	
	format(sendString, 90, "Ngay %d %s Nam %d - Gio %02d:%02d:%02d", day,MonthStr, year, hour, minute, second);
	return sendString;
}

stock ReturnIP(playerid)
{
	new
		ipAddress[266];

	GetPlayerIp(playerid, ipAddress, sizeof(ipAddress));
	return ipAddress; 
}

/**
 *  ส่งข้อความไปยังผู้เล่นรอบ ๆ ตัวของไอดีผู้เล่นที่ระบุ
 * @param {number} ไอดีผู้เล่น
 * @param {float} ระยะทาง
 * @param {string} ข้อความ
 */
ProxDetector(playerid, Float:radius, const str[])
{
	new Float:posx, Float:posy, Float:posz;
	new Float:oldposx, Float:oldposy, Float:oldposz;
	new Float:tempposx, Float:tempposy, Float:tempposz;

	GetPlayerPos(playerid, oldposx, oldposy, oldposz);

	foreach (new i : Player)
	{
		if(GetPlayerInterior(playerid) == GetPlayerInterior(i) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
		{
			GetPlayerPos(i, posx, posy, posz);
			tempposx = (oldposx -posx);
			tempposy = (oldposy -posy);
			tempposz = (oldposz -posz);

			if (((tempposx < radius/16) && (tempposx > -radius/16)) && ((tempposy < radius/16) && (tempposy > -radius/16)) && ((tempposz < radius/16) && (tempposz > -radius/16)))
			{
				SendClientMessage(i, COLOR_GRAD1, str);
			}
			else if (((tempposx < radius/8) && (tempposx > -radius/8)) && ((tempposy < radius/8) && (tempposy > -radius/8)) && ((tempposz < radius/8) && (tempposz > -radius/8)))
			{
				SendClientMessage(i, COLOR_GRAD2, str);
			}
			else if (((tempposx < radius/4) && (tempposx > -radius/4)) && ((tempposy < radius/4) && (tempposy > -radius/4)) && ((tempposz < radius/4) && (tempposz > -radius/4)))
			{
				SendClientMessage(i, COLOR_GRAD3, str);
			}
			else if (((tempposx < radius/2) && (tempposx > -radius/2)) && ((tempposy < radius/2) && (tempposy > -radius/2)) && ((tempposz < radius/2) && (tempposz > -radius/2)))
			{
				SendClientMessage(i, COLOR_GRAD4, str);
			}
			else if (((tempposx < radius) && (tempposx > -radius)) && ((tempposy < radius) && (tempposy > -radius)) && ((tempposz < radius) && (tempposz > -radius)))
			{
				SendClientMessage(i, COLOR_GRAD5, str);
			}
		}
	}
	return 1;
}

/**
 *  ซิงค์สิทธิ์ผู้ดูแล
 * @param {number} ไอดีผู้เล่น
 */
syncAdmin(playerid) {
	switch(PlayerInfo[playerid][pAdmin]) {
		case 1: {
			PlayerInfo[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1;
		}
		case 2: {
			PlayerInfo[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2;
		}
		case 3: {
			PlayerInfo[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2 | CMD_ADM_3;
		}
		case 4: {
			PlayerInfo[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2 | CMD_ADM_3 | CMD_LEAD_ADMIN;
		}
		case 5: {
			PlayerInfo[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2 | CMD_ADM_3 | CMD_LEAD_ADMIN | CMD_MANAGEMENT;
		}
		case 6: {
			PlayerInfo[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2 | CMD_ADM_3 | CMD_LEAD_ADMIN | CMD_MANAGEMENT | CMD_DEV;
		}
		default: {
			PlayerInfo[playerid][pCMDPermission] = CMD_PLAYER;
		}
	}
}

/**
 *  ตรวจสอบสิทธิ์ระหว่าง Flags
 * @param {flags} ที่ต้องการเทียบ
 * @param {flags} ตัวเปรียบเทียบ
 */
stock isFlagged(flags, flagValue) {
    if ((flags & flagValue) == flagValue) {
        return true;
    }
    return false;
}


ptask FunctionPlayers[1000](playerid) 
{
	if (PlayerInfo[playerid][pAdminjailed] == true)
	{
		PlayerInfo[playerid][pAdminjailTime]--; 
			
		if(PlayerInfo[playerid][pAdminjailTime] < 1)
		{
			PlayerInfo[playerid][pAdminjailed] = false; 
			PlayerInfo[playerid][pAdminjailTime] = 0; 
				
			SendServerMessage(playerid, "Ban da duoc tha tu khoi Admin Jail");
				
			new str[128];
			format(str, sizeof(str), "%s da duoc tha ra Admin Jail.", ReturnName(playerid));
			SendAdminMessage(1, str);
			
			SetPlayerHealth(playerid, 100);
			SpawnPlayer(playerid);
		}
	}
	if (PlayerInfo[playerid][pArrest] == true)
	{
		PlayerInfo[playerid][pArrestTime]--; 
			
		if(PlayerInfo[playerid][pArrestTime] < 1)
		{
			PlayerInfo[playerid][pArrest] = false; 
			PlayerInfo[playerid][pArrestTime] = 0; 
			PlayerInfo[playerid][pArrestRoom] = 0;
			PlayerInfo[playerid][pArrestBy] = 0;
				
			SendServerMessage(playerid, "Ban da duoc ra tu.");

			SendFactionMessageToAll(1, 0x8D8DFFFF, "HQ-ARREST: %s da duoc ra tu.", ReturnName(playerid));

			SetPlayerHealth(playerid, 100);
			
			SpawnPlayer(playerid);
			CharacterSave(playerid);
		}
	}
	return 1;
}

stock PlayNearbySound(playerid, sound)
{
	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetPlayerPos(playerid, x, y, z);

	foreach (new i : Player) if (IsPlayerInRangeOfPoint(i, 15.0, x, y, z)) {
	    PlayerPlaySound(i, sound, x, y, z);
	}
	return 1;
}

stock ShowCharacterStats(playerid, playerb)
{
	// playerid = player's statistics;
	// playerb = player receiving stats;
	
	new 
		duplicate_key[20],
		business_key[20] = "Khong"
	;

	
	if(PlayerInfo[playerid][pDuplicateKey] == INVALID_VEHICLE_ID)
		duplicate_key = "ไม่มี";

	else format(duplicate_key, 32, "%d", PlayerInfo[playerid][pDuplicateKey]); 
	
	for(new i = 1; i < MAX_BUSINESS; i++)
	{
		if(!BusinessInfo[i][BusinessDBID])
			continue;
			
		if(BusinessInfo[i][BusinessOwnerDBID] == PlayerInfo[playerid][pDBID])
			format(business_key, 20, "%d", BusinessInfo[i][BusinessDBID]); 
	}

	GetPlayerHealth(playerid, PlayerInfo[playerid][pHealth]);
	GetPlayerArmour(playerid, PlayerInfo[playerid][pArmour]);
	
	SendClientMessageEx(playerb, COLOR_DARKGREEN, "|__________________%s [%s]__________________|", ReturnRealName(playerid, 0), ReturnDate());

	SendClientMessageEx(playerb, COLOR_GRAD2, "CHARACTER| Faction/Gang:[%s] Rank:[%s] Nghe nghiep:[%s] Mau:[%.2f] Giap:[%.2f]", ReturnFactionName(playerid), ReturnFactionRank(playerid), GetJobName(PlayerInfo[playerid][pCareer], PlayerInfo[playerid][pJob]), PlayerInfo[playerid][pHealth],PlayerInfo[playerid][pArmour]);
	SendClientMessageEx(playerb, COLOR_GRAD1, "Experience| Cap do:[%d] Kinh nghiem:[%d/%d] Gio choi:[%d gio]", PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pExp], ((PlayerInfo[playerid][pLevel]) * 4 + 2), PlayerInfo[playerid][pTimeplayed]);
	SendClientMessageEx(playerb, COLOR_GRAD2, "Weapon| Vu khi chinh:[%s] Dan:[%d] Vu khi phu:[%s] Dan:[%d]", ShowPlayerWeapons(playerid, 4), PlayerInfo[playerid][pGunAmmo][3], ShowPlayerWeapons(playerid, 3), PlayerInfo[playerid][pGunAmmo][2]);
	SendClientMessageEx(playerb, COLOR_GRAD1, "Storage Compartment|: So dien thoai:[%d] Radio:[%s] Channel:[%d] Khoi luong:[%s] Can chien:[%s]", PlayerInfo[playerid][pPhone], (PlayerInfo[playerid][pHasRadio] != true) ? ("ไม่มี") : ("มี"), PlayerInfo[playerid][pRadio][PlayerInfo[playerid][pMainSlot]], (PlayerInfo[playerid][pHasMask] != true) ? ("Khong") : ("Co"), ShowPlayerWeapons(playerid, 1));
	SendClientMessageEx(playerb, COLOR_GRAD2, "Tai San| Tien:[$%s] Ngan hang:[$%s] Luong:[$%s] Bitsamp:[%.5f]", MoneyFormat(PlayerInfo[playerid][pCash]), MoneyFormat(PlayerInfo[playerid][pBank]), MoneyFormat(PlayerInfo[playerid][pPaycheck]), PlayerInfo[playerid][pBTC]);
	SendClientMessageEx(playerb, COLOR_GRAD1, "Khac| Chia khoa xe du phong:[%s] Chia khoa doanh nghiep:[%s]  Chia khoa nha du phong:[%d] Chia khoa doanh nghiep du phong [%d]", duplicate_key, business_key, PlayerInfo[playerid][pHouseKey], PlayerInfo[playerid][pBusinessKey]);	

	if(PlayerInfo[playerid][pJob] == 4)
	{
		SendClientMessageEx(playerb, COLOR_GRAD1, "Khoang san| Quang chua che bien:[%d] Than:[%d] Sat:[%d] Dong:[%d] Kali Nitrat:[%d]", PlayerInfo[playerid][pOre], PlayerInfo[playerid][pCoal],PlayerInfo[playerid][pIron], PlayerInfo[playerid][pCopper], PlayerInfo[playerid][pKNO3]);
	}

	if(PlayerInfo[playerb][pAdmin])
	{
		SendClientMessageEx(playerb, COLOR_GRAD1, "For Admin| DBID:[%d] UCP:[%s (%d)] Interior:[%d] World:[%d]", PlayerInfo[playerid][pDBID], e_pAccountData[playerid][mAccName], e_pAccountData[playerid][mDBID], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
		
		SendClientMessageEx(playerb, COLOR_GRAD2, "Connection| IP:[%s] Lan cuoi online:[%s] Gio choi:[%d gio]", ReturnIP(playerid), ReturnLastOnline(playerid), PlayerInfo[playerid][pTimeplayed]);
		
		SendClientMessageEx(playerb, COLOR_GRAD1, "Misc| InsideProperty:[%i] InsideBusiness:[%i]", IsPlayerInHouse(playerid), IsPlayerInBusiness(playerid)); 
	}
	
	SendClientMessageEx(playerb, COLOR_DARKGREEN, "|__________________%s [%s]__________________|", ReturnRealName(playerid, 0), ReturnDate());
	return 1;
}


stock CompareStrings(const string[], const string2[])
{
	if(!strcmp(string, string2, true))
		return true;
	else
		return false;
}

stock ReturnLastOnline(playerid)
{
	new returnString[90]; 
	
	if(!PlayerInfo[playerid][pLastOnline])
		returnString = "Never";
	
	else
		format(returnString, 90, "%s", PlayerInfo[playerid][pLastOnline]);
	
	return returnString;
}

stock GetChannelSlot(playerid, chan)
{
	for(new i = 1; i < 3; i++)
	{
		if(PlayerInfo[playerid][pRadio][i] == chan)
			return i;
	}
	return 0; 
}

forward OnCallPaycheck(playerid, response);
public OnCallPaycheck(playerid, response)
{
	new
		str[128]
	;
	
	if(response)
	{
		format(str, sizeof(str), "%s nhan thong bao phieu luong.", ReturnName(playerid));
		SendAdminMessage(3, str);
		
		CallPaycheck(); 
	}
	return 1;
}

forward FunctionPaychecks();
public FunctionPaychecks()
{
	new 
		hour, 
		minute, 
		seconds
	;

	gettime(hour, minute, seconds); 
	
	if(minute == 00 && seconds == 59)
	{
		CallPaycheck(); 
		SetWorldTime(hour + 1);
	}
	
	return 1;
}

new Ticketnumber[][] = 
	{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};

forward CallPaycheck();
public CallPaycheck()
{
	foreach(new i : Player)
	{
		if(!BitFlag_Get(gPlayerBitFlag[i], IS_LOGGED))
			continue;
			
		new
			str[128],
			total_paycheck = 0
		; 
		
		new
			Float: interest,
			interest_convert,
			total_tax,
			Float:interest_saving
		;

		if(IsAfk{i}) 
		{
			if(AFKCount[i] > 120)
			{
				SendClientMessageEx(i, COLOR_LIGHTRED, "Ban da khong nhan duoc PayDay vi ban da AFK %s giay. Ban chi co the AFK toi da 120 giay.",MoneyFormat(AFKCount[i]));
				format(str, sizeof(str), "[%s] %s(DBID:%d) khong duoc nhan PayCheck [AFK]",ReturnDate(), ReturnRealName(i,0), PlayerInfo[i][pDBID]);
				SendDiscordMessageEx("khong-nhan-paycheck", str);
				continue;
			}
		}
		
		PlayerInfo[i][pTimeplayed]++; 
		PlayerInfo[i][pExp]++;
		
		if(PlayerInfo[i][pJob] == 4 && PlayerInfo[i][pJobRank] < 3)
			PlayerInfo[i][pJobExp]++;

		if(PlayerInfo[i][pJobExp] >= 25 && PlayerInfo[i][pJobRank] == 1)
		{
			PlayerInfo[i][pJobExp] = 0;
			PlayerInfo[i][pJobRank]++;
			SendClientMessage(i, COLOR_YELLOWEX, "Xin chuc mung, ban da thang tien trong su nghiep cua minh. Tho may cua ban la Tho sua xe.");
		}
		else if(PlayerInfo[i][pJobExp] >= 50 && PlayerInfo[i][pJobRank] == 2)
		{
			PlayerInfo[i][pJobExp] = 0;
			PlayerInfo[i][pJobRank]++;
			SendClientMessage(i, COLOR_YELLOWEX, "Xin chuc mung, ban da thang tien trong su nghiep cua minh. Tho may cua ban la nguoi cai.");
		}

		if(PlayerInfo[i][pExp] >= 6 && PlayerInfo[i][pLevel] == 1)
		{
			PlayerInfo[i][pExp] = 0;
			PlayerInfo[i][pLevel]++;
			format(str, sizeof(str), "~g~LEN CAP~n~~w~Ban da len cap %i.", PlayerInfo[i][pLevel]);
			GameTextForPlayer(i, str, 5000, 1);
			PlayerPlaySound(i, 1052, 0.0, 0.0, 0.0);
			SetPlayerScore(i, PlayerInfo[i][pLevel]); 
		}
		else if(PlayerInfo[i][pExp] >= 10 && PlayerInfo[i][pLevel] == 2)
		{
			PlayerInfo[i][pExp] = 0;
			PlayerInfo[i][pLevel]++;
			format(str, sizeof(str), "~g~LEN CAP~n~~w~Ban da len cap %i.", PlayerInfo[i][pLevel]);
			GameTextForPlayer(i, str, 5000, 1);
			PlayerPlaySound(i, 1052, 0.0, 0.0, 0.0);
			SetPlayerScore(i, PlayerInfo[i][pLevel]); 
		}
		
		if(PlayerInfo[i][pLevel] == 1)
			total_paycheck+= 200; 
			
		else if(PlayerInfo[i][pLevel] == 2)
			total_paycheck+= 100; 

		else if(PlayerInfo[i][pJob] == 3)
			total_paycheck+= 50;
			
		//Add an auto-level up on paycheck for level 1 and 2 to prevent paycheck farming.
		if(!PlayerInfo[i][pSaving])
		{
			interest_saving = 0.03;
			interest = PlayerInfo[i][pBank] * interest_saving;
		}
		else
		{
			if(PlayerInfo[i][pBank] >= 10000000)
			{
				PlayerInfo[i][pSaving] = false;
				SendClientMessage(i, COLOR_ORANGE, "Xin chuc mung, ban co so du tien gui tiet kiem. Dat den so tien quy dinh, ban co the rut tien tai ngan hang cua minh.");
			}

			interest_saving = 0.04;
			interest = PlayerInfo[i][pBank] * interest_saving; 
		}

		interest_convert = floatround(interest, floatround_round); 
	
		total_tax = floatround((PlayerInfo[i][pBank] * 0.035), floatround_round);
		
		SendClientMessageEx(i, COLOR_WHITE, "THOI GIAN - MAY CHU:[ %s ]", ReturnHour()); 
		
		SendClientMessage(i, COLOR_WHITE, "|___ NGAN HANG NHA NUOC ___|"); 
		SendClientMessageEx(i, COLOR_GREY, "Tien trong ngan hang: $%s.", MoneyFormat(PlayerInfo[i][pBank])); 
		SendClientMessageEx(i, COLOR_GREY, "Lai suat: %.2f.",interest_saving);
		SendClientMessageEx(i, COLOR_GREY, "Tien lai: $%s.", MoneyFormat(interest_convert));
		SendClientMessageEx(i, COLOR_GREY, "Thue: $%s.", MoneyFormat(total_tax)); 
		SendClientMessage(i, COLOR_WHITE, "|________________________|");
		
		PlayerInfo[i][pPaycheck]+= total_paycheck;

		PlayerInfo[i][pBank]+= interest_convert;
		//PlayerInfo[i][pBank]+= total_paycheck;
		PlayerInfo[i][pBank]-= total_tax;
		GlobalInfo[G_GovCash]+= floatround(total_tax, floatround_round);
		GlobalInfo[G_GovCash]-= floatround(total_paycheck, floatround_round);
		GlobalInfo[G_GovCash]-= floatround(interest_convert / 2, floatround_round);
		
		SendClientMessageEx(i, COLOR_WHITE, "Tien trong ngan hang: $%s.", MoneyFormat(PlayerInfo[i][pBank]));
		
		if(PlayerInfo[i][pLevel] == 1)
			SendClientMessage(i, COLOR_WHITE, "((Ban nhan duoc 200$ vi da len cap 1.))");
			
		else if(PlayerInfo[i][pLevel] == 2)
			SendClientMessage(i, COLOR_WHITE, "((Ban nhan duoc $100 vi da len cap 2.))");

		else if(PlayerInfo[i][pJob] == 3)
			SendClientMessage(i, COLOR_WHITE, "((Ban nhan duoc $50 vi da tro thanh mot tho co khi.))");
		
		format(str, sizeof(str), "~y~Payday~n~~w~Paycheck~n~~g~$%d.", total_paycheck);
		GameTextForPlayer(i, str, 3000, 1); 

		new randset[2];

		randset[0] = random(sizeof(Ticketnumber));
		randset[1] = random(sizeof(Ticketnumber)); 

		format(GlobalInfo[G_Ticket], 32,  "%s%s", Ticketnumber[randset[0]],Ticketnumber[randset[1]]);

		if(PlayerInfo[i][pTicket] == GlobalInfo[G_Ticket])
		{
			SendClientMessageEx(i, COLOR_GENANNOUNCE, "Ban da trung giai khi mua xo so %d ban da nhan duoc $200.",GlobalInfo[G_Ticket]);
			GiveMoney(i, 200);
			format(PlayerInfo[i][pTicket], PlayerInfo[i][pTicket],"");
		}
		SendClientMessageEx(i, COLOR_GREY, "Cac con xo so la: %s",  GlobalInfo[G_Ticket]);

		
		for(new h = 1; h < MAX_HOUSE; h++)
		{
			if(!HouseInfo[h][HouseDBID])
				continue;
			
			if(!HouseInfo[h][HouseOwnerDBID])
				continue;

			if(!HouseInfo[h][HouseRent])
				continue;
			
			if(HouseInfo[h][HouseRent] == PlayerInfo[i][pDBID])
			{
				GiveMoney(i, -HouseInfo[h][HouseRentPrice]);

				new total_tax_h = floatround(HouseInfo[h][HouseRentPrice] * 0.07,floatround_round);
				SendClientMessageEx(i, COLOR_LIGHTRED, "Tien thue nha cua ban: $%s",MoneyFormat(HouseInfo[h][HouseRentPrice]));
				
				if(HouseInfo[h][HouseOwnerDBID] == PlayerInfo[i][pDBID])
				{
					GiveMoney(i, HouseInfo[h][HouseRentPrice] - total_tax_h);
					SendClientMessageEx(i, COLOR_ORANGE,"Ban da nhan duoc tien thue nha: $%s",MoneyFormat(HouseInfo[h][HouseRentPrice] - total_tax_h));
				}
				else
				{
					AddPlayerCash(HouseInfo[h][HouseOwnerDBID], HouseInfo[h][HouseRentPrice] - total_tax_h);
				}
			}
			else
			{
				new total_tax_h = floatround(HouseInfo[h][HouseRentPrice] * 0.07,floatround_round);
				AddPlayerCash(HouseInfo[h][HouseRent], HouseInfo[h][HouseRentPrice] - total_tax_h);

				if(HouseInfo[h][HouseOwnerDBID] == PlayerInfo[i][pDBID])
				{
					GiveMoney(i, HouseInfo[h][HouseRentPrice] - total_tax_h);
					SendClientMessageEx(i, COLOR_ORANGE,"Ban nhan duoc tien thue nha: $%s",MoneyFormat(HouseInfo[h][HouseRentPrice] - total_tax_h));
				}
				else
				{
					AddPlayerCash(HouseInfo[h][HouseOwnerDBID], HouseInfo[h][HouseRentPrice] - total_tax_h);
				}
			}
		}
		

		DelevehicleVar();
		CharacterSave(i); 
		Saveglobal();		
	}

	new str[120];
	format(str, sizeof(str), "[%s] Paycheck Now",ReturnDate());
	SendDiscordMessageEx("paycheck-hour", str);
	return 1;
}

stock DelevehicleVar()
{
	new bool:respawn/*,query[MAX_STRING]*/;

	for(new v = 1; v < MAX_VEHICLES; v++) 
	{
		if(IsVehicleOccupied(v))
			continue;

		if(!VehicleInfo[v][eVehicleDBID])
			continue;

		if(VehicleInfo[v][eVehicleFaction])
			continue;

		if(VehicleInfo[v][eVehicleCarPark])
			continue;

			
		
		respawn = true;

		foreach (new i : Player) 
		{
				
            if(VehicleInfo[v][eVehicleOwnerDBID] == PlayerInfo[i][pDBID]) 
			{
				respawn = false;
                break;
            }
        }


		if (respawn) {
			/*mysql_format(dbCon, query, sizeof(query), "UPDATE `characters` SET `pVehicleSpawned` = '0',`pVehicleSpawnedID` = '0' WHERE `char_dbid` = '%d'",VehicleInfo[v][eVehicleOwnerDBID]);
         	mysql_tquery(dbCon, query);*/

			ResetVehicleVars(v);
			DestroyVehicle(v);
		}
	}
	return 1;
}
stock AddPlayerCash(charid, amount)
{
	new query[MAX_STRING], Money;
	
	mysql_format(dbCon, query, sizeof(query), "SELECT `pCash` FROM `characters` WHERE `char_dbid` = '%d'",charid);
	new Cache:cache = mysql_query(dbCon, query);
	
	if(!cache_num_rows())
		return 1;

	else
		cache_get_value_index_int(0, 0, Money);
	
	cache_delete(cache);

	mysql_format(dbCon, query, sizeof(query), "UPDATE `characters` SET `pCash` = '%d' WHERE `char_dbid` = '%d';",Money += amount, charid);
	mysql_tquery(dbCon, query);
	return 1;
}

stock ReturnHour()
{
	new time[36]; 
	
	gettime(time[0], time[1], time[2]);
	
	format(time, sizeof(time), "%02d:%02d", time[0], time[1]);
	return time;
}

stock ReturnLicenses(playerid, playerb)
{
	new
		driver_str[60],
		wep_str[60],
		truck_str[60],
		taxi_str[60]

	;
	
	if(!PlayerInfo[playerid][pDriverLicense])
		driver_str = "{FF6346}Giay phep lai xe : Khong";
		
	else if(PlayerInfo[playerid][pDriverLicenseRevoke]) 
		driver_str = "{FF6346}Giay phep lai xe : Co";
	
	else if(PlayerInfo[playerid][pDriverLicenseSus])
		driver_str = "{F1C40F}Giay phep lai xe : Co";

	else driver_str = "{E2FFFF}Giay phep lai xe : Khong";
	
	if(!PlayerInfo[playerid][pWeaponLicense])
		wep_str = "{FF6346}Giay phep su dung vu khi : Khong";

	else if(PlayerInfo[playerid][pWeaponLicenseRevoke])
		wep_str = "{F1C40F}Giay phep su dung vu khi : Co";
	
	else wep_str = "{E2FFFF}Giay phep su dung vu khi : Co";

	if(!PlayerInfo[playerid][pTuckingLicense])
		truck_str = "{FF6346}Giay phep xe tai : Khong";
		
	else if(PlayerInfo[playerid][pTuckingLicenseRevoke]) 
		truck_str = "{FF6346}Giay phep xe tai : Co";
	
	else if(PlayerInfo[playerid][pTuckingLicenseSus])
		truck_str = "{F1C40F}Giay phep xe tai : Co";

	else truck_str = "{E2FFFF}Giay phep xe tai : Co";

	if(!PlayerInfo[playerid][pTxaiLicense])
		taxi_str = "{FF6346}Giay phep xe TAXI : Khong";
		
	else if(PlayerInfo[playerid][pTxaiLicense]) 
		taxi_str = "{E2FFFF}Giay phep xe TAXI : Co";



	
	SendClientMessage(playerb, COLOR_DARKGREEN, "______Identification_______");
	SendClientMessageEx(playerb, COLOR_GRAD2, "Ten : %s", ReturnRealName(playerid, 0)); 
	SendClientMessageEx(playerb, COLOR_GRAD2, "%s", driver_str);
	SendClientMessageEx(playerb, COLOR_GRAD2, "%s", wep_str);
	SendClientMessageEx(playerb, COLOR_GRAD2, "%s", truck_str);
	SendClientMessageEx(playerb, COLOR_GRAD2, "%s", taxi_str);
	SendClientMessage(playerb, COLOR_DARKGREEN, "___________________________"); 
	return 1;
}


stock Player_IsNearPlayer(playerid, targetid, Float:radius)
{
	new
        Float:x,
        Float:y,
        Float:z;

	GetPlayerPos(playerid, x, y, z);

    new
        matchingVW = GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid),
        matchingInt = GetPlayerInterior(playerid) == GetPlayerInterior(targetid),
        inRange = IsPlayerInRangeOfPoint(targetid, radius, x, y, z);

	return matchingVW && matchingInt && inRange;
}


stock SendMsgLocal(playerid, Float:radius = 10.0, colour, const string[]) {
    SendClientMessage(playerid, colour, string);
    foreach(new i: StreamedPlayer[playerid])
    {
        if (Player_IsNearPlayer(playerid, i, radius))
        {
            SendClientMessage(i, colour, string);
        }
    }
	return 1;
}

stock SendMsgLocalEx(playerid, Float:radius = 15.0, colour, const fmat[], {Float,_}:...) {
    va_format(chat_msgOut, sizeof (chat_msgOut), fmat, va_start<4>);
    SendClientMessage(playerid, colour, chat_msgOut);
    foreach(new i: StreamedPlayer[playerid])
    {
        if (Player_IsNearPlayer(playerid, i, radius))
        {
			if(i == playerid)
				continue;

			SendClientMessage(i, colour, chat_msgOut);	
        }
    }
	return 1;
}


SetPlayerToFacePlayer(playerid, targetid)
{
	new
	    Float:px,
	    Float:py,
	    Float:pz,
	    Float:tx,
	    Float:ty,
	    Float:tz;

	GetPlayerPos(targetid, tx, ty, tz);
	GetPlayerPos(playerid, px, py, pz);
	SetPlayerFacingAngle(playerid, 180.0 - atan2(px - tx, py - ty));
	return 1;
}

stock GivePlayerHealth(playerid, Float:amount)
{
	new Float:health;
	GetPlayerHealth(playerid, health);
	SetPlayerHealth(playerid, health + amount);
	return 1;
}

stock GivePlayerArmour(playerid, Float:amount)
{
	new Float:armour;
	GetPlayerArmour(playerid, armour);
	SetPlayerArmour(playerid, armour + amount);
	return 1;
}

stock UpDateRadioStats(playerid)
{
	new str[120];

	new local = PlayerInfo[playerid][pMainSlot];
	new channel = PlayerInfo[playerid][pRadio][local];

	for(new r = 1; r < 3; r ++)
	{
		if(PlayerInfo[playerid][pRadio][r] == channel)
		{
			format(str, sizeof(str), "~b~RADIO:INFO~n~CH: ~g~%d~n~~b~SLOT: ~g~%d",PlayerInfo[playerid][pRadio][r], PlayerInfo[playerid][pMainSlot]);
			PlayerTextDrawSetString(playerid, RadioStats[playerid], str);
		}
	}
	return 1;
}

ChatAnimation(playerid, length)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && !PlayerInfo[playerid][pAnimation])
	{
		ApplyAnimation(playerid,"PED","IDLE_CHAT",4.1,1,0,0,1,1);
		SetTimerEx("StopChatting", floatround(length)*100, 0, "i", playerid);
	}
	return 1;
}

forward StopChatting(playerid);
public StopChatting(playerid) ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);



stock SetPlayerSpawn(playerid)
{

	if(!PlayerInfo[playerid][pTutorial])
	{
		SetPlayerCameraPos(playerid, 1450.2858,-912.3414,84.3133);
		SetPlayerCameraLookAt(playerid,1415.9854,-809.7775,75.7696, 0);
		SetPlayerPos(playerid, 1415.9854,-809.7775,75.7696);
		ShowDialogSpawn(playerid);
		return 1;
	}

    else if(PlayerInfo[playerid][pAdminjailed] == true)
    {
        SendClientMessageEx(playerid, COLOR_REDEX, "[ADMIN JAIL:] Thoi gian Admin Jail cua ban chua het, ban phai doi them %d giay nua.",PlayerInfo[playerid][pAdminjailTime]);
        ClearAnimations(playerid); 
	
        SetPlayerPos(playerid, 2687.3630, 2705.2537, 22.9472);
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 1338);
        SetPlayerWeapons(playerid);

        CharacterSave(playerid);
        StopAudioStreamForPlayer(playerid);
    }
    else if(PlayerInfo[playerid][pArrest] == true)
    {
        ArrestConecterJail(playerid, PlayerInfo[playerid][pArrestTime], PlayerInfo[playerid][pArrestRoom]);
        ClearAnimations(playerid);
        CharacterSave(playerid);
        StopAudioStreamForPlayer(playerid);
    }
    else if (PlayerInfo[playerid][pTimeout]) {

        // ตั้งค่าผู้เล่นให้กลับที่เดิมและสถานะบางอย่างเหมือนเดิม

        SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pLastWorld]);
        SetPlayerInterior(playerid, PlayerInfo[playerid][pLastInterior]);

        SetPlayerPos(playerid, PlayerInfo[playerid][pLastPosX], PlayerInfo[playerid][pLastPosY], PlayerInfo[playerid][pLastPosZ]);

        SetPlayerHealth(playerid, PlayerInfo[playerid][pHealth]);
        SetPlayerArmour(playerid, PlayerInfo[playerid][pArmour]);

        PlayerInfo[playerid][pTimeout] = 0;

        GameTextForPlayer(playerid, "~r~crashed. ~w~quay lai vi tri cuoi cung.", 1000, 1);
        StopAudioStreamForPlayer(playerid);

        new query[255];
		mysql_format(dbCon, query, sizeof(query), "SELECT * FROM `cache` WHERE C_DBID = '%d'",PlayerInfo[playerid][pDBID]);
		mysql_tquery(dbCon, query, "OnplayerCache", "d",playerid);
    }
    else if(PlayerInfo[playerid][pSpectating] != INVALID_PLAYER_ID)
    {
        SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pLastWorld]);
        SetPlayerInterior(playerid, PlayerInfo[playerid][pLastInterior]);

        SetPlayerPos(playerid, PlayerInfo[playerid][pLastPosX], PlayerInfo[playerid][pLastPosY], PlayerInfo[playerid][pLastPosZ]);
        PlayerInfo[playerid][pSpectating] = INVALID_PLAYER_ID;
        StopAudioStreamForPlayer(playerid);
        RemovePlayerWeapon(playerid, 1);
    }
    else 
    {
        switch (PlayerInfo[playerid][pSpawnPoint]) {
            case SPAWN_AT_DEFAULT: {
                SetPlayerVirtualWorld(playerid, 0);
                SetPlayerInterior(playerid, 0);
                SetPlayerPos(playerid, DEFAULT_SPAWN_LOCATION_X, DEFAULT_SPAWN_LOCATION_Y, DEFAULT_SPAWN_LOCATION_Z);
                SetPlayerFacingAngle(playerid, DEFAULT_SPAWN_LOCATION_A);
            }
            case SPAWN_AT_FACTION: {
                new id = PlayerInfo[playerid][pFaction];

                SetPlayerPos(playerid, FactionInfo[id][eFactionSpawn][0], FactionInfo[id][eFactionSpawn][1], FactionInfo[id][eFactionSpawn][2]-2);
                
                SetPlayerVirtualWorld(playerid, FactionInfo[id][eFactionSpawnWorld]);
                SetPlayerInterior(playerid, FactionInfo[id][eFactionSpawnInt]);
                TogglePlayerControllable(playerid, 0);
                SetTimerEx("SpawnFaction", 2000, false, "dd",playerid,id);
            }
            case SPAWN_AT_HOUSE: {
                
                new id = PlayerInfo[playerid][pSpawnHouse];

                SetPlayerVirtualWorld(playerid, HouseInfo[id][HouseInteriorWorld]);
                SetPlayerInterior(playerid, HouseInfo[id][HouseInteriorID]);
                SetPlayerPos(playerid, HouseInfo[id][HouseInterior][0], HouseInfo[id][HouseInterior][1], HouseInfo[id][HouseInterior][2]-2);
                TogglePlayerControllable(playerid, 0);
                SetTimerEx("OnPlayerEnterProperty", 2000, false, "ii", playerid, id); 

                PlayerInfo[playerid][pInsideProperty] = id;
            }
            case SPAWN_AT_LASTPOS: 
            {
                SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pLastWorld]);
        		SetPlayerInterior(playerid, PlayerInfo[playerid][pLastInterior]);

        		SetPlayerPos(playerid, PlayerInfo[playerid][pLastPosX], PlayerInfo[playerid][pLastPosY], PlayerInfo[playerid][pLastPosZ]);
            }

        }
    }

    new query[255];
	mysql_format(dbCon, query, sizeof(query), "DELETE FROM `cache` WHERE `C_DBID` = '%d'",PlayerInfo[playerid][pDBID]);
	mysql_tquery(dbCon, query);
    return 1;
}


stock ShowDialogSpawn(playerid)
{
	new str[255], longstr[255];

	format(str, sizeof(str), "Ganton Bus Stop\n");
	strcat(longstr, str);
	format(str, sizeof(str), "Idlewood Bus Stop\n");
	strcat(longstr, str);
	format(str, sizeof(str), "Jefferson Bus Stop\n");
	strcat(longstr, str);

	Dialog_Show(playerid, D_SET_SPAWN_START, DIALOG_STYLE_LIST, "Chom diem", longstr, "Xac nhan", "Huy");
	return 1;
}


Dialog:D_SET_SPAWN_START(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		SendClientMessage(playerid, COLOR_LIGHTRED, "Ban da khong chon diem xuat hien, ban da bi kick.");
		KickEx(playerid);
		return 1;
	}


	// ยังไม่ผ่านบทเรียน / ตัวละครใหม่
	PlayerInfo[playerid][pLevel] = 1;
	PlayerInfo[playerid][pCash] = DEFAULT_PLAYER_CASH;
		
	PlayerInfo[playerid][pTutorial] = true;
	SetCameraBehindPlayer(playerid);
	ShowPlayerGuid(playerid);
	
	switch(listitem)
	{
		case 0: //ganton
		{
			SendClientMessage(playerid, COLOR_YELLOWEX, "Ban da chon spawn o Ganton.");
			SetPlayerPos(playerid, 2279.3052,-1739.9686,13.5469);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerInterior(playerid, 0);
			ShowSkinModelMenu(playerid);
			return 1;
		}
		case 1: //Idlewood
		{
			SendClientMessage(playerid, COLOR_YELLOWEX, "Ban da chon spawn o Idlewood.");
			SetPlayerPos(playerid, 2036.2422,-1757.5090,13.5469);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerInterior(playerid, 0);
			ShowSkinModelMenu(playerid);
			return 1;
		}
		case 2: //Jefferson
		{
			SendClientMessage(playerid, COLOR_YELLOWEX, "Ban da chon spawn o Jefferson.");
			SetPlayerPos(playerid, 2202.2676,-1134.0295,25.7459);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerInterior(playerid, 0);
			ShowSkinModelMenu(playerid);
			return 1;
		}
	}
	return 1;
}


stock ShowPlayerGuid(playerid)
{
	new str[4000], longstr[4000];

	if(PlayerInfo[playerid][pInsideBusiness])
	{
		format(str, sizeof(str), "{45B39D}GUIED BUSINESS!!{FFFFFF}\n");
		strcat(longstr, str);
		format(str, sizeof(str), "\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Co nhieu loai hinh kinh doanh khac nhau trong thanh pho, moi loai hinh duoc xac dinh boi nguoi choi so huu doanh nghiep. Co quyen kinh doanh moi hoat dong kinh doanh.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Trong do doanh nghiep co cac hinh thuc, quy tac khac nhau va linh hoat theo cac loai hinh doanh nghiep. No co the hoi kho hieu, nhung toi tin rang no rat vui.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Va khong thua bat cu van de gi Co mot doanh nghiep, ban se luon co the lien he voi nguoi kiem duyet ve Doanh nghiep tren cac dien dan hoac kenh Discord,\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Se la nguoi huong dan ban mo cua kinh doanh ma moi doanh nghiep phai dua vao nguoi choi de dong cac vai tro khac nhau Tuy nhien, ban co the xem cac doanh nghiep khac ma ban dang o day de lam vi du.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Hoac ban luon co the tim kiem loi khuyen tu mot nguoi cham soc. Trong moi truong hop, chung toi chuc ban hanh phuc trong nganh kinh doanh ma ban mong muon.\n");
		strcat(longstr, str);
	}
	else if(PlayerInfo[playerid][pInsideProperty])
	{
		format(str, sizeof(str), "{45B39D}GUIED HOUSE!!{FFFFFF}\n");
		strcat(longstr, str);
		format(str, sizeof(str), "\n\n\n");
		strcat(longstr, str);
		format(str, sizeof(str), "That tot khi ban dang ban khoan ve no. Ve he thong Nha cai cua chung toi, bay gio chung toi co mot ngoi nha ma nguoi choi co the yeu cau mo ngay lap tuc. Chung toi se co cac vai tro khac nhau trong IC de nguoi choi lua chon choi.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Va yeu cau mo ban nha ban co the thuc hien mien phi ma khong can tra phi qua bat ky he thong OOC nao, neu ban la chu so huu ngoi nha thi ban se co nhieu quyen so huu ngoi nha cua chinh minh.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Sau do, ban co the kiem tra tat ca cac lenh lien quan den ngoi nha bang cach go /housecmds. Tat ca cac lenh lien quan den ngoi nha se duoc hien thi ngay lap tuc.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Neu ban co nha rieng, ban co the mang theo vu khi va giu chung o nha de tranh bi that lac. Hoac co the la bat ky loai thuoc nao.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "\n\n");
		strcat(longstr, str);
		format(str, sizeof(str), "{C0392B}Canh bao:{FFFFFF}\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Mot ngoi nha la thu ma moi nguoi choi nen co de nhap vai va la noi luu tru vu khi cua chung ta hoac moi thu khac. Va neu ban co mot ngoi nha, ganh nang chi tra Tien dien se tang theo muc su dung.\n");
		strcat(longstr, str);
	}
	else if(IsPlayerInAnyVehicle(playerid))
	{
		format(str, sizeof(str), "{45B39D}GUIED VEHICLE!!{FFFFFF}\n");
		strcat(longstr, str);
		format(str, sizeof(str), "\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Bay gio ban dang o trong xe cho du chiec xe nay co phai la cua ban hay khong, nhung dieu quan trong la ban khong nen su dung no theo cach pha vo cac quy tac may chu.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Viec lai bat ky phuong tien nao cung nen duoc coi la Lai xe nhap vai. Chung toi khong co nghia la ban tuan theo giao thong, ma chung toi muon noi den viec dieu khien phuong tien thuc te.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Boi vi chang ai lai lay mot chiec xe hang sang de lai tren nhung con doc cao hay ngon nui nao ca. Dieu khien mot chiec xe, chung ta nen nghi ve phan than cua moi chiec xe. Va nen su dung no de co loi cho no.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Nhung gi ban nen lam neu xe cua ban bi hong la lien he voi mot tho co khi dia phuong. Hoac lam bat cu dieu gi can thiet de co nhieu RP nhat.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "De xem cac lenh ve xe hay su dung '/v(ehicle)'.\n");
		strcat(longstr, str);
	}
	else
	{
		format(str, sizeof(str), "{229954}Chao mung %s!{FFFFFF}\n", ReturnRealName(playerid));
		strcat(longstr, str);
		format(str, sizeof(str), "Truoc het, chao mung ban den voi Los Santos. Ban co phai la nguoi choi moi khong?\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Day la mot mo phong cuoc song o thanh pho Los Santos duoc mo phong theo thanh pho Los Angeles cua Hoa Ky.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "\n\n");
		strcat(longstr, str);
		format(str, sizeof(str), "{D35400}Story Line .1{FFFFFF}\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Ban co $5.000 trong tui. Tot nhat ban nen su dung no mot cach tiet kiem vi ban se danh no cho su thang tien trong su nghiep cua minh.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Trong do thanh pho cua chung toi co mot su nghiep nho cho nguoi choi thuong thuc ma khong can phai canh tranh voi nhieu thoi gian. Ma nguoi choi tieu tien\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Moi lan co mot he thong thue cho doi tien de lam viec trong su nghiep cua moi nghe nghiep. Tat ca nguoi choi duoc yeu cau su dung tien cua ho mot cach than trong.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "\n\n");
		strcat(longstr, str);
		format(str, sizeof(str), "{D35400}Story Line .2{FFFFFF}\n");
		strcat(longstr, str);
		format(str, sizeof(str), "Cac may chu cua phien ban Roleplay co the khong nhieu nguoi thich, muon vao choi thi co the vao choi nhung phai tuan theo quy dinh cua chung toi.\n");
		strcat(longstr, str);
		format(str, sizeof(str), "duoc them vao may chu co thee xem tren web %s\n", WEB_SITE_FORUM);
		strcat(longstr, str);
	}

	Dialog_Show(playerid, DEFAULT_DIALOG, DIALOG_STYLE_MSGBOX, "Player Guide", longstr, "Xac nhan", "");
	return 1;
}