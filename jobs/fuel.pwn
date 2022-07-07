#include <YSI_Coding\y_hooks>

new PlayerGetFuel[MAX_PLAYERS];

CMD:fuel(playerid, params[])
{
    new option[16];

    if(sscanf(params, "s[16]", option))
    {
        SendClientMessage(playerid, COLOR_GRAD3, "Lenh:");
	    SendClientMessage(playerid, -1, ""EMBED_YELLOW"/fuel list "EMBED_WHITE"- Hien thi nhien lieu.");
        SendClientMessage(playerid, -1, ""EMBED_YELLOW"/fuel place "EMBED_WHITE"- Dat thung dau xuong.");
        SendClientMessage(playerid, -1, ""EMBED_YELLOW"/fuel get "EMBED_WHITE"- Nhat thung dau len.");
        SendClientMessage(playerid, -1, ""EMBED_YELLOW"/fuel drop "EMBED_WHITE"- Dat thung dau xuong dat.");
        SendClientMessage(playerid, -1, ""EMBED_YELLOW"/fuel buy "EMBED_WHITE"- Mua thung dau.");
        SendClientMessage(playerid, -1, ""EMBED_YELLOW"/fuel sell "EMBED_WHITE"- Ban cho cac doanh nghiep.");
        return 1;
    }

    if(!strcmp(option, "list", true))
    {
        new Float:x, Float:y, Float:z;
        if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) != INVALID_VEHICLE_ID)
        {
            GetVehicleBoot(GetNearestVehicle(playerid), x, y, z); 
            new 
                vehicleid = GetNearestVehicle(playerid)
            ;

            if(!IsCheckVehicleFuel(vehicleid))
                return SendErrorMessage(playerid, "Ban khong o gan phuong tien cho thung dau.");

            if(VehicleInfo[vehicleid][eVehicleLocked])
                return SendServerMessage(playerid, "Chiec xe nay da bi khoa.");

            if(!IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
                return SendErrorMessage(playerid, "Ban khong o phia sau xe.");

            SendClientMessageEx(playerid, COLOR_ORANGE, "Dau chua trong xe %s, so luong: %d thung.",ReturnVehicleName(vehicleid), VehicleInfo[vehicleid][eVehicleFuelStock]);
            return 1;

        }

        else SendErrorMessage(playerid, "Ban khong o phia sau xe.");
    }
    else if(!strcmp(option, "place", true))
    {
        if(!PlayerGetFuel[playerid])
            return SendErrorMessage(playerid, "Ban khong cam mot thung dau.");

        new Float:x, Float:y, Float:z;
        if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) != INVALID_VEHICLE_ID)
        {
            GetVehicleBoot(GetNearestVehicle(playerid), x, y, z); 
            new 
                vehicleid = GetNearestVehicle(playerid)
            ;

            if(!IsCheckVehicleFuel(vehicleid))
                return SendErrorMessage(playerid, "Ban khong o gan phuong tien cho thung dau");

            if(VehicleInfo[vehicleid][eVehicleLocked])
                return SendServerMessage(playerid, "Chiec xe nay da bi khoa.");

            if(!IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
                return SendErrorMessage(playerid, "Ban khong o phia sau xe.");


            new modelid = GetVehicleModel(vehicleid);


            switch(modelid)
            {
                case 422, 554:
                {
                    if(VehicleInfo[vehicleid][eVehicleFuelStock] > 4)
                        return SendErrorMessage(playerid, "Xe nay da day.");

                    VehicleInfo[vehicleid][eVehicleFuelStock]++;
                    PlaceFuel(playerid);
                    return 1;
                }
                case 573:
                {
                    if(VehicleInfo[vehicleid][eVehicleFuelStock] > 10)
                        return SendErrorMessage(playerid, "Xe nay da day.");

                    VehicleInfo[vehicleid][eVehicleFuelStock]++;
                    PlaceFuel(playerid);
                    return 1;
                }
            }
            return 1;

        }
    }
    else if(!strcmp(option, "get", true))
    {
        if(PlayerGetFuel[playerid])
            return SendErrorMessage(playerid, "Ban dang cam mot thung dau.");

        new Float:x, Float:y, Float:z;
        if(!IsPlayerInAnyVehicle(playerid) && GetNearestVehicle(playerid) != INVALID_VEHICLE_ID)
        {
            GetVehicleBoot(GetNearestVehicle(playerid), x, y, z); 
            new 
                vehicleid = GetNearestVehicle(playerid)
            ;

            if(!IsCheckVehicleFuel(vehicleid))
                return SendErrorMessage(playerid, "Ban khong o gan phuong tien cho thung dau");

            if(VehicleInfo[vehicleid][eVehicleLocked])
                return SendServerMessage(playerid, "Chiec xe nay da bi khoa.");

            if(!IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
                return SendErrorMessage(playerid, "Ban khong o phia sau xe.");


            if(!VehicleInfo[vehicleid][eVehicleFuelStock])
                return SendErrorMessage(playerid, "Phuong tien nay khong co thung chua.");


            VehicleInfo[vehicleid][eVehicleFuelStock]--;
            GetPlayerFuel(playerid);
            return 1;

        }
    }
    else if(!strcmp(option, "buy", true))
    {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, -1024.2225,-688.4048,32.0078) && !IsPlayerInRangeOfPoint(playerid, 3.0, -1030.3638,-688.3743,32.0126) && !IsPlayerInRangeOfPoint(playerid, 3.0, -1037.9266,-688.1974,32.0126))
            return SendErrorMessage(playerid,"Ban khong o tram xang.");

        if(PlayerInfo[playerid][pCash] < 100)
            return SendErrorMessage(playerid, "Ban khong co du tien ($100).");
        
        GiveMoney(playerid, -100);
        GetPlayerFuel(playerid);
        return 1;
    }
    else if(!strcmp(option, "sell", true))
    {
        if(!PlayerGetFuel[playerid])
            return SendErrorMessage(playerid, "Ban khong cam mot thung dau.");

        
        new id;
        for(new i = 1; i < MAX_FUELS; i++)
        {
            if(!FuelInfo[i][F_ID])
                continue;
            
            if(IsPlayerInRangeOfPoint(playerid, 3.5, FuelInfo[i][F_Pos][0], FuelInfo[i][F_Pos][1], FuelInfo[i][F_Pos][2]))
            {
                id = i;
                break;
            }
        }

        if(id == 0)
            return SendErrorMessage(playerid, "Ban khong o gan tramg xang.");

        new b_id = FuelInfo[id][F_Business];

        if(!BusinessInfo[b_id][BusinessCash])
            return SendErrorMessage(playerid, "Tien trong doanh nghiep nay da het.");
        

        if(FuelInfo[id][F_Fuel] >= 99999.0)
            return SendErrorMessage(playerid, "Thung nay da day dau.");

        FuelInfo[id][F_Fuel] += 50.0;
        UpdateFuel(id);
        PlaceFuel(playerid);
        GiveMoney(playerid, FuelInfo[id][F_PriceBuy]);
        BusinessInfo[b_id][BusinessCash] -= FuelInfo[id][F_PriceBuy];

        CharacterSave(playerid);
        SaveFuel(id);
        return 1;
    }
    else if(!strcmp(option, "drop", true))
    {
        if(!PlayerGetFuel[playerid])
            return SendErrorMessage(playerid, "Ban khong cam mot thung dau.");
        
        PlaceFuel(playerid);
        SendNearbyMessage(playerid, 5.5, COLOR_EMOTE, "> %s dat thung dau xuong", ReturnName(playerid,0));
        return 1;
    }
    return 1;
}


stock GetPlayerFuel(playerid)
{
    PlayerGetFuel[playerid] = true;
    ApplyAnimation(playerid, "CARRY","liftup", 4.1, 0, 0, 0, 0, 0, 1);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
    SetPlayerAttachedObject(playerid, 9, 3632, 5, 0.092999, 0.373000, 0.186999, -80.899963, -9.800071, 178.300048, 0.714000, 0.712000, 0.793000);

    new str[90];
    format(str, sizeof(str), "cam thung dau len bang hai tay");
    callcmd::me(playerid, str);
    return 1;
}

stock PlaceFuel(playerid)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	RemovePlayerAttachedObject(playerid, 9);
    PlayerGetFuel[playerid] = false;
    return 1;
}