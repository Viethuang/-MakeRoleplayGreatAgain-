#include <YSI_Coding\y_hooks>

static
    loginAttempt[MAX_PLAYERS], 
    g_MysqlRaceCheck[MAX_PLAYERS];

hook OnPlayerDisconnect(playerid, reason) {
	loginAttempt[playerid]=0;
	g_MysqlRaceCheck[playerid]++;
    return 1;
}

forward OnPlayerJoin(playerid);
public OnPlayerJoin(playerid)
{
	new rows;
	cache_get_value_index_int(0, 0, rows);
	if(rows) Auth_Login(playerid);
	else Auth_Register(playerid);
	return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
	SendClientMessage(playerid, COLOR_YELLOW2, "Ban da dang ky! Gio hay nhap mat khau de dang nhap");
    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Dang Nhap", "%s ! Hay nhap mat khau de dang nhap", "Dang Nhap", "Thoat", ReturnPlayerName(playerid));
	return 1;
}

forward OnPlayerLogin(playerid/*, race_check*/);
public OnPlayerLogin(playerid/*, race_check*/)
{
	/*if (race_check != g_MysqlRaceCheck[playerid]) 
		return Kick(playerid);*/

	new pPass[129], unhashed_pass[129];
	GetPVarString(playerid, "Unhashed_Pass",unhashed_pass, 129);
	if(cache_num_rows())
	{
		cache_get_value_index(0, 0, pPass, 129);
		cache_get_value_index_int(0, 1, e_pAccountData[playerid][mDBID]);
        cache_get_value_index(0, 2, e_pAccountData[playerid][mAccName], 60);
		cache_get_value_index(0, 3, e_pAccountData[playerid][mForumName], 60);
		
        if (strequal(unhashed_pass, pPass, true)) {
            DeletePVar(playerid, "Unhashed_Pass");

            cache_get_value_name_int(0, "admin", PlayerInfo[playerid][pAdmin]);
            ShowCharacterSelection(playerid);

        }
        else {



			if(loginAttempt[playerid] == DEFAULT_PLAYER_LOGIN_ATTEMPT) {
				SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: "EMBED_WHITE"Ban da nhap sai mat khau qua nhieu. -Kick-");
				KickEx(playerid);
				return 1;
			}
			loginAttempt[playerid]++;
			
			Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Dang Nhap",""EMBED_RED"ERROR:"EMBED_DIALOG" Mat khau khong dung\n\n"EMBED_DIALOG"Nhap mat khau de dang nhap:\n\n"EMBED_RED"LOI DANG NHAP (%d/%d)","Dang Nhap","Thoat", DEFAULT_PLAYER_LOGIN_ATTEMPT - loginAttempt[playerid], DEFAULT_PLAYER_LOGIN_ATTEMPT);
		}
	}
    else {
        printf("ERROR: %s khong the log-in", ReturnPlayerName(playerid));
    }
	return 1;
}

Auth_Login(playerid) {
    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Dang Nhap", "Xin chao, %s\n\Hay nhap mat khau de dang nhap:", "Dang Nhap", "Thoat", ReturnPlayerName(playerid));
    return 1;
}

Auth_Register(playerid) {

	#if defined IN_GAME_REGISTER

    	Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", "Tai khoan nay chua ton tai hay nhap mat khau de dang ky", "Register", "Thoat");

	#else

		SendClientMessageEx(playerid, COLOR_LIGHTRED, "ERROR: "EMBED_WHITE"Khong tim thay ten tai khoan %s", ReturnPlayerName(playerid));
		SendClientMessage(playerid, COLOR_LIGHTRED, "[ ! ] "EMBED_WHITE"Dam bao rang ten tai khoan (MasterAccount) khong phai la ten nhan vat");
		SendClientMessage(playerid, COLOR_LIGHTRED, "[ ! ] "EMBED_WHITE"De tao tai khoan, truy cap http://lsrp.com/");
		KickEx(playerid);

	#endif

    return 1;
}

timer ShowLoginCamera[400](playerid)
{
	SetPlayerCameraPos(playerid, 2071.6313,-1828.9207,23.3445);
	SetPlayerCameraLookAt(playerid, 2096.2373,-1794.2494,13.3889);
	return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
    if (!response)
        Kick(playerid);

    new query[128], buf[129];

    WP_Hash(buf, sizeof (buf), inputtext);
    SetPVarString(playerid, "Unhashed_Pass",buf);

	//g_MysqlRaceCheck[playerid]++;
    mysql_format(dbCon, query, sizeof(query), "SELECT acc_pass, acc_dbid, acc_name, forum_name, admin from `masters` WHERE acc_name = '%e'", ReturnPlayerName(playerid));
    mysql_tquery(dbCon, query, "OnPlayerLogin", "i", playerid/*,g_MysqlRaceCheck[playerid]*/);

    return 1;
}

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
    if (!response)
        Kick(playerid);

    new
        buf[129];

    WP_Hash(buf, sizeof (buf), inputtext);

    new query[256];
    mysql_format(dbCon, query, sizeof(query), "INSERT INTO `masters` (`acc_name`, `acc_pass`) VALUES('%s', '%e')", ReturnPlayerName(playerid), buf);
	mysql_tquery(dbCon, query, "OnPlayerRegister", "d", playerid);

    return 1;
}

Dialog:DIALOG_SET_USERNAME(playerid, response, listitem, inputtext[])
{
	if (!response)
        Kick(playerid);
	
	if(strlen(inputtext) < 1 || strlen(inputtext) > 90)
		return Dialog_Show(playerid, DIALOG_SET_USERNAME, DIALOG_STYLE_INPUT, "Nhap Username ma ban muon", "Ban da nhap ten Username, khong duoc it hon 1 hoac nhieu hon 90 ky tu, vui long nhap lai:", "Xac nhan", "Huy");

	new maxusername = strlen(inputtext);

	for(new i=0; i<maxusername; i++)
	{
		if(inputtext[i] == '_')
		{
			return Dialog_Show(playerid, DIALOG_SET_USERNAME, DIALOG_STYLE_INPUT, "Nhap Username ma ban muon", "Dung dat dau '_' vao username", "Xac nhan", "Huy");
		}
	}
	SetPlayerName(playerid, inputtext);

	new existCheck[129];
	
	mysql_format(dbCon, existCheck, sizeof(existCheck), "SELECT COUNT(acc_name) FROM `masters` WHERE acc_name = '%e'", ReturnPlayerName(playerid));
	mysql_tquery(dbCon, existCheck, "OnPlayerJoin", "d", playerid);
	return 1;
}