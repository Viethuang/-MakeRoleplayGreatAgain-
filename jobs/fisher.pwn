
#include <YSI_Coding\y_hooks>

#define DELIVERY_FISH_X     2475.2932
#define DELIVERY_FISH_Y     -2710.7759
#define DELIVERY_FISH_Z     3.1963

new FishingPlace[MAX_PLAYERS];
new FishingCP[MAX_PLAYERS];
new FishingBoat[MAX_PLAYERS];

new const Float:GoFishingPlace[3][3] = {
	{813.6824,-2248.2407,-0.4488},
	{407.6824,-2318.2407,-0.5752},
	{-25.9471,-1981.9995,-0.6268}
};

new const FishNames[] = {
	"Ca ngu",
	"Ca hoi",
	"Ca kiem",
	"Ca chinh",
	"Ca map",
    "Ca chim",
    "Ca mieng dai",
    "ปลากระทุงเหวบั้ง",
    "ปลากระทุงเหวหูดำ",
    "ปลากระบอกท่อนใต้",
    "ปลากระบอกปีกเหลือง",
    "ปลากระเบนจมูกแหลม",
    "ปลากระเบนนก",
    "ปลากระเบนแมลงวัน",
    "ปลากะตักใหญ่",
    "ปลากะโทงแทงกล้วย",
    "ปลากะพงข้างเหลือง",
    "ปลากะพงขาว",
    "ปลากะพงเขียว",
    "ปลากะพงแดงเกล็ดห่าง",
    "ปลากะพงแดงข้างแถว",
    "ปลากะพงแดงหน้าตั้ง",
    "ปลากะพงแดงสั้นหางปาน",
    "ปลากะพงปานข้างลาย",
    "ปลากะพงแสม",
    "ปลากะรังแดงจุดฟ้า",
    "ปลากุเราสี่เส้น",
    "ปลากุแลกล้วย",
    "ปลาเก๋าดอกหางตัด",
    "ปลาเก๋าแดง",
    "ปลาเก๋าจุดน้ำตาล",
    "ปลาเก๋าบั้งแฉก",
    "ปลาเก๋าหางซ้อน",
    "ปลาแข้งไก่",
    "ปลาคลุด",
    "ปลางัวใหญ่หางตัด",
    "ปลาจวดเตียนเขี้ยว",
    "ปลาจะละเม็ดขาว",
    "ปลาจะละเม็ดดำ",
    "ปลาจะละเม็ดดำ",
    "ปลาจาน",
    "ปลาฉลามหัวค้อนสั้น",
    "ปลาเฉลียบ",
    "ปลาช่อนทะเล",
    "ปลาซ่อนทรายแก้ว",
    "ปลาดอกหมากกระโดง",
    "ปลาดอกหมากครีบยาว",
    "ปลาดาบลาวยาว",
    "ปลาดาบเงินใหญ่",
    "ปลาดุกทะเล",
    "ปลาตะคองเหลือง",
    "ปลาตะเพียนน้ำเค็ม",
    "ปลาตะลุมพุก",
    "ปลาตาหวานจุด",
    "ปลาทรายขาวหูแดง",
    "ปลาทรายแดงกระโดง"
};

hook OnPlayerConnect(playerid) {
    FishingCP[playerid] = 0;
    FishingPlace[playerid] = -1;
    FishingBoat[playerid] = 0;
}

CMD:fishhelp(playerid, params[])
{
    SendClientMessage(playerid, COLOR_DARKGREEN,"_______________________________________");
	SendClientMessage(playerid, COLOR_GRAD3,"/myfish /gofishing /fish /stopfishing /unloadfish");
	return 1;
}

CMD:gofishing(playerid, params[]) {

    new place;
	if(sscanf(params,"i", place)) {
        SendClientMessage(playerid, COLOR_GRAD1, "SU DUNG: /gofishing [1 (tren thuyen) / 2 (tren cau)]");
        return 1;
    }

    if (FishingPlace[playerid] != -1) {
        return SendClientMessage(playerid, COLOR_LIGHTRED, "Checkpoint dang bat");
    }

    if (place == 1) {

        new vehicleid = GetPlayerVehicleID(playerid);
        if (vehicleid == INVALID_VEHICLE_ID || !IsABoat(vehicleid)) {
            SendClientMessage(playerid, COLOR_LIGHTRED, "Ban phai o trong/gan thuyen de su dung.");
            return 1;
        }
        else {
            vehicleid = GetNearestVehicle(playerid);
            if (vehicleid == INVALID_VEHICLE_ID || !IsABoat(vehicleid)) {
                SendClientMessage(playerid, COLOR_LIGHTRED, "Ban phai o trong/gan thuyen de su dung.");
                return 1;
            }
        }

        if(PlayerInfo[playerid][pFishes] > 5000) {
            SendClientMessage(playerid, COLOR_DARKGREEN, "Ban da day ca.");
            SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish neu ban muon ban ca.");
            return 1;
        }

        new rand = random(sizeof(GoFishingPlace));
        if (IsPlayerInRangeOfPoint(playerid, 30.0, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2])) {
            FishingPlace[playerid] = 1;
            SendClientMessage(playerid, COLOR_WHITE, "Su dung (/fish)- de danh ca | Su dung /stopfishing - de dung cau ca | Su dung /unloadfish - de ban ca.");
            DisablePlayerCheckpoint(playerid);
        }
        else {
            SetPlayerCheckpoint(playerid, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2], 30.0);
            SendClientMessage(playerid, COLOR_DARKGREEN, "Di den diem cau ca de cau ca (/fish).");
        }
        
        FishingCP[playerid] = rand + 1;
        return 1;
    }
    else if (place == 2) {

	    if(PlayerInfo[playerid][pFishes] > 1000) {
	        SendClientMessage(playerid, COLOR_DARKGREEN, "Ban da day ca.");
	        SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish neu ban muon ban ca.");
            return 1;
	    }

        if (!IsPlayerInRangeOfPoint(playerid, 30.0, 383.6021,-2061.7881,7.6140))
        {
            SetPlayerCheckpoint(playerid, 383.6021,-2061.7881,7.6140, 30.0);
            SendClientMessage(playerid, COLOR_DARKGREEN, "Di den diem cau ca de cau ca (/fish).");
        }
        else 
        {
            FishingPlace[playerid] = 2;
            SendClientMessage(playerid, COLOR_WHITE, "Su dung (/fish)- de danh ca | Su dung /stopfishing - de dung cau ca | Su dung /unloadfish - de ban ca.");
        }
        FishingCP[playerid] = sizeof(GoFishingPlace) + 1;
        return 1;
    }
    else {
        SendClientMessage(playerid, COLOR_GRAD1, "SU DUNG: /gofishing [1 (tren thuyen) / 2 (tren cau)]");
    }
    return 1;
}

hook OnPlayerEnterCheckpoint(playerid) {
    if (FishingCP[playerid] != 0) {
        if (FishingCP[playerid] <= sizeof(GoFishingPlace)) { // เรือ
            new rand = FishingCP[playerid]-1;
            if (IsPlayerInRangeOfPoint(playerid, 30.0, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2])) {
                FishingPlace[playerid] = 1;

                SendClientMessage(playerid, COLOR_WHITE, "Su dung (/fish)- de danh ca | Su dung /stopfishing - de dung cau ca | Su dung /unloadfish - de ban ca.");
                DisablePlayerCheckpoint(playerid);
            }
        }
        else {
            if (IsPlayerInRangeOfPoint(playerid, 30.0, 383.6021,-2061.7881,7.6140)) { // สะพาน LS
                FishingPlace[playerid] = 2;

                SendClientMessage(playerid, COLOR_WHITE, "Su dung (/fish)- de danh ca | Su dung /stopfishing - de dung cau ca | Su dung /unloadfish - de ban ca.");
                DisablePlayerCheckpoint(playerid);
            }
            else if (IsPlayerInRangeOfPoint(playerid, 2.5, DELIVERY_FISH_X,DELIVERY_FISH_Y,DELIVERY_FISH_Z) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) { // ขายปลา LS
                new earn = PlayerInfo[playerid][pFishes] + random(floatround(PlayerInfo[playerid][pFishes]/5));
  
                new Float:tax = earn * 0.07;
                GiveMoney(playerid, earn - floatround(tax, floatround_round));
                GlobalInfo[G_GovCash]+=floatround(tax, floatround_round);
                GameTextForPlayer(playerid, sprintf("~p~BAN CA VOI SO LUONG ~w~%d - BAN DA NHAN DUOC %d", PlayerInfo[playerid][pFishes], earn - floatround(tax, floatround_round)), 8000, 4);

                PlayerInfo[playerid][pFishes] = 0;
                FishingCP[playerid] = 0;
                DisablePlayerCheckpoint(playerid);
            }
        }
        return -2; // หยุด Callback อื่น
    }
    return 1;
}

CMD:stopfishing(playerid, params[]) {
	if(FishingPlace[playerid] != -1)
	{
	    SendClientMessage(playerid, COLOR_DARKGREEN, "Ban da dung cau ca.");

	    if(PlayerInfo[playerid][pFishes]) 
            SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish de ban ca.");

	    FishingPlace[playerid]=-1;
        FishingCP[playerid] = 0;
	}
	else SendClientMessage(playerid, COLOR_WHITE, "Ban khong cau ca.");
	return 1;
}

CMD:unloadfish(playerid, params[]) {

    if(FishingPlace[playerid] != -1)
		return SendClientMessage(playerid, COLOR_LIGHTRED, "Ngung cau ca truoc /stopfishing.");

	if(PlayerInfo[playerid][pFishes])
	{
	    SendClientMessage(playerid, COLOR_DARKGREEN, "Dia diem ban ca da duoc danh dau tren ban do.");
        SetPlayerCheckpoint(playerid, DELIVERY_FISH_X,DELIVERY_FISH_Y,DELIVERY_FISH_Z, 2.0);
        FishingCP[playerid] = sizeof(GoFishingPlace) + 1;

	} else SendClientMessage(playerid, COLOR_LIGHTRED, "Ban khong co ca de ban.");
	
    return 1;
}

CMD:myfish(playerid, params[]) {
	if(PlayerInfo[playerid][pFishes])
	{
	    SendClientMessage(playerid, COLOR_DARKGREEN, "_______________________________________");
	    SendClientMessageEx(playerid, COLOR_DARKGREEN, "Trong luong ca [%d kg]", PlayerInfo[playerid][pFishes]);
	} 
    else SendClientMessage(playerid, COLOR_LIGHTRED, "Ban khong co ca.");
	
    return 1;
}

CMD:fish(playerid, params[]) {

	if(FishingPlace[playerid] != -1) {
		if(!HasCooldown(playerid,COOLDOWN_FISHING))
		{
            new Fishcaught, Fishlbs;
            SetCooldown(playerid,COOLDOWN_FISHING, 6);

            if (FishingCP[playerid] != 0) {
                if (FishingCP[playerid] <= sizeof(GoFishingPlace)) { // เรือ
                    new rand = FishingCP[playerid]-1;
                    if (IsPlayerInRangeOfPoint(playerid, 30.0, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2])) {
                          
                        new vehicleid = GetPlayerVehicleID(playerid);
                        if (vehicleid == INVALID_VEHICLE_ID || !IsABoat(vehicleid)) {
                            SendClientMessage(playerid, COLOR_LIGHTRED, "Ban phai o trong/gan thuyen de su dung.");
                            return 1;
                        }
                        else {
                            vehicleid = GetNearestVehicle(playerid);
                            if (vehicleid == INVALID_VEHICLE_ID || !IsABoat(vehicleid)) {
                                SendClientMessage(playerid, COLOR_LIGHTRED, "Ban phai o trong/gan thuyen de su dung.");
                                return 1;
                            }
                        }

                        if(random(6) >= 5)
                            return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ban khong bat duoc thu gi.");
    
                        Fishcaught = random(55);

                        if(FishingPlace[playerid] != 1) Fishlbs = ((Fishcaught+1)*10) + (1 + random(10));
                        else Fishlbs = ((Fishcaught+1)*20) + (1 + random(10));

                        SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "> %s can cau da duoc thu lai va thay chung da bat duoc %s.", ReturnRealName(playerid), FishNames[Fishcaught]);
                        SendClientMessageEx(playerid, COLOR_DARKGREEN, "Ban da bat duoc %s - Trong luong %d kg", FishNames[Fishcaught], Fishlbs);
        
                        PlayerInfo[playerid][pFishes]+=Fishlbs;

                        if(PlayerInfo[playerid][pFishes] > 1000)
                        {
                            FishingPlace[playerid]=-1;

                            SendClientMessage(playerid, COLOR_DARKGREEN, "Ban da day ca.");
                            SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish de ban ca.");
                            return 1;
                        }

                        FishingBoat[playerid]+=Fishlbs;

                        if(FishingBoat[playerid] > 1000) {
                            rand = random(sizeof(GoFishingPlace));
                            SetPlayerCheckpoint(playerid, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2], 30.0);
                            FishingCP[playerid] = rand + 1;
                            FishingBoat[playerid]=0;
                            FishingPlace[playerid]=-1;
                            SendClientMessage(playerid, COLOR_DARKGREEN, "Di cau ca o mot noi khac.");
                        }
                    }
                    else SendClientMessage(playerid, COLOR_LIGHTRED, "Ban khong the cau ca o day.");
                }
                else {
                    if (IsPlayerInRangeOfPoint(playerid, 30.0, 383.6021,-2061.7881,7.6140)) { // สะพาน
                        if(random(7) >= 55)
                            return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ban khong bat duoc thu gi.");
    
                        Fishcaught = random(55);

                        if(FishingPlace[playerid] != 1) Fishlbs = ((Fishcaught+1)*10) + (1 + random(10));
                        else Fishlbs = ((Fishcaught+1)*20) + (1 + random(10));

                        SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "> %s luoi da thu lai va nhan thay luoi da cau duoc %s.", ReturnRealName(playerid), FishNames[Fishcaught]);
                        SendClientMessageEx(playerid, COLOR_DARKGREEN, "Ban da bat duoc %s - Trong luong %d kg.", FishNames[Fishcaught], Fishlbs);

                        PlayerInfo[playerid][pFishes]+=Fishlbs;

                        if(PlayerInfo[playerid][pFishes] > 100)
                        {
                            FishingPlace[playerid]=-1;
                            SendClientMessage(playerid, COLOR_DARKGREEN, "Ban da day ca.");
                            SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish de ban ca.");
                            return 1;
                        }
                    }
                    else SendClientMessage(playerid, COLOR_LIGHTRED, "Ban khong the cau ca o day.");

                }
            }
		}
		else {
			SendClientMessage(playerid, COLOR_LIGHTRED, "Khong co ca xng quanh.");
			SendClientMessage(playerid, COLOR_WHITE, "((Vui long doi 6 giay de co the su dung lai /fish))");
		}
	}
	else
	{
	    SendClientMessage(playerid, COLOR_LIGHTRED, "Ban khong co ca.");
	}
	return 1;
}

static IsABoat(vehicleid)
{
    new model = GetVehicleModel(vehicleid);

	switch (model) {
		case 430, 446, 452, 453, 454, 472, 473, 484, 493, 595: return 1;
	}
	return 0;
}