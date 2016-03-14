/*-----------------------------------------------------------------------------------------------------------------
|             ESTE PROJETO É PROTEGIDO POR DIREITOS AUTORAIS CONCEDIDOS ATRAVÉS DA CREATIVE COMMONS               |
|                       http://creativecommons.org/licenses/by-nd/3.0/br/                                         |
|------------------------------------------------------------------------------------------------------------------*/
#include        <       a_samp      >
#include        <       zcmd        >
#include        <       dof2        >
#include        <       sscanf2     >
#include        <       streamer    >
#include        <       Losgs       >

#define         TIMER_FIX_PERFORMANCE_CHECKS        false
#include        <       timerfix    >

/*-----------------------------------------------------------------------------------------------------------------
|             1 - Los Santos                                                                                      |
|             2 - San Fierro                                                                                      |
|             3 - Las Venturas                                                                                    |
|------------------------------------------------------------------------------------------------------------------*/
#define         LHOUSE_CITY                     1

/*-----------------------------------------------------------------------------------------------------------------
|             1 - Teletransporta o player quando comprar o carro                                                  |
|             2 - Envia mensagem com a localização do carro                                                       |
|------------------------------------------------------------------------------------------------------------------*/
#define         LHOUSE_DELIVERY_METHOD          1

/*-----------------------------------------------------------------------------------------------------------------
|             ID da tecla que ao ser pressionada perto do carro, irá ativar/desativar o alarme                    |
|                               Por padrão a tecla é Y (65536)                                                    |
|------------------------------------------------------------------------------------------------------------------*/
#define         ALARM_KEY                       65536

/*-----------------------------------------------------------------------------------------------------------------
|             Número máximo de coletes que podem ser armazenados em cada casa                                     |
|                               Por padrão: 5                                                                     |
|------------------------------------------------------------------------------------------------------------------*/
#define         MAX_ARMOUR                      5

//=====================  [DIALOGS] ==========================//
#define         DIALOG_CREATE_HOUSE             1335
#define         DIALOG_CAR_MODELS_CHANGE        1336
#define         DIALOG_CAR_MENU                 1337
#define         DIALOG_CAR_PARK                 1338
#define         DIALOG_CAR_COLOR_1              1339
#define         DIALOG_VEHICLES_MODELS          1340
#define         DIALOG_SELL_CAR                 1341
#define         DIALOG_HOUSE_STATUS             1342
#define         DIALOG_SELL_HOUSE               1343
#define         DIALOG_CHANGE_HOUSE_SPAWN       1344
#define         DIALOG_EDIT_HOUSE               1345
#define         DIALOG_EDIT_HOUSE_PRICE         1346
#define         DIALOG_EDIT_HOUSE_RENT_PRICE    1347
#define         DIALOG_EDIT_HOUSE_INT           1348
#define         DIALOG_EDIT_HOUSE_ID            1349
#define         DIALOG_HOUSE_TENANT_MENU        1350
#define         DIALOG_HOUSE_RENT_MENU          1351
#define         DIALOG_HOUSE_OWNER_MENU         1352
#define         DIALOG_HOUSE_SELL_MENU          1353
#define         DIALOG_RENT                     1354
#define         DIALOG_RENT_PRICE               1355
#define         DIALOG_HOUSE_SELL_PLAYER        1356
#define         DIALOG_HOUSE_SELL_PLAYER2       1357
#define         DIALOG_HOUSE_SELL_PLAYER3       1358
#define         DIALOG_SELLING_CONFIRM          1359
#define         DIALOG_CHANGE_PLATE             1360
#define         DIALOG_STORAGE_HOUSE            1361
#define         DIALOG_DELETE_HOUSE             1362
#define         DIALOG_CHANGE_OWNER             1363
#define         DIALOG_CHANGE_OWNER2            1364
#define         DIALOG_ADMIN                    1365
#define         DIALOG_SELL_HOUSE_ADMIN         1366
#define         DIALOG_GUEST                    1367
#define         DIALOG_CAR_MODELS_CREATED       1368
#define         DIALOG_RENT_CONFIRM             1369
#define         DIALOG_DUMP_TENANT              1370
#define         DIALOG_UNRENT_CONFIRM           1371
#define         DIALOG_RENTING_GUEST            1372
#define         DIALOG_HOUSE_TITLE              1373
#define         DIALOG_HOUSE_TITLE_ADMIN        1374
#define         DIALOG_CAR_COLOR_2              1375
#define         DIALOG_STORAGE_ARMOUR           1376

//======================== [CORES] ==============================//
#define         COLOR_WARNING					0xf14545ff
#define         COLOR_ERROR						0xf14545ff
#define         COLOR_SUCCESS					0x88aa62ff
#define         COLOR_INFO						0xA9C4E4ff

//======================== [DEFINES] ===========================//
#define         TEXT_SELLING_HOUSE              "- {5CFFC8} CASA A VENDA {FFFFFF} -\n{FFFF5C}Preço: {F6F6F6}$%d\n{FFFF5C}Número: {F6F6F6}%d"
#define         TEXT_HOUSE                      "{46FE00}%s\n\n{FFFF5C}Dono da Casa: {F6F6F6}%s\n{FFFF5C}Aluguel: {F6F6F6}%s\n{FFFF5C}Status: {F6F6F6}%s\n{FFFF5C}Número: {F6F6F6}%d"
#define         TEXT_RENT_HOUSE                 "{46FE00}%s\n\n{FFFF5C}Dono da Casa: {F6F6F6}%s\n{FFFF5C}Locador: {F6F6F6}%s\n{FFFF5C}Preço Aluguel: {F6F6F6}$%d\n{FFFF5C}Status: {F6F6F6}%s\n{FFFF5C}Número: {F6F6F6}%d"

#define         MAX_HOUSES                      500

#define         LOG_HOUSES                      "LHouse/Logs/Casas.log"
#define         LOG_VEHICLES                    "LHouse/Logs/Carros.log"
#define         LOG_ADMIN                       "LHouse/Logs/Administração.log"
#define         LOG_SYSTEM                      "LHouse/Logs/Sistema.log"

#define         LHOUSE_VERSION                  "2.1.7"
#define         LHOUSE_RELEASE_DATE             "10/07/2014"

enum H_DATA
{
    houseOwner[MAX_PLAYER_NAME],
    houseTitle[32],
    Float:houseX,
    Float:houseY,
    Float:houseZ,
    Float:houseIntX,
    Float:houseIntY,
    Float:houseIntZ,
    Float:houseIntFA,
    housePrice,
    houseRentable,
    houseRentPrice,
    houseTenant[MAX_PLAYER_NAME],
    houseInterior,
    houseVirtualWorld,
    houseOutcoming,
    houseIncoming,
    houseStatus,
    Float: houseArmourStored[MAX_ARMOUR]
};

new
    houseData[MAX_HOUSES][H_DATA];

enum V_DATA
{
    vehicleHouse,
    vehicleModel,
    Float:vehicleX,
    Float:vehicleY,
    Float:vehicleZ,
    Float:vehicleAngle,
    vehicleColor1,
    vehicleColor2,
    vehiclePrice,
    vehicleStatus,
    vehiclePlate[9],
    vehicleRespawnTime
};

new
    houseVehicle[MAX_HOUSES][V_DATA];

new Float:vehicleRandomSpawnLS[5][4] =
{
    {562.1305, -1289.1633, 17.2482, 8.3140},
    {555.0199, -1289.7725, 17.2482, 8.3140},
    {545.4489, -1290.3143, 17.2422, 5.4940},
    {537.9535, -1290.5930, 17.2422, 5.4940},
    {531.6931, -1289.9067, 17.2422, 5.4940}
};

new Float:vehicleRandomSpawnLV[5][4] =
{
    {2148.9365, 1408.1271, 10.8203, 357.5897},
    {2142.3223, 1408.1522, 10.8203, 0.4097},
    {2135.7615, 1408.5500, 10.8203, 0.4097},
    {2129.6689, 1408.9573, 10.8203, 0.4097},
    {2122.9722, 1408.7527, 10.8125, 0.4097}
};

new Float:vehicleRandomSpawnSF[5][4] =
{
    {-1660.8989, 1214.8601, 6.8225, 254.6284},
    {-1662.4044, 1220.4973, 13.2328, 244.6268},
    {-1658.1219, 1211.8868, 13.2439, 253.0740},
    {-1665.8286, 1206.1846, 20.7260, 297.6071},
    {-1656.9680, 1214.9564, 20.7159, 214.0509}
};

#pragma unused vehicleRandomSpawnLV
#pragma unused vehicleRandomSpawnSF

new
    houseIDReceiveCar,
    carSell,
    housePickupIn[MAX_HOUSES],
    housePickupOut[MAX_HOUSES],
    houseMapIcon[MAX_HOUSES],
    Text3D:houseLabel[MAX_HOUSES],
    Float:houseInteriorX[MAX_PLAYERS],
    Float:houseInteriorY[MAX_PLAYERS],
    Float:houseInteriorZ[MAX_PLAYERS],
    Float:houseInteriorFA[MAX_PLAYERS],
    houseIntPrice[MAX_PLAYERS],
    houseInteriorInt[MAX_PLAYERS],
    carSet[MAX_PLAYERS],
    bool: houseCarSet[MAX_PLAYERS],
    bool: counting[MAX_PLAYERS] = false,
    houseCarSetPos[MAX_PLAYERS],
    carSetted[MAX_PLAYERS],
    playerReceiveHouse,
    priceReceiveHouse,
    timerC[MAX_PLAYERS],
    houseSellingID,
    playerIDOffer,
    timeHour, timeMinute, timeSecond,
    towRequired[MAX_HOUSES],
    vehicleHouseCarDefined[MAX_HOUSES],
    newOwnerID,
    bool: adminCreatingVehicle[MAX_PLAYERS],
    playerName[MAX_PLAYER_NAME],
    globalColor1,
    globalColor2,
    Float: oldArmour;

//============================= [FORWARDS] ============================//
TowVehicles();
CreateHouseVehicleToPark(playerid);
RentalCharge();
CreateLogs();
SaveHouses();
SaveHouse(house);
SpawnInHome(playerid);
DestroySetVehicle(playerid);

//============================= [PUBLICS] ============================//
public OnPlayerDisconnect(playerid)
{
    new
        house = GetHouseByOwner(playerid);

    if(houseCarSet[playerid])
    {
        new
            logString[400];

        GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
        format(logString, sizeof logString, "O jogador %s[%d], se desconectou e estava definindo o carro da casa %d", playerName, playerid, house);
        WriteLog(LOG_SYSTEM, logString);
        DestroyVehicle(vehicleHouseCarDefined[house]);
        adminCreatingVehicle[playerid] = false;
    }

    return 1;
}

public SpawnInHome(playerid)
{
    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

    new
        house,
        tenantHouseID,
        tenantFile[200],
        houseFile[200],
        houseFile2[200],
        ownerFile[200],
        logString[700];

    format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);
    format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", playerName);

    house = DOF2_GetInt(ownerFile, "houseID");
    tenantHouseID = DOF2_GetInt(tenantFile, "houseID");

    format(houseFile, sizeof houseFile, "LHouse/Casas/Casa %d.txt", house);
    format(houseFile2, sizeof houseFile2, "LHouse/Casas/Casa %d.txt", tenantHouseID);

    if(DOF2_FileExists(ownerFile))
    {
        new
            value = DOF2_GetInt(ownerFile, "ValorAreceber");

    	SetPlayerVirtualWorld(playerid, houseData[house][houseVirtualWorld]);
	    SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
    	SetPlayerFacingAngle(playerid, houseData[house][houseIntFA]);
    	SetPlayerInterior(playerid, houseData[house][houseInterior]);

        format(logString, sizeof logString, "O jogador %s[%d], foi spawnado na casa %d.", playerName, playerid, house);
        WriteLog(LOG_HOUSES, logString);

        if(value != 0)
        {
            format(logString, sizeof logString, "O jogador %s[%d], foi spawnado na casa %d, e coletou o aluguel de $%d.", playerName, playerid, house, houseData[house][houseIncoming]);
            WriteLog(LOG_HOUSES, logString);
            GivePlayerMoney(playerid, houseData[house][houseIncoming]);
            houseData[house][houseIncoming] = 0;
            DOF2_SetInt(ownerFile, "ValorAreceber", houseData[house][houseIncoming]);
            return 1;
        }

        return 1;
    }

    else if(DOF2_FileExists(tenantFile))
    {
        new
            value = DOF2_GetInt(tenantFile, "ValorApagar");

    	SetPlayerVirtualWorld(playerid, houseData[tenantHouseID][houseVirtualWorld]);
	    SetPlayerPos(playerid, houseData[tenantHouseID][houseIntX], houseData[tenantHouseID][houseIntY], houseData[tenantHouseID][houseIntZ]);
    	SetPlayerFacingAngle(playerid, houseData[tenantHouseID][houseIntFA]);
    	SetPlayerInterior(playerid, houseData[tenantHouseID][houseInterior]);

        format(logString, sizeof logString, "O jogador %s[%d], foi spawnado na casa %d.", playerName, playerid, tenantHouseID);
        WriteLog(LOG_HOUSES, logString);

        if(value != 0)
        {
            if(GetPlayerMoney(playerid) < value)
            {
                new
                    Float: X, Float: Y, Float: Z;

                GetPlayerPos(playerid, X, Y, Z);
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Você não tem dinheiro o suficiente para pagar o aluguel e foi despejado.");

    			format(houseData[tenantHouseID][houseTenant], 255, "Ninguem");
    			DOF2_SetString(houseFile2, "Locador", "Ninguem", "Aluguel");
                DOF2_RemoveFile(tenantFile);
                Update3DText(tenantHouseID);

                format(logString, sizeof logString, "O jogador %s[%d], não tinha dinheiro o suficiente para pagar o aluguel da casa %d e foi despejado.", playerName, playerid, tenantHouseID);
                WriteLog(LOG_HOUSES, logString);

                return 1;
            }

            format(logString, sizeof logString, "O jogador %s[%d], foi spawnado na casa %d e pagou $%d de aluguel.", playerName, playerid, tenantHouseID, value);
            WriteLog(LOG_HOUSES, logString);

            GivePlayerMoney(playerid, -value);
            houseData[tenantHouseID][houseOutcoming] = 0;

            DOF2_SetInt(tenantFile, "ValorApagar", houseData[tenantHouseID][houseOutcoming]);
            return 1;
        }

        return 1;
    }

    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetTimerEx("SpawnInHome", 500, false, "i", playerid);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    new vehicleid = GetPlayerVehicleID(playerid);
    new house = GetHouseByOwner(playerid);
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
    {
        if(houseCarSet[playerid])
        {
            counting[playerid] = true;
            SendClientMessage(playerid, COLOR_WARNING, "* Você saiu do veículo que você comprou para sua casa e estava definindo.");
            SendClientMessage(playerid, COLOR_WARNING, "* Você tem {FF0000}50 {FFFFFF}segundos para voltar para o veículo, caso contrário ele vai ser destruído.");
            SendClientMessage(playerid, COLOR_WARNING, "* Se o tempo for esgotado você não vai ter seu dinheiro de volta.");
            timerC[playerid] = SetTimerEx("DestroySetVehicle", 50000, false, "i", playerid);
        }
        return 1;
    }
    else if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
    {
        if(vehicleid == vehicleHouseCarDefined[house])
        {
            if(counting[playerid])
            {
                SendClientMessage(playerid, COLOR_INFO, "* Você entrou no veículo a tempo e pode continuar definindo normalmente.");
                KillTimer(timerC[playerid]);
            }
        }
        return 1;
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    new
        Float: X, Float: Y, Float: Z;

    if(newkeys == KEY_SECONDARY_ATTACK)
    {
        for(new house = 1; house < MAX_HOUSES; house++)
        {
            if(IsPlayerInRangeOfPoint(playerid, 1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]))
            {
                if(IsPlayerAdmin(playerid))
                {
                    TogglePlayerControllable(playerid, 0);
                    ShowPlayerDialog(playerid, DIALOG_ADMIN, DIALOG_STYLE_MSGBOX, "{00F2FC}Escolha um menu.", "{FFFFFF}Qual menu você gostaria de ter acesso desta casa?", "Normal", "Admin.");
                    return 1;
                }

                ShowHouseMenu(playerid);
                GetPlayerPos(playerid, X, Y, Z);
                PlayerPlaySound(playerid, 1083, X, Y, Z);
            }

            else if(IsPlayerInRangeOfPoint(playerid, 1, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]))
            {
                if(GetPlayerVirtualWorld(playerid) == houseData[house][houseVirtualWorld])
                {
                    SetPlayerPos(playerid, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
                    SetPlayerVirtualWorld(playerid, 0);
                    SetPlayerInterior(playerid, 0);

                    new
                        logString[400];

                    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
                    format(logString, sizeof logString, "O jogador %s[%d], saiu da casa %d", playerName, playerid, house);
                    WriteLog(LOG_SYSTEM, logString);
                }
            }
        }
    }

    if(newkeys == ALARM_KEY)
    {
        for(new house = 1; house < MAX_HOUSES; house++)
        {
            new
                housePath[200],
                Float:Pos[3],
                engine, lights, alarm, doors, bonnet, boot, objective;

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
    		GetVehicleParamsEx(houseVehicle[house][vehicleHouse], engine, lights, alarm, doors, bonnet, boot, objective);
    		GetVehiclePos(houseVehicle[house][vehicleHouse], Pos[0], Pos[1], Pos[2]);

    		if(!IsPlayerInVehicle(playerid, houseVehicle[house][vehicleHouse]))
    		{
                if((!strcmp(houseData[house][houseOwner], playerName, false)) || (!strcmp(houseData[house][houseTenant], playerName, false)))
                {
        			if(IsPlayerInRangeOfPoint(playerid, 30.0, Pos[0], Pos[1], Pos[2]))
        			{
        				if(houseVehicle[house][vehicleStatus] == 1)
        				{
        					houseVehicle[house][vehicleStatus] = 0;

        					DOF2_SetInt(housePath, "Status do Carro", 0, "Veículo");
        					DOF2_SaveFile();

        					SendClientMessage(playerid, COLOR_INFO, "* Você destrancou seu veículo.");

        					SetVehicleParamsEx(houseVehicle[house][vehicleHouse], engine, lights, alarm, 0, bonnet, boot, objective);

                            new
                                logString[128];

                            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
                            GetPlayerPos(playerid, X, Y, Z);

                            format(logString, sizeof logString, "O jogador %s[%d], trancou o carro da casa %d ", playerName, playerid, house);
                            WriteLog(LOG_VEHICLES, logString);

                            for(new s = GetMaxPlayers(), i; i < s; i++)
                            {
                                if(IsPlayerInRangeOfPoint(i, 20.0, X, Y, Z))
                                {
                					PlayerPlaySound(i, 1145, X, Y, Z);
            	      				PlayAudioStreamForPlayer(i, "https://dl.dropboxusercontent.com/u/70544925/LHouse/Alarme.mp3", Pos[0], Pos[1], Pos[2], 20.0);
                                }
                            }
        				}

        				else
        	   			{
        					houseVehicle[house][vehicleStatus] = 1;

        					DOF2_SetInt(housePath, "Status do Carro", 1, "Veículo");
        					DOF2_SaveFile();

        					SendClientMessage(playerid, COLOR_INFO, "* Você trancou seu veículo");


        					SetVehicleParamsEx(houseVehicle[house][vehicleHouse], engine, lights, alarm, 1, bonnet, boot, objective);

                            new
                                logString[128];

                            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
                            GetPlayerPos(playerid, X, Y, Z);

                            format(logString, sizeof logString, "O jogador %s[%d], destrancou o carro da casa %d", playerName, playerid, house);
                            WriteLog(LOG_VEHICLES, logString);

                            for(new s = GetMaxPlayers(), i; i < s; i++)
                            {
                                if(IsPlayerInRangeOfPoint(i, 20.0, X, Y, Z))
                                {
                					PlayerPlaySound(i, 1145, X, Y, Z);
            	      				PlayAudioStreamForPlayer(i, "https://dl.dropboxusercontent.com/u/70544925/LHouse/Alarme.mp3", Pos[0], Pos[1], Pos[2], 20.0);
                                }
                            }
        				}
                    }
                }
            }
        }
    }
    return 1;
}

public OnFilterScriptInit()
{
    CreateAllHouses();
    CreateAllHousesVehicles();
    CreateLogs();

    for(new house = 1; house < MAX_HOUSES; house++)
        if(houseVehicle[house][vehicleModel] != 0)
            SetVehicleNumberPlate(houseVehicle[house][vehicleHouse], houseVehicle[house][vehiclePlate]);

    print("\t========================= LHOUSE ========================");
    printf("\t LHouse v%s                ", LHOUSE_VERSION);
    printf("\t Última atualização: %s         ", LHOUSE_RELEASE_DATE);
    print("\t Autor: Lós                     ");
    print("\t========================= LHOUSE ========================\n\n");

    new
        logString[128];

    format(logString, sizeof logString, "----------- SISTEMA INICIADO -----------");
    WriteLog(LOG_SYSTEM, logString);

    SetTimer("TowVehicles", 60000*3, true);
    SetTimer("RentalCharge", 1000, true);
    SetTimer("SaveHouses", 60000*10, true);

    return 1;
}

public OnFilterScriptExit()
{
    SaveHouses();
    DOF2_Exit();

    new
        logString[128];

    format(logString, sizeof logString, "----------- SISTEMA FINALIZADO -----------");
    WriteLog(LOG_SYSTEM, logString);

    for(new house = 1; house < MAX_HOUSES; house++)
        if(houseVehicle[house][vehicleModel] != 0)
            DestroyVehicle(houseVehicle[house][vehicleHouse]);

    return 1;
}

public TowVehicles()
{
    new
        string[128], houseTows;

    for(new houses = 1; houses < MAX_HOUSES; houses++)
    {
        if(towRequired[houses] == 1)
        {
            houseTows++;
            SetVehicleToRespawn(houseVehicle[houses][vehicleHouse]);
            towRequired[houses] = 0;
            format(string, sizeof string, "* O guincho acabou de entregar os carros solicitados!");
        }
    }

    if(houseTows == 0)
        return 1;

    SendClientMessageToAll(COLOR_INFO, string);
    return 1;
}

public DestroySetVehicle(playerid)
{
    SendClientMessage(playerid, COLOR_ERROR, "* Você não voltou para o veículo a tempo.");
    SendClientMessage(playerid, COLOR_ERROR, "* O veículo foi destruído.");
    new house = GetHouseByOwner(playerid);
    DestroyVehicle(vehicleHouseCarDefined[house]);
    houseCarSet[playerid] = false;
    return 1;
}

public CreateLogs()
{
    if(!LogExists(LOG_HOUSES))
    {
        CreateLog(LOG_HOUSES);
        WriteLog(LOG_HOUSES, "Log de casas criado.");
        print("\n\t Log de casas criado.");
    }
    if(!LogExists(LOG_VEHICLES))
    {
        CreateLog(LOG_VEHICLES);
        WriteLog(LOG_VEHICLES, "Log de veículos das casas criado.");
        print("\t Log de veículos das casas criado.");
    }
    if(!LogExists(LOG_ADMIN))
    {
        CreateLog(LOG_ADMIN);
        WriteLog(LOG_ADMIN, "Log de administração das casas criado.");
        print("\t Log de administração das casas criado.");
    }
    if(!LogExists(LOG_SYSTEM))
    {
        CreateLog(LOG_SYSTEM);
        WriteLog(LOG_SYSTEM, "Log do sistema criado.");
        print("\t Log do sistema criado.");
    }
    return 1;
}

public CreateHouseVehicleToPark(playerid)
{
    new
        Float: X, Float: Y, Float: Z,
        Float: facingAngle;

    SendClientMessage(playerid, COLOR_INFO, "* Agora estacione e digite {46FE00}/estacionar{FFFFFF}.");

    GetPlayerPos(playerid, X, Y, Z);
    GetPlayerFacingAngle(playerid, facingAngle);

    carSet[playerid] = 1;
    carSetted[playerid] = CreateVehicle(542, X, Y, Z, facingAngle, 0, 0, 90000);

    PutPlayerInVehicle(playerid, carSetted[playerid], 0);
    SendClientMessage(playerid, COLOR_INFO, "* Veículo criado.");


    return 1;
}

public RentalCharge()
{
    new
        Float: X, Float: Y, Float: Z,
        housesCharged,
        playersDumped,
        ownerID,
        tenantID,
        logString[700],
        playerName2[MAX_PLAYER_NAME],
        playerName3[MAX_PLAYER_NAME],
        ownerFile[200],
        tenantFile[200],
        houseFile[200],
        string[128];

    gettime(timeHour, timeMinute, timeSecond);

    for(new i = 1; i < MAX_HOUSES; i++)
    {
        format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", houseData[i][houseOwner]);
        format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", houseData[i][houseTenant]);
        format(houseFile, sizeof houseFile, "LHouse/Casas/Casa %d.txt", i);

        if(DOF2_FileExists(ownerFile) || DOF2_FileExists(tenantFile))
        {
            for(new ids = 0; ids < MAX_PLAYERS; ids++)
            {
                if(IsPlayerConnected(ids))
                {
                    GetPlayerName(ids, playerName, MAX_PLAYER_NAME);

                    if(!strcmp(houseData[i][houseOwner], playerName, true))
                    {
                       ownerID = ids;
                       GetPlayerName(ownerID, playerName2, MAX_PLAYER_NAME);
                    }

                    if(!strcmp(houseData[i][houseTenant], playerName, true))
                    {
                       tenantID = ids;
                       GetPlayerName(tenantID, playerName3, MAX_PLAYER_NAME);
                    }
                }
            }
        }
        if(timeHour == 15)
        {
            if(timeMinute == 43)
            {
                if(timeSecond == 00)
                {
                    if(strcmp(houseData[i][houseTenant], "Ninguem", true))
                    {
                        housesCharged++;
                        houseData[i][houseOutcoming] += houseData[i][houseRentPrice];
                        houseData[i][houseIncoming] += houseData[i][houseRentPrice];
                        DOF2_SetInt(ownerFile, "ValorAreceber", houseData[i][houseIncoming]);
                        DOF2_SetInt(tenantFile, "ValorApagar", houseData[i][houseOutcoming]);

                        if(IsPlayerConnected(ownerID))
                        {
                            format(string, sizeof string, "* Hora de receber o aluguel! Você recebeu {FFFFFF}$%d {FFFFFF}do locador.", houseData[i][houseIncoming]);
                            SendClientMessage(ownerID, -1, string);
                            GivePlayerMoney(ownerID, houseData[i][houseIncoming]);
                            houseData[i][houseIncoming] = 0;
                            DOF2_SetInt(ownerFile, "ValorAreceber", houseData[i][houseIncoming]);
                        }

                        if(IsPlayerConnected(tenantID))
                        {
                            if(GetPlayerMoney(tenantID) < houseData[i][houseOutcoming])
                            {
                                playersDumped++;
                                GetPlayerPos(tenantID, X, Y, Z);
                                PlayerPlaySound(tenantID, 1085, X, Y, Z);
                                SendClientMessage(tenantID, COLOR_ERROR, "* Você não tem dinheiro o suficiente para pagar o aluguel. Você foi despejado.");
                    			format(houseData[i][houseTenant], 255, "Ninguem");
                    			DOF2_SetString(houseFile, "Locador", "Ninguem", "Aluguel");
                                DOF2_RemoveFile(tenantFile);
                                Update3DText(i);
                                return 1;
                            }

                            format(string, sizeof string, "* Hora de pagar o aluguel! Você pagou {FFFFFF}$%d {FFFFFF}de aluguel.", houseData[i][houseOutcoming]);
                            SendClientMessage(tenantID, COLOR_INFO, string);
                            GivePlayerMoney(tenantID, -houseData[i][houseOutcoming]);
                            houseData[i][houseOutcoming] = 0;
                            DOF2_SetInt(tenantFile, "ValorApagar", houseData[i][houseOutcoming]);
                        }
                    }
                }
            }
        }
    }

    if(housesCharged != 0)
    {
        format(logString, sizeof logString, "Foram cobrado os alugueis de %d casas, %d jogadores que não tinham dinheiro para pagar aluguel estavam conectados e foram despejados.", housesCharged, playersDumped);
        return WriteLog(LOG_SYSTEM, logString);
    }

    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new
        Float: X, Float: Y, Float: Z;

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

    switch(dialogid)
    {
        case DIALOG_ADMIN:
        {
            if(response)
            {
                ShowHouseMenu(playerid);
				TogglePlayerControllable(playerid, 1);
                return 1;
            }

            if(!response)
            {
                ShowAdminMenu(playerid);
				TogglePlayerControllable(playerid, 1);
                return 1;
            }
        }
        case DIALOG_GUEST:
        {
            if (!response)
                return TogglePlayerControllable(playerid, 1);

            new
                house = GetProxHouse(playerid);

            if(houseData[house][houseStatus] == 1)
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Esta casa está trancada.");
                TogglePlayerControllable(playerid, 1);

                new
                    logString[700];

                format(logString, sizeof logString, "O jogador %s[%d], tentou entrar na casa %d, mas ela estava trancada.", playerName, playerid, house);
                WriteLog(LOG_HOUSES, logString);

                return 1;
            }

            else
            {
                if(IsPlayerInRangeOfPoint(playerid, 5.0, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]))
                {
                    SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
                    SetPlayerVirtualWorld(playerid, houseData[house][houseVirtualWorld]);
                    SetPlayerInterior(playerid, houseData[house][houseInterior]);

                    TogglePlayerControllable(playerid, 1);
                    SendClientMessage(playerid, COLOR_INFO, "* Bem vindo!");

                    new
                        logString[700];

                    format(logString, sizeof logString, "O jogador %s[%d], entrou na casa %d como visitante.", playerName, playerid, house);
                    WriteLog(LOG_HOUSES, logString);
                }
            }
        }
        case DIALOG_RENTING_GUEST:
        {
            if(!response)
                return TogglePlayerControllable(playerid, 1);

            new
                house = GetProxHouse(playerid);

            switch(listitem)
            {
                case 0:
                {
                    if(houseData[house][houseStatus] == 1)
                    {
                        SendClientMessage(playerid, COLOR_ERROR, "* Esta casa está trancada!");
                        TogglePlayerControllable(playerid, 1);

                        new
                            logString[256];

                        format(logString, sizeof logString, "O jogador %s[%d], tentou entrar na casa %d, mas ela estava trancada.", playerName, playerid, house);
                        WriteLog(LOG_HOUSES, logString);
                        return 1;
                    }

                    else
                    {
                        if(IsPlayerInRangeOfPoint(playerid, 5.0, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]))
                        {
                            SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
                            SetPlayerVirtualWorld(playerid, houseData[house][houseVirtualWorld]);
                            SetPlayerInterior(playerid, houseData[house][houseInterior]);

                            TogglePlayerControllable(playerid, 1);
                            SendClientMessage(playerid, COLOR_INFO, "* Bem vindo!");

                            new
                                logString[128];

                            format(logString, sizeof logString, "O jogador %s[%d], entrou na casa %d como visitante.", playerName, playerid, house);
                            WriteLog(LOG_HOUSES, logString);
                        }
                    }
                }
                case 1:
                {
                    new
                        ownerFile[200];

                    format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

                    if(DOF2_FileExists(ownerFile))
                    {
                        new
                            alreadyOwner = DOF2_GetInt(ownerFile, "houseID"),
                            string[128];

                        GetPlayerPos(playerid, X, Y, Z);
                        PlayerPlaySound(playerid, 1085, X, Y, Z);

                        format(string, sizeof string, "* Você já é dono da casa %d! Não pode alugar uma casa.!", alreadyOwner);
                        SendClientMessage(playerid, COLOR_ERROR, string);

                        TogglePlayerControllable(playerid, 1);
                        new
                            logString[700];

                        format(logString, sizeof logString, "O jogador %s[%d], tentou alugar a casa %d, mais ele já é dono da casa %d.", playerName, playerid, house, alreadyOwner);
                        WriteLog(LOG_HOUSES, logString);

                        return 1;
                    }

                    new
                        stringCat[600],
                        string[100],
                        string2[100],
                        string3[100];

                    GetPlayerName(playerIDOffer, playerName, MAX_PLAYER_NAME);
                    TogglePlayerControllable(playerIDOffer, 1);

                    format(string, sizeof string, "{00F2FC}Dono da casa a ser alugada: {46FE00}%s\n\n", houseData[house][houseOwner]);
                    format(string2, sizeof string2, "{00F2FC}Valor a ser pago pelo aluguel da casa: {FFFFFF}$%d\n", houseData[house][houseRentPrice]);
                    format(string3, sizeof string3, "{00F2FC}ID da casa a ser alugada: {FFFFFF}%d\n", house);

                    strcat(stringCat, "{00F2FC}Após alugar a casa, o aluguel será cobrado todo dia 00:00! Se você não estiver online\n");
                    strcat(stringCat, "o aluguel será cobrado quando você entrar novamente no servidor.\n\n");
                    strcat(stringCat, string);
                    strcat(stringCat, string2);
                    strcat(stringCat, string3);
                    strcat(stringCat, "{FD0900}ATENÇÃO:{FFFFFF} A casa dita acima vai ser alugada por você e você poderá trancar e destrancar a casa, tanto como nascerá nela.\nVocê também vai poder trancar e destrancar o carro caso ela tiver, caso não tiver você pode ajudar o dono a comprar um\npagando seu aluguel regurlamente.\n");
                    strcat(stringCat, "Você deseja alugar a casa, baseada nas informações acima descritas?\n");

                    ShowPlayerDialog(playerid, DIALOG_RENT_CONFIRM, DIALOG_STYLE_MSGBOX, "Venda de casa", stringCat, "Alugar", "Negar");
                    TogglePlayerControllable(playerid, 1);
                }
            }
        }
        case DIALOG_UNRENT_CONFIRM:
        {
            if (!response)
                return SendClientMessage(playerid, COLOR_ERROR, "* Cancelado.");
            new
                tenantFile[200],
                houseFile[200],
                house = GetProxHouse(playerid),
                logString[128];

            format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", houseData[house][houseTenant]);
            format(houseFile, sizeof houseFile, "LHouse/Casas/Casa %d.txt", house);
            format(houseData[house][houseTenant], 24, "Ninguem");

            DOF2_RemoveFile(tenantFile);
            DOF2_SetString(houseFile, "Locador", "Ninguem", "Aluguel");

            TogglePlayerControllable(playerid, 1);
            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(logString, sizeof logString, "O jogador %s[%d], desalugou a casa %d.", playerName, playerid, house);
            WriteLog(LOG_HOUSES, logString);

            return 1;
        }
        case DIALOG_RENT_CONFIRM:
        {
            if(!response)
                return 1;

            new
                house = GetProxHouse(playerid),
                tenantFile[200],
                houseFile[200],
                logString[128];

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", playerName);
            format(houseFile, sizeof houseFile, "LHouse/Casas/Casa %d.txt", house);

            if(DOF2_FileExists(tenantFile))
            {
                new
                    alreadyTenant = DOF2_GetInt(tenantFile, "houseID"),
                    string[128];

                GetPlayerPos(playerid, X, Y, Z);
                PlayerPlaySound(playerid, 1085, X, Y, Z);

                format(string, sizeof string, "* Você já é locador da casa %d! Você só pode ter 1 casa alugada!", alreadyTenant);
                SendClientMessage(playerid, COLOR_ERROR, string);

                TogglePlayerControllable(playerid, 1);

                format(logString, sizeof logString, "O jogador %s[%d], tentou alugar a casa %d, mas ele já é locador da casa %d.", playerName, playerid, house, alreadyTenant);
                WriteLog(LOG_HOUSES, logString);
                return 1;
            }

            format(houseData[house][houseTenant], 24, playerName);

            DOF2_CreateFile(tenantFile);
            DOF2_SetInt(tenantFile, "houseID", house);
            DOF2_SetString(houseFile, "Locador", houseData[house][houseTenant], "Aluguel");

            SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
            SetPlayerVirtualWorld(playerid, houseData[house][houseVirtualWorld]);
            SetPlayerInterior(playerid, houseData[house][houseInterior]);

            DOF2_SaveFile();
            Update3DText(house);

            format(logString, sizeof logString, "O jogador %s[%d], alugou a casa %d.", playerName, playerid, house);
            WriteLog(LOG_HOUSES, logString);
        }
        case DIALOG_EDIT_HOUSE:
        {
            if(!response)
                return TogglePlayerControllable(playerid, 1);

            new
                house = GetProxHouse(playerid);

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            switch(listitem)
            {
                case 0:
                {
                    if(IsPlayerInRangeOfPoint(playerid, 5.0, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]))
                    {
                        SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
                        SetPlayerVirtualWorld(playerid, houseData[house][houseVirtualWorld]);
                        SetPlayerInterior(playerid, houseData[house][houseInterior]);

                        TogglePlayerControllable(playerid, 1);
                        SendClientMessage(playerid, COLOR_INFO, "* Bem vindo!");

                        new
                            logString[128];

                        format(logString, sizeof logString, "O administrador %s[%d], entrou na casa %d como administrador.", playerName, playerid, house);
                        WriteLog(LOG_HOUSES, logString);
                        WriteLog(LOG_ADMIN, logString);


                    }
                }
                case 1:
                {
                	if(strcmp(houseData[house][houseOwner], "Ninguem", true))
                    {
                        GetPlayerPos(playerid, X, Y, Z);
                        PlayerPlaySound(playerid, 1085, X, Y, Z);

                        SendClientMessage(playerid, COLOR_ERROR, "* Não é possível alterar o preço de uma casa que não está a venda.");

                        new
                            logString[128];

                        format(logString, sizeof logString, "O administrador %s[%d], tentou alterar o preço da casa %d, mas ela não está a venda.", playerName, playerid, house);
                        WriteLog(LOG_ADMIN, logString);

                        ShowAdminMenu(playerid);
                        return 1;
                    }

                    ShowPlayerDialog(playerid, DIALOG_EDIT_HOUSE_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o preço da casa.", "{FFFFFF}Digite o novo preço que você quer abaixo\n{FFFFFF}Use somente números.\n", "Alterar", "Voltar");
                    TogglePlayerControllable(playerid, 1);
                }
                case 2:
                {
                	if(houseData[house][houseRentable] == 0)
                    {
                        GetPlayerPos(playerid, X, Y, Z);
                        PlayerPlaySound(playerid, 1085, X, Y, Z);

                        SendClientMessage(playerid, COLOR_ERROR, "* Não é possível alterar o preço do aluguel de uma casa que não está sendo alugada.");

                        new
                            logString[700];

                        format(logString, sizeof logString, "O administrador %s[%d], tentou alterar o preço de aluguel da casa %d, mas ela não está sendo alugada.", playerName, playerid, house);
                        WriteLog(LOG_ADMIN, logString);

                        ShowAdminMenu(playerid);
                        return 1;
                    }

                    ShowPlayerDialog(playerid, DIALOG_EDIT_HOUSE_RENT_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o preço do aluguel.", "{FFFFFF}Digite o novo preço que você quer abaixo\n{FFFFFF}Use somente números.\n", "Alterar", "Voltar");
                    TogglePlayerControllable(playerid, 1);
                }
                case 3:
                {
                    new
                        stringCat[1200];

                    strcat(stringCat, "Interior {FB1300}1 \t{FCEC00}6 {FFFFFF}Comodos\n");
                    strcat(stringCat, "Interior {FB1300}2 \t{FCEC00}3 {FFFFFF}Comodos\n");
                    strcat(stringCat, "Interior {FB1300}3 \t{FCEC00}3 {FFFFFF}Comodos\n");
                    strcat(stringCat, "Interior {FB1300}4 \t{FCEC00}1 {FFFFFF}Comodo\n");
                    strcat(stringCat, "Interior {FB1300}5 \t{FCEC00}1 {FFFFFF}Comodo\n");
                    strcat(stringCat, "Interior {FB1300}6 \t{FCEC00}3 {FFFFFF}Comodos \t{FFFFFF}(Casa do CJ)\n");
                    strcat(stringCat, "Interior {FB1300}7 \t{FCEC00}5 {FFFFFF}Comodos\n");
                    strcat(stringCat, "Interior {FB1300}8 \t{FCEC00}7 {FFFFFF}Comodos\n");
                    strcat(stringCat, "Interior {FB1300}9 \t{FCEC00}4 {FFFFFF}Comodos\n");
                    strcat(stringCat, "Interior {FB1300}10 \t{FCEC00}Muitos {FFFFFF}Comodos \t{FFFFFF} (Casa do Madd Dog)\n");
                    strcat(stringCat, "Interior {FB1300}11 \t{FCEC00}7 {FFFFFF}Comodos\n");

                    ShowPlayerDialog(playerid, DIALOG_EDIT_HOUSE_INT, DIALOG_STYLE_LIST,"{00F2FC}Você escolheu alterar o interior da casa.", stringCat, "Continuar", "Voltar");
                    TogglePlayerControllable(playerid, 1);
                }
                case 4:
                {
                    ShowPlayerDialog(playerid, DIALOG_HOUSE_STATUS, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu mudar o status dessa casa.", "{FFFFFF}Oque você gostaria de fazer com o status atual da casa?\n", "Trancar", "Destrancar");
                    TogglePlayerControllable(playerid, 1);
                }
                case 5:
                {
                    new
                        stringMessage[128];

                    if (strlen(houseData[house][houseTitle]) > 0)
                    {
                        format(stringMessage, sizeof stringMessage, "{FFFFFF}Digite o novo título da casa.\n\nTítulo anterior: %s\n", houseData[house][houseTitle]);
                        ShowPlayerDialog(playerid, DIALOG_HOUSE_TITLE_ADMIN, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar o título da casa.", stringMessage, "Alterar", "Voltar");
                    }
                    else
                        ShowPlayerDialog(playerid, DIALOG_HOUSE_TITLE_ADMIN, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar o título da casa.", "{FFFFFF}Digite o novo título da casa.\n\nTítulo anterior: {FFFFFF}Título ainda não definido\n", "Alterar", "Voltar");

                    TogglePlayerControllable(playerid, 1);
                }
                case 6:
                {
                    ShowPlayerDialog(playerid, DIALOG_CHANGE_OWNER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o dono da casa.", "{FFFFFF}Digite o {FFFFFF}ID {FFFFFF}ou {FFFFFF}nickname {FFFFFF}do novo dono", "Continuar", "Voltar");
                    TogglePlayerControllable(playerid, 1);
                }
                case 7:
                {
                	if(houseVehicle[house][vehicleModel] != 0)
                    {
                        GetPlayerPos(playerid, X, Y, Z);
                        PlayerPlaySound(playerid, 1085, X, Y, Z);

                        SendClientMessage(playerid, COLOR_ERROR, "* Essa casa já tem carro.");
                        ShowAdminMenu(playerid);

                        new
                            logString[128];

                        format(logString, sizeof logString, "O administrador %s[%d], tentou criar um carro para a casa %d, mas ela já tem carro.", playerName, playerid, house);
                        WriteLog(LOG_ADMIN, logString);

                        return 1;
                    }

                    houseIDReceiveCar = house;
                    adminCreatingVehicle[playerid] = true;
                    SendClientMessage(playerid, COLOR_INFO, "* Vá aonde você quer criar o carro (em uma rua de preferência) e digite {46FE00}/criaraqui.");
                    TogglePlayerControllable(playerid, 1);
                }
                case 8:
                {
                	if(!strcmp(houseData[house][houseOwner], "Ninguem", true))
                    {
                        GetPlayerPos(playerid, X, Y, Z);
                        PlayerPlaySound(playerid, 1085, X, Y, Z);

                        SendClientMessage(playerid, COLOR_ERROR, "* Não é possível vender uma casa que já está a venda.");
                        ShowAdminMenu(playerid);

                        new
                            logString[128];

                        format(logString, sizeof logString, "O administrador %s[%d], tentou vender a casa %d, mas ela já está à venda.", playerName, playerid, house);
                        WriteLog(LOG_ADMIN, logString);

                        return 1;
                    }

                    ShowPlayerDialog(playerid, DIALOG_SELL_HOUSE_ADMIN, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu botar essa casa a venda", "{FFFFFF}Você tem certeza que deseja botar essa casa a venda?", "Sim", "Não");
                    TogglePlayerControllable(playerid, 1);
                }
                case 9:
                {
                    ShowPlayerDialog(playerid, DIALOG_DELETE_HOUSE, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu deletar casa.", "{FFFFFF}Se a casa ter dono, ele não vai ter o dinheiro que gastou na casa novamente.\n{FFFFFF}Você confirma essa ação?", "Deletar", "Voltar");
                    TogglePlayerControllable(playerid, 1);
                }
            }
        }
        case DIALOG_SELL_HOUSE_ADMIN:
        {
            if(!response)
                return ShowAdminMenu(playerid);

            new
                house = GetProxHouse(playerid),
                filePath[200],
                ownerFile[200],
                tenantFile[200];

        	format(filePath, sizeof filePath, "LHouse/Casas/Casa %d.txt", house);
            format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", houseData[house][houseTenant]);
            GetPlayerName(houseData[house][houseOwner], playerName, MAX_PLAYER_NAME);
            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

            if(DOF2_FileExists(ownerFile))
                return DOF2_RemoveFile(ownerFile);

            if(DOF2_FileExists(tenantFile))
                return DOF2_RemoveFile(tenantFile);

			format(houseData[house][houseOwner], 255, "Ninguem");
			format(houseData[house][houseTenant], 255, "Ninguem");

			DOF2_SetString(filePath, "Dono", "Ninguem", "Informações");
			DOF2_SetString(filePath, "Locador", "Ninguem", "Aluguel");
			DOF2_RemoveFile(ownerFile);
            DOF2_SaveFile();

        	DestroyDynamicPickup(housePickupIn[house]);
        	DestroyDynamicMapIcon(houseMapIcon[house]);

            Update3DText(house);
            SendClientMessage(playerid, COLOR_SUCCESS, "* Casa colocada a venda com sucesso.");

            new
                logString[128];

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(logString, sizeof logString, "O administrador %s[%d], botou a casa %d, à venda.", playerName, playerid, house);
            WriteLog(LOG_ADMIN, logString);

            houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 31, -1, -1, 0, -1, 100.0);
            housePickupIn[house] = CreateDynamicPickup(1273, 23, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
        }
        case DIALOG_CHANGE_OWNER:
        {
            if(!response)
                return ShowAdminMenu(playerid);

            GetPlayerPos(playerid, X, Y, Z);

            if(sscanf(inputtext, "u", newOwnerID))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* ID ou nome inválido!");
                ShowPlayerDialog(playerid, DIALOG_CHANGE_OWNER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o dono da casa.", "{FFFFFF}Digite o {FFFFFF}ID {FFFFFF}ou {FFFFFF}nickname {FFFFFF}do novo dono", "Continuar", "Cancelar");
                return 1;
            }

            if(!IsPlayerConnected(newOwnerID) || newOwnerID == INVALID_PLAYER_ID)
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Player desconectado!");
                ShowPlayerDialog(playerid, DIALOG_CHANGE_OWNER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o dono da casa.", "{FFFFFF}Digite o {FFFFFF}ID {FFFFFF}ou {FFFFFF}nickname {FFFFFF}do novo dono", "Continuar", "Cancelar");
                return 1;
            }

            new
                ownerFile[200];

            GetPlayerName(newOwnerID, playerName, MAX_PLAYER_NAME);
            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

            if(DOF2_FileExists(ownerFile))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Esse jogador já tem uma casa!");
                ShowPlayerDialog(playerid, DIALOG_CHANGE_OWNER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o dono da casa.", "{FFFFFF}Digite o {FFFFFF}ID {FFFFFF}ou {FFFFFF}nickname {FFFFFF}do novo dono", "Continuar", "Cancelar");
                return 1;
            }

            new
                dialogString[200],
                house;

            house = GetProxHouse(playerid);
            GetPlayerName(newOwnerID, playerName, MAX_PLAYER_NAME);

            format(dialogString, sizeof dialogString, "{00F2FC}Dono Atual: {46FE00}%s\n{00F2FC}Novo Dono: {46FE00}%s\n\n{FFFFFF}Você confirma está ação?", houseData[house][houseOwner], playerName);
            ShowPlayerDialog(playerid, DIALOG_CHANGE_OWNER2, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu alterar o dono da casa.", dialogString, "Sim", "Não");
        }
        case DIALOG_CHANGE_OWNER2:
        {
            if(!response)
                return ShowAdminMenu(playerid);

            new
                house = GetProxHouse(playerid),
                filePath[200],
                playerName2[MAX_PLAYER_NAME],
                playerName3[MAX_PLAYER_NAME],
                logString[128],
                ownerFile[200],
                newOwnerFile[200];

            GetPlayerName(newOwnerID, playerName, MAX_PLAYER_NAME);
            GetPlayerName(houseData[house][houseOwner], playerName2, MAX_PLAYER_NAME);
            GetPlayerName(playerid, playerName3, MAX_PLAYER_NAME);

            format(filePath, sizeof filePath, "LHouse/Casas/Casa %d.txt", house);
            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName2);
            format(newOwnerFile, sizeof newOwnerFile, "LHouse/Donos/%s.txt", playerName);

            if (!strcmp(playerName2, "Ninguem", true))
            {
                DOF2_CreateFile(newOwnerFile);
                DOF2_SetInt(newOwnerFile, "houseID", house);
                DOF2_SetString(filePath, "Dono", playerName, "Informações");
                DOF2_SaveFile();

                format(houseData[house][houseOwner], 24, playerName);
                houseData[house][houseStatus] = DOF2_SetInt(filePath,"Status", 0, "Informações");

                DestroyDynamicPickup(housePickupIn[house]);
                DestroyDynamicMapIcon(houseMapIcon[house]);
                housePickupIn[house] = CreateDynamicPickup(1272, 23, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
                houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 32, -1, -1, 0, -1, 100.0);

                Update3DText(house);
                return 1;
            }

            format(logString, sizeof logString, "O administrador %s[%d], alterou o dono da casa %d, de %s para %s.", playerName3, playerid, house, playerName2, playerName);
            WriteLog(LOG_ADMIN, logString);

            DOF2_RenameFile(ownerFile, newOwnerFile);
            DOF2_RemoveFile(ownerFile);
            DOF2_SetString(filePath, "Dono", playerName);
            DOF2_SaveFile();

            format(houseData[house][houseOwner], 255, playerName);

            SendClientMessage(playerid, COLOR_SUCCESS, "* Dono da casa alterado com sucesso.");

            Update3DText(house);

            return 1;
        }
        case DIALOG_DELETE_HOUSE:
        {
            if(!response)
                return ShowAdminMenu(playerid);

            new
                house = GetProxHouse(playerid),
                filePath[150],
                houseAtual[200],
                checkID[200],
                logString[128],
                ownerFile[200],
                tenantFile[200],
                playerName2[MAX_PLAYER_NAME],
                playerName3[MAX_PLAYER_NAME];

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
            GetPlayerName(houseData[house][houseOwner], playerName2, MAX_PLAYER_NAME);
            GetPlayerName(houseData[house][houseTenant], playerName3, MAX_PLAYER_NAME);

            format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", playerName3);
            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName2);
            format(logString, sizeof logString, "O administrador %s[%d], deletou a casa %d.", playerName, playerid, house);

            WriteLog(LOG_ADMIN, logString);

            if(DOF2_FileExists(ownerFile))
                return DOF2_RemoveFile(ownerFile);

            if(DOF2_FileExists(tenantFile))
                return DOF2_RemoveFile(tenantFile);

            DestroyDynamicPickup(housePickupIn[house]);
            DestroyDynamicMapIcon(houseMapIcon[house]);
            DestroyDynamic3DTextLabel(houseLabel[house]);

            if(houseVehicle[house][vehicleModel] != 0)
                DestroyVehicle(houseVehicle[house][vehicleHouse]);

            DOF2_RemoveFile(filePath);

            SendClientMessage(playerid, COLOR_SUCCESS, "* Casa removida com sucesso.");

            format(houseAtual, sizeof houseAtual, "LHouse/CasaAtual.txt");

            for(new i = 1; i < MAX_HOUSES; i++)
            {
                format(checkID, sizeof checkID, "LHouse/Casas/Casa %d.txt", i);
                if(!DOF2_FileExists(checkID))
                {
                    DOF2_SetInt(houseAtual, "IDAtual", i);
                    break;
                }
            }

            DOF2_SaveFile();
            return 1;
        }
        case DIALOG_EDIT_HOUSE_PRICE:
        {
            if(!response)
                return ShowAdminMenu(playerid);

            GetPlayerPos(playerid, X, Y, Z);

            if(!IsNumeric(inputtext))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Digite apenas números!");
                ShowPlayerDialog(playerid, DIALOG_EDIT_HOUSE_RENT_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o preço do aluguel.", "{FFFFFF}Digite o novo preço que você quer abaixo\n{FFFFFF}Use somente números.\n", "Alterar", "Cancelar");
                return 1;
            }

            if(!strlen(inputtext))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Digite algo no campo ou cancele!");
                ShowPlayerDialog(playerid, DIALOG_EDIT_HOUSE_RENT_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o preço do aluguel.", "{FFFFFF}Digite o novo preço que você quer abaixo\n{FFFFFF}Use somente números.\n", "Alterar", "Cancelar");
                return 1;
            }

            new
                house = GetProxHouse(playerid),
                file[100],
                logString[128];

            format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);

            houseData[house][housePrice] = strval(inputtext);
            DOF2_SetInt(file, "Preço", houseData[house][housePrice], "Informações");
            DOF2_SaveFile();

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(logString, sizeof logString, "O administrador %s[%d], alterou o preço da casa %d.", playerName, playerid, house);
            WriteLog(LOG_ADMIN, logString);

            SendClientMessage(playerid, COLOR_SUCCESS, "* Preço da casa alterado com sucesso.");

            Update3DText(house);
        }
        case DIALOG_HOUSE_TITLE_ADMIN:
        {
            if(!response)
                return ShowAdminMenu(playerid);

            new
                house = GetProxHouse(playerid);

            if (!strlen(inputtext) && strlen(houseData[house][houseTitle]) > 0)
            {
                SendClientMessage(playerid, COLOR_INFO, "* Você removeu o título da casa.");
                format(houseData[house][houseTitle], 32, "%s", inputtext);
                Update3DText(house);
                return 1;
            }

            else if (!strlen(inputtext) && strlen(houseData[house][houseTitle]) == 0)
            {
                SendClientMessage(playerid, COLOR_WARNING, "* A casa ainda não tem um título, portanto não é possível remove-lo.");
                ShowPlayerDialog(playerid, DIALOG_HOUSE_TITLE_ADMIN, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar o título dessa casa.", "{FFFFFF}Digite o novo título da casa.\n\nTítulo anterior: {FFFFFF}SEM TÍTULO\n", "Alterar", "Voltar");
                return 1;
            }

            format(houseData[house][houseTitle], 32, "%s", inputtext);
            Update3DText(house);

            new
                file[100],
                logString[160];

            format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);

            DOF2_SetString(file, "Título", houseData[house][houseTitle], "Informações");
            DOF2_SaveFile();

            SendClientMessage(playerid, COLOR_INFO, "* Título alterado com sucesso.");

            format(logString, sizeof logString, "O jogador/administrador %s[%d], alterou o título da casa %d para %s.", playerName, playerid, house, houseData[house][houseTitle]);
            WriteLog(LOG_ADMIN, logString);
            WriteLog(LOG_HOUSES, logString);
        }
        case DIALOG_HOUSE_TITLE:
        {
            if(!response)
                return ShowHouseMenu(playerid);

            new
                house = GetProxHouse(playerid);

            if (!strlen(inputtext) && strlen(houseData[house][houseTitle]) > 0)
            {
                SendClientMessage(playerid, COLOR_WARNING, "* Você removeu o título da casa.");
                format(houseData[house][houseTitle], 32, "%s", inputtext);
                Update3DText(house);
                return 1;
            }

            else if (!strlen(inputtext) && strlen(houseData[house][houseTitle]) == 0)
            {
                SendClientMessage(playerid, COLOR_WARNING, "* A casa ainda não tem um título, portanto não é possível remove-lo.");
                ShowPlayerDialog(playerid, DIALOG_HOUSE_TITLE_ADMIN, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar o título dessa casa.", "{FFFFFF}Digite o novo título da casa.\n\nTítulo anterior: {FFFFFF}SEM TÍTULO\n", "Alterar", "Voltar");
                return 1;
            }

            format(houseData[house][houseTitle], 32, "%s", inputtext);
            Update3DText(house);

            new
                file[100],
                logString[160];

            format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);

            DOF2_SetString(file, "Título", houseData[house][houseTitle], "Informações");
            DOF2_SaveFile();

            SendClientMessage(playerid, COLOR_INFO, "* Título alterado com sucesso.");

            format(logString, sizeof logString, "O jogador/administrador %s[%d], alterou o título da casa %d para %s.", playerName, playerid, house, houseData[house][houseTitle]);
            WriteLog(LOG_ADMIN, logString);
            WriteLog(LOG_HOUSES, logString);
        }
        case DIALOG_EDIT_HOUSE_RENT_PRICE:
        {
            if(!response)
                return ShowAdminMenu(playerid);

            GetPlayerPos(playerid, X, Y, Z);

            if(!IsNumeric(inputtext))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Digite apenas números!");
                ShowPlayerDialog(playerid, DIALOG_EDIT_HOUSE_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o preço da casa.", "{FFFFFF}Digite o novo preço que você quer abaixo\n{FFFFFF}Use somente números.\n", "Alterar", "Cancelar");
                return 1;
            }

            if(!strlen(inputtext))
            {
                GetPlayerPos(playerid, X, Y, Z);
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Digite algo no campo ou cancele!");
                ShowPlayerDialog(playerid, DIALOG_EDIT_HOUSE_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar o preço da casa.", "{FFFFFF}Digite o novo preço que você quer abaixo\n{FFFFFF}Use somente números.\n", "Alterar", "Cancelar");
                return 1;
            }

            new
                house = GetProxHouse(playerid),
                file[100],
                logString[128];

            format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);

            houseData[house][houseRentPrice] = strval(inputtext);
            DOF2_SetInt(file, "Preço do Aluguel", houseData[house][houseRentPrice], "Informações");
            DOF2_SaveFile();

            format(logString, sizeof logString, "O administrador %s[%d], alterou o preço de aluguel da casa %d.", playerName, playerid, house);
            WriteLog(LOG_ADMIN, logString);

            Update3DText(house);

            SendClientMessage(playerid, COLOR_SUCCESS, "* Preço do aluguel alterado com sucesso.");
        }
        case DIALOG_EDIT_HOUSE_INT:
        {
            if(!response)
                return ShowAdminMenu(playerid);

            switch(listitem)
            {
                case 0:
                {
                    houseInteriorX[playerid] = 2196.84;
                    houseInteriorY[playerid] = -1204.36;
                    houseInteriorZ[playerid] = 1049.02;
                    houseInteriorFA[playerid] = 94.0010;
                    houseInteriorInt[playerid] = 6;
                }
                case 1:
                {
                    houseInteriorX[playerid] = 2259.38;
                    houseInteriorY[playerid] = -1135.89;
                    houseInteriorZ[playerid] = 1050.64;
                    houseInteriorFA[playerid] = 275.3992;
                    houseInteriorInt[playerid] = 10;
                }
                case 2:
                {
                    houseInteriorX[playerid] = 2282.99;
                    houseInteriorY[playerid] = -1140.28;
                    houseInteriorZ[playerid] = 1050.89;
                    houseInteriorFA[playerid] = 358.4660;
                    houseInteriorInt[playerid] = 11;
                }
                case 3:
                {
                    houseInteriorX[playerid] = 2233.69;
                    houseInteriorY[playerid] = -1115.26;
                    houseInteriorZ[playerid] = 1050.88;
                    houseInteriorFA[playerid] = 358.4660;
                    houseInteriorInt[playerid] = 5;
                }
                case 4:
                {
                    houseInteriorX[playerid] = 2218.39;
                    houseInteriorY[playerid] = -1076.21;
                    houseInteriorZ[playerid] = 1050.48;
                    houseInteriorFA[playerid] = 95.2635;
                    houseInteriorInt[playerid] = 1;
                }
                case 5:
                {
                    houseInteriorX[playerid] = 2496.00;
                    houseInteriorY[playerid] = -1692.08;
                    houseInteriorZ[playerid] = 1014.74;
                    houseInteriorFA[playerid] = 177.8159;
                    houseInteriorInt[playerid] = 3;
                }
                case 6:
                {
                    houseInteriorX[playerid] = 2365.25;
                    houseInteriorY[playerid] = -1135.58;
                    houseInteriorZ[playerid] = 1050.88;
                    houseInteriorFA[playerid] = 359.0367;
                    houseInteriorInt[playerid] = 8;
                }
                case 7:
                {
                    houseInteriorX[playerid] = 2317.77;
                    houseInteriorY[playerid] = -1026.76;
                    houseInteriorZ[playerid] = 1050.21;
                    houseInteriorFA[playerid] = 359.0367;
                    houseInteriorInt[playerid] = 9;
                }
                case 8:
                {
                    houseInteriorX[playerid] = 2324.41;
                    houseInteriorY[playerid] = -1149.54;
                    houseInteriorZ[playerid] = 1050.71;
                    houseInteriorFA[playerid] = 359.0367;
                    houseInteriorInt[playerid] = 12;
                }
                case 9:
                {
                    houseInteriorX[playerid] = 1260.6603;
                    houseInteriorY[playerid] = -785.4005;
                    houseInteriorZ[playerid] = 1091.9063;
                    houseInteriorFA[playerid] = 270.9891;
                    houseInteriorInt[playerid] = 5;
                }
                case 10:
                {
                    houseInteriorX[playerid] = 140.28;
                    houseInteriorY[playerid] = 1365.92;
                    houseInteriorZ[playerid] = 1083.85;
                    houseInteriorFA[playerid] = 9.6901;
                    houseInteriorInt[playerid] = 5;
                }
            }

            new
                house = GetProxHouse(playerid),
                file[100];

            format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);

            houseData[house][houseIntX] = houseInteriorX[playerid];
            houseData[house][houseIntY] = houseInteriorY[playerid];
            houseData[house][houseIntZ] = houseInteriorZ[playerid];
            houseData[house][houseIntFA] = houseInteriorFA[playerid];
            houseData[house][houseInterior] = houseInteriorInt[playerid];

            DOF2_SetFloat(file, "Interior X", houseInteriorX[playerid], "Coordenadas");
            DOF2_SetFloat(file, "Interior Y", houseInteriorY[playerid], "Coordenadas");
            DOF2_SetFloat(file, "Interior Z", houseInteriorZ[playerid], "Coordenadas");
            DOF2_SetFloat(file, "Interior Facing Angle", houseInteriorFA[playerid], "Coordenadas");
            DOF2_SetInt(file, "Interior", houseInteriorInt[playerid], "Coordenadas");
            DOF2_SaveFile();

            SendClientMessage(playerid, COLOR_SUCCESS, "* Interior da casa alterado com sucesso.");

        	DestroyDynamicPickup(housePickupOut[house]);
            housePickupOut[house] = CreateDynamicPickup(1318, 1, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            new
                logString[128];

            format(logString, sizeof logString, "O administrador %s[%d], alterou o interior da casa %d.", playerName, playerid, house);
            WriteLog(LOG_ADMIN, logString);
        }
        case DIALOG_HOUSE_SELL_MENU:
        {
            if(!response)
                return TogglePlayerControllable(playerid, 1);

            switch(listitem)
            {
                case 0:
                {
                	new
                        string[260],
                        filePath[200],
                        house = GetProxHouse(playerid),
                        alreadyOwner,
                        ownerFile[200],
                        tenantFile[200],
                        logString[128];

                    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
                    format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);
                    format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", playerName);
                    format(filePath, sizeof filePath, "LHouse/Casas/Casa %d.txt", house);

                    if(DOF2_FileExists(ownerFile))
                    {
                        alreadyOwner = DOF2_GetInt(ownerFile, "houseID");
                        GetPlayerPos(playerid, X, Y, Z);
                        PlayerPlaySound(playerid, 1085, X, Y, Z);
                        format(string, sizeof string, "* Você já é dono da casa %d! Você só pode ter 1 casa!", alreadyOwner);
                        SendClientMessage(playerid, COLOR_ERROR, string);
                        TogglePlayerControllable(playerid, 1);
                        return 1;
                    }

                    else if(DOF2_FileExists(tenantFile))
                    {
                        alreadyOwner = DOF2_GetInt(tenantFile, "houseID");
                        GetPlayerPos(playerid, X, Y, Z);
                        PlayerPlaySound(playerid, 1085, X, Y, Z);
                        format(string, sizeof string, "* Você já é locador da casa %d! Você só pode ter 1 casa!", alreadyOwner);
                        SendClientMessage(playerid, COLOR_ERROR, string);
                        return 1;
                    }

                	else if(GetPlayerMoney(playerid) < houseData[house][housePrice])
                    {
                        GetPlayerPos(playerid, X, Y, Z);
                        PlayerPlaySound(playerid, 1085, X, Y, Z);
                        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem dinheiro o suficiente.");
                        TogglePlayerControllable(playerid, 1);
                        return 1;
                    }

                  	format(string, sizeof string, "%s comprou a casa de id %d", playerName, house);
                	print(string);
                    WriteLog(LOG_HOUSES, string);

                    DOF2_CreateFile(ownerFile);
                    DOF2_SetInt(ownerFile, "houseID", house);
                    DOF2_SetString(filePath, "Dono", playerName, "Informações");
                    DOF2_SaveFile();

                    format(houseData[house][houseOwner], 24, playerName);
                    houseData[house][houseStatus] = DOF2_SetInt(filePath, "Status", 0, "Informações");

                    GivePlayerMoney(playerid, -houseData[house][housePrice]);
                    SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
                    SetPlayerVirtualWorld(playerid, houseData[house][houseVirtualWorld]);
                    SetPlayerInterior(playerid, houseData[house][houseInterior]);

                    DestroyDynamicPickup(housePickupIn[house]);
                    DestroyDynamicMapIcon(houseMapIcon[house]);
                    housePickupIn[house] = CreateDynamicPickup(1272, 23, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
                    houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 32, -1, -1, 0, -1, 100.0);

                    Update3DText(house);
                    SendClientMessage(playerid, COLOR_INFO, "* Bem vindo!");

                    format(logString, sizeof logString, "O jogador %s[%d], comprou a casa %d.", playerName, playerid, house);
                    WriteLog(LOG_HOUSES, logString);
                }
                case 1:
                {
                    ShowAdminMenu(playerid);
                    TogglePlayerControllable(playerid, 1);
                }
            }
        }
        case DIALOG_HOUSE_TENANT_MENU:
        {
            if(!response)
                return TogglePlayerControllable(playerid, 1);

            new
                house = GetProxHouse(playerid),
                logString[128],
                string[200];

            switch(listitem)
            {
                case 0:
                {
                    if(IsPlayerInRangeOfPoint(playerid, 5.0, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]))
                    {
                        SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
                        SetPlayerVirtualWorld(playerid, houseData[house][houseVirtualWorld]);
                        SetPlayerInterior(playerid, houseData[house][houseInterior]);

                        TogglePlayerControllable(playerid, 1);
                        SendClientMessage(playerid, COLOR_INFO, "* Bem vindo!");


                        GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
                        format(logString, sizeof logString, "O jogador %s[%d], entrou na casa %d como locador.", playerName, playerid, house);
                        WriteLog(LOG_HOUSES, logString);
                    }
                }
                case 1:
                {
                    TogglePlayerControllable(playerid, 1);
                    ShowPlayerDialog(playerid, DIALOG_HOUSE_STATUS, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu mudar o status da casa.", "{FFFFFF}Oque você gostaria de fazer com o status atual da casa?\n", "Trancar", "Destrancar");
                    return 1;
                }
                case 2:
                {
                    format(string, sizeof string, "{FFFFFF}Você deseja desalugar essa casa? {FFFFFF}(%d)\n", house);
                    ShowPlayerDialog(playerid, DIALOG_UNRENT_CONFIRM, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu desalugar a casa.", string, "Sim", "Não");
                }
            }
        }
        case DIALOG_HOUSE_OWNER_MENU:
        {
            if(!response)
                return TogglePlayerControllable(playerid, 1);

            new
                house = GetProxHouse(playerid);

            GetPlayerPos(playerid, X, Y, Z);

            switch(listitem)
            {
                case 0:
                {
                    if(IsPlayerInRangeOfPoint(playerid, 5.0, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]))
                    {
                        SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
                        SetPlayerVirtualWorld(playerid, houseData[house][houseVirtualWorld]);
                        SetPlayerInterior(playerid, houseData[house][houseInterior]);

                        TogglePlayerControllable(playerid, 1);
                        SendClientMessage(playerid, COLOR_INFO, "* Bem vindo!");


                        new
                            logString[128];

                        GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
                        format(logString, sizeof logString, "O jogador %s[%d], entrou na casa %d como dono da casa.", playerName, playerid, house);
                        WriteLog(LOG_HOUSES, logString);
                    }
                }
                case 1:
                {
                    TogglePlayerControllable(playerid, 1);
                    ShowPlayerDialog(playerid, DIALOG_RENT, DIALOG_STYLE_MSGBOX, "{00F2FC}Aluguel.", "{FFFFFF}Oque você gostaria de fazer com o aluguel da sua casa?\n", "Ativar", "Desativar");
                    return 1;
                }
                case 2:
                {
                    TogglePlayerControllable(playerid, 1);
                    ShowPlayerDialog(playerid, DIALOG_HOUSE_STATUS, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu mudar o status da sua casa.", "{FFFFFF}Oque você gostaria de fazer com o status atual da sua casa?\n", "Trancar", "Destrancar");
                    return 1;
                }
                case 3:
                {
                	if(houseVehicle[house][vehicleModel] != 0)
                    {
                        PlayerPlaySound(playerid, 1085, X, Y, Z);
                        SendClientMessage(playerid, COLOR_ERROR, "* Sua casa já tem um carro. Venda-o antes.");
                        TogglePlayerControllable(playerid, 1);
                        return 1;
                    }

                    new
                        stringCat[2500];

                    strcat(stringCat, "Modelo {FB1300}475 \t{FCEC00}Sabre       \t\t{00EAFA}R$ 19.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}496 \t{FCEC00}Blista      \t\t{00EAFA}R$ 25.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}560 \t{FCEC00}Sultan      \t\t{00EAFA}R$ 26.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}401 \t{FCEC00}Bravura     \t\t{00EAFA}R$ 27.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}404 \t{FCEC00}Perenniel   \t\t{00EAFA}R$ 28.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}559 \t{FCEC00}Jester      \t\t{00EAFA}R$ 29.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}402 \t{FCEC00}Buffalo     \t\t{00EAFA}R$ 32.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}562 \t{FCEC00}Elegy       \t\t{00EAFA}R$ 35.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}589 \t{FCEC00}Club        \t\t{00EAFA}R$ 38.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}603 \t{FCEC00}Phoenix     \t\t{00EAFA}R$ 42.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}400 \t{FCEC00}Landstalker \t\t{00EAFA}R$ 65.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}429 \t{FCEC00}Banshee     \t\t{00EAFA}R$ 131.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}415 \t{FCEC00}Cheetah     \t\t{00EAFA}R$ 145.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}411 \t{FCEC00}Infernus    \t\t{00EAFA}R$ 150.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}409 \t{FCEC00}Limosine    \t\t{00EAFA}R$ 230.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}477 \t{FCEC00}ZR-350      \t\t{00EAFA}R$ 250.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}506 \t{FCEC00}Super GT    \t\t{00EAFA}R$ 500.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}541 \t{FCEC00}Bullet      \t\t{00EAFA}R$ 700.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}451 \t{FCEC00}Turismo     \t\t{00EAFA}R$ 850.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}468 \t{FCEC00}Sanchez     \t\t{00EAFA}R$ 40.000,00 {FFFFFF} - MOTO\n");
                    strcat(stringCat, "Modelo {FB1300}461 \t{FCEC00}PCJ-600     \t\t{00EAFA}R$ 55.000,00 {FFFFFF} - MOTO\n");
                    strcat(stringCat, "Modelo {FB1300}521 \t{FCEC00}FCR-900     \t\t{00EAFA}R$ 60.000,00 {FFFFFF} - MOTO\n");
                    strcat(stringCat, "Modelo {FB1300}463 \t{FCEC00}Freeway     \t\t{00EAFA}R$ 80.000,00 {FFFFFF} - MOTO\n");
                    strcat(stringCat, "Modelo {FB1300}522 \t{FCEC00}NRG-500     \t\t{00EAFA}R$ 150.000,00 {FFFFFF} - MOTO\n");
                    ShowPlayerDialog(playerid, DIALOG_VEHICLES_MODELS, DIALOG_STYLE_LIST, "{FFFFFF}Escolha um modelo e clique em continuar.", stringCat, "Continuar", "Voltar");
                    TogglePlayerControllable(playerid, 1);
                }
                case 4:
                {
                    new
                        string[250];

                	if(houseVehicle[house][vehicleModel] != 0)
                    {
                        PlayerPlaySound(playerid, 1085, X, Y, Z);
                        SendClientMessage(playerid, COLOR_ERROR, "* Sua casa casa tem um carro. Venda-o antes de vender sua casa.");
                        TogglePlayerControllable(playerid, 1);
                        return 1;
                    }

                    format(string, sizeof string, "{FFFFFF}Você deseja vender sua casa por {FFFFFF}R$%d{FFFFFF}?\n", houseData[house][housePrice]/2);
                    ShowPlayerDialog(playerid, DIALOG_SELL_HOUSE, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu vender sua casa.", string, "Sim", "Não");
                    TogglePlayerControllable(playerid, 1);
                    return 1;
                }
                case 5:
                {
                    ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_PLAYER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu vender sua casa para um player.", "{FFFFFF}Digite o ID/playerName do player abaixo, é possível utilizar parte do nick quanto ID do player\n", "Próximo", "Voltar");
                    TogglePlayerControllable(playerid, 1);
                    return 1;
                }
                case 6:
                {
                    new
                        string[250];

                    if(houseData[house][houseRentable] == 0)
                    {
                        PlayerPlaySound(playerid, 1085, X, Y, Z);
                        SendClientMessage(playerid, COLOR_ERROR, "* Sua casa casa não está sendo alugada. Ative o aluguel antes.");
                        TogglePlayerControllable(playerid, 1);
                        return 1;
                    }

                	if(!strcmp(houseData[house][houseTenant], "Ninguem", false))
                    {
                        PlayerPlaySound(playerid, 1085, X, Y, Z);
                        SendClientMessage(playerid, COLOR_ERROR, "* Não tem ninguém alugando sua casa no momento.");
                        TogglePlayerControllable(playerid, 1);
                        return 1;
                    }

                    format(string, sizeof string, "{FFFFFF}Você deseja despejar o locador {46FE00}%s{FFFFFF}, da sua casa?\n", houseData[house][houseTenant]);
                    ShowPlayerDialog(playerid, DIALOG_DUMP_TENANT, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu despejar o locador da sua casa.", string, "Sim", "Não");
                    TogglePlayerControllable(playerid, 1);
                }
                case 7:
                {
                    new
                        stringMessage[128];

                    if (strlen(houseData[house][houseTitle]) > 0)
                    {
                        format(stringMessage, sizeof stringMessage, "{FFFFFF}Digite o novo título da casa.\n\nTítulo anterior: {46FE00}%s\n", houseData[house][houseTitle]);
                        ShowPlayerDialog(playerid, DIALOG_HOUSE_TITLE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar o título da casa.", stringMessage, "Alterar", "Voltar");
                    }
                    else
                        ShowPlayerDialog(playerid, DIALOG_HOUSE_TITLE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar o título da casa.", "{FFFFFF}Digite o novo título da casa.\n\nTítulo anterior: {FFFFFF}SEM TÍTULO\n", "Alterar", "Voltar");

                    TogglePlayerControllable(playerid, 1);
                }
                case 8:
                {
                    ShowPlayerDialog(playerid, DIALOG_STORAGE_HOUSE, DIALOG_STYLE_LIST, "{00F2FC}Você escolheu acessar o armazamento.", "{FFFFFF}Coletes a prova de bala", "Acessar", "Voltar");
                    return 1;
                }
            }
        }
        case DIALOG_STORAGE_HOUSE:
        {
            if(!response)
                return ShowHouseMenu(playerid);

            switch(listitem)
            {
                case 0: return ShowStorageMenu(playerid, 1);
            }
        }
        case DIALOG_STORAGE_ARMOUR:
        {
            if(!response)
                return ShowPlayerDialog(playerid, DIALOG_STORAGE_HOUSE, DIALOG_STYLE_LIST, "{00F2FC}Você escolheu acessar o armazamento.", "{FFFFFF}Coletes a prova de bala", "Acessar", "Voltar");

            new
                storageFile[100],
                slotStorageID[20],
                house = GetProxHouse(playerid);

            PlayerPlaySound(playerid, 1085, X, Y, Z);
            GetPlayerArmour(playerid, oldArmour);

            format(storageFile, sizeof storageFile, "LHouse/Armazenamento/Casa %d.txt", house);

            for(new s; s < MAX_ARMOUR; s++)
            {
                if (listitem == s)
                {
                    if(houseData[house][houseArmourStored][s] > 0)
                    {
                        if(oldArmour > 0)
                        {
                            PlayerPlaySound(playerid, 1085, X, Y, Z);
                            SendClientMessage(playerid, COLOR_WARNING, "* Você só pode pegar um colete quando você não estiver usando um.");
                            ShowStorageMenu(playerid, 1);
                            printf("debug: oldArmour = %f, error 00245", oldArmour);
                            return 1;
                        }

                        SetPlayerArmour(playerid, houseData[house][houseArmourStored][s]);
                        houseData[house][houseArmourStored][s] = 0;
                        ShowStorageMenu(playerid, 1);

                        SendClientMessage(playerid, COLOR_INFO, "* Você vestiu o colete com sucesso.");

                        if(!DOF2_FileExists(storageFile))
                            DOF2_CreateFile(storageFile);

                        format(slotStorageID, sizeof slotStorageID, "SLOT %d", s);
                        DOF2_SetFloat(storageFile, slotStorageID, 0, "Colete");
                        DOF2_SaveFile();

                        return 1;
                    }
                    else if(houseData[house][houseArmourStored][s] == 0)
                    {
                        if(oldArmour == 0)
                        {
                            PlayerPlaySound(playerid, 1085, X, Y, Z);
                            SendClientMessage(playerid, COLOR_WARNING, "* Você não tem colete para armazenar.");
                            ShowStorageMenu(playerid, 1);
                            return 1;
                        }
                        else if(oldArmour >= 1 && oldArmour <= 99)
                        {
                            PlayerPlaySound(playerid, 1085, X, Y, Z);
                            SendClientMessage(playerid, COLOR_WARNING, "* É necessário que o seu colete esteja totalmente cheio para que possa ser armazenado.");
                            ShowStorageMenu(playerid, 1);
                            return 1;
                        }

                        houseData[house][houseArmourStored][s] = 100;
                        SetPlayerArmour(playerid, 0);
                        ShowStorageMenu(playerid, 1);

                        SendClientMessage(playerid, COLOR_INFO, "* Colete armazenado com sucesso.");

                        if(!DOF2_FileExists(storageFile))
                            DOF2_CreateFile(storageFile);

                        format(slotStorageID, sizeof slotStorageID, "SLOT %d", s);
                        DOF2_SetFloat(storageFile, slotStorageID, 100, "Colete");
                        DOF2_SaveFile();

                        return 1;
                    }
                }
            }
            return 1;
        }

        case DIALOG_DUMP_TENANT:
        {
            if(!response)
                return ShowHouseMenu(playerid);

            new
                house = GetProxHouse(playerid),
                tenantFile[200],
                houseFile[200],
                string[128],
                string2[128],
                playerName2[MAX_PLAYER_NAME],
                logString[128],
                tenantID = GetTenantID(house);

            if(tenantID != -255)
            {
                if(GetPlayerVirtualWorld(tenantID) == house)
                {
        			SetPlayerPos(tenantID, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
        			SetPlayerInterior(tenantID, 0);
        			SetPlayerVirtualWorld(tenantID, 0);
                }
            }

            format(string, sizeof string, "* Você foi despejado. Procure {46FE00}%s {FFFFFF}para saber o motivo.", houseData[house][houseOwner]);
            format(string2, sizeof string2, "* Você despejou {46FE00}%s {FFFFFF}com sucesso, ele deve te procurar para saber o motivo.", houseData[house][houseTenant]);

            format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", houseData[house][houseTenant]);
            format(houseFile, sizeof houseFile, "LHouse/Casas/Casa %d.txt", house);

            SendClientMessage(houseData[house][houseTenant], COLOR_INFO, string);
            SendClientMessage(playerid, COLOR_INFO, string2);

            GetPlayerName(houseData[house][houseTenant], playerName2, MAX_PLAYER_NAME);
            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(logString, sizeof logString, "O jogador %s[%d], despejou o locador %s da casa %d.", playerName, playerid, playerName2, house);
            WriteLog(LOG_HOUSES, logString);


            DOF2_RemoveFile(tenantFile);
            format(houseData[house][houseTenant], 24, "Ninguem");
            DOF2_SetString(houseFile, "Locador", "Ninguem", "Aluguel");

            return 1;
        }
        case DIALOG_HOUSE_SELL_PLAYER:
        {
            if(!response)
                return ShowHouseMenu(playerid);

            new
                targetID,
                tenantFile[200],
                ownerFile[200];

            GetPlayerPos(playerid, X, Y, Z);

            if(sscanf(inputtext, "u", targetID))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_PLAYER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu vender sua casa para um player.", "{FFFFFF}Digite o ID/playerName do player abaixo, é possível utilizar parte do nick quanto ID do player\n", "Próximo", "Cancelar");
                return 1;
            }

            else if(!IsPlayerConnected(targetID) || targetID == INVALID_PLAYER_ID)
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Jogador não conectado!");
                ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_PLAYER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu vender sua casa para um player.", "{FFFFFF}Digite o ID/playerName do player abaixo, é possível utilizar parte do nick quanto ID do player\n", "Próximo", "Cancelar");
                return 1;
            }

            GetPlayerName(targetID, playerName, MAX_PLAYER_NAME);

            format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", playerName);
            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

            if(DOF2_FileExists(tenantFile))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Este player já é locador de uma casa!");
                ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_PLAYER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu vender sua casa para um player.", "{FFFFFF}Digite o ID/playerName do player abaixo, é possível utilizar parte do nick quanto ID do player\n", "Próximo", "Cancelar");
                return 1;
            }

            else if(DOF2_FileExists(ownerFile))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Este player já é dono de uma casa!");
                ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_PLAYER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu vender sua casa para um player.", "{FFFFFF}Digite o ID/playerName do player abaixo, é possível utilizar parte do nick quanto ID do player\n", "Próximo", "Cancelar");
                return 1;
            }

            else if(playerid == targetID)
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Você não pode vender a casa para você mesmo!");
                ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_PLAYER, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu vender sua casa para um player.", "{FFFFFF}Digite o ID/playerName do player abaixo, é possível utilizar parte do nick quanto ID do player\n", "Próximo", "Cancelar");
                return 1;
            }

            playerReceiveHouse = targetID;
            ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_PLAYER2, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu vender sua casa para um player.", "{FFFFFF}Agora digite o preço abaixo e aguarde a confirmação\n{FFFFFF}Use somente números.\n", "Próximo", "Cancelar");
        }
        case DIALOG_HOUSE_SELL_PLAYER2:
        {
            if(!response)
                return ShowHouseMenu(playerid);

            new
                sellingHousePrice;

            if(sscanf(inputtext, "d", sellingHousePrice))
            {
                GetPlayerPos(playerid, X, Y, Z);
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_PLAYER2, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu vender sua casa para um player.", "{FFFFFF}Agora digite o preço abaixo\n{FFFFFF}Use somente números.\n", "Próximo", "Cancelar");
                return 1;
            }

            priceReceiveHouse = sellingHousePrice;

            new
                stringCat[600],
                string[100],
                string2[100],
                string3[100],
                string4[100],
                playerName2[MAX_PLAYER_NAME],
                ownerFile[200];

            GetPlayerName(playerReceiveHouse, playerName, MAX_PLAYER_NAME);
            GetPlayerName(playerid, playerName2, MAX_PLAYER_NAME);

            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName2);

            houseSellingID = DOF2_GetInt(ownerFile, "houseID");
			playerIDOffer = playerid;

			format(string, sizeof string, "{00F2FC}Quem vai receber a casa: {46FE00}%s\n", playerName);
            format(string2, sizeof string2, "{00F2FC}Valor a ser pago pela casa: {FFFFFF}$%d\n", sellingHousePrice);
            format(string3, sizeof string3, "{00F2FC}ID da casa a ser vendida: {FFFFFF}%d\n", houseSellingID);
            format(string4, sizeof string4, "{00F2FC}Dono da casa a ser vendida: {46FE00}%s\n\n", houseData[houseSellingID][houseOwner]);

			strcat(stringCat, string);
			strcat(stringCat, string2);
			strcat(stringCat, string3);
			strcat(stringCat, string4);
			strcat(stringCat, "{FD0900}ATENÇÃO:{FFFFFF} A casa dita acima vai ser do player para o qual a casa vai ser vendida, isso não pode ser desfeito,\nA menos que você a compre do player novamente.\n");
			strcat(stringCat, "Você deseja confirmar essa ação, baseada nas informações acima descritas?\n");

			ShowPlayerDialog(playerid, DIALOG_SELLING_CONFIRM, DIALOG_STYLE_MSGBOX, "Venda de casa para player", stringCat, "CONFIRMAR", "Cancelar");
        }
        case DIALOG_SELLING_CONFIRM:
        {
            if(!response)
                return ShowHouseMenu(playerid);

            if (!IsPlayerConnected(playerReceiveHouse) || playerReceiveHouse == INVALID_PLAYER_ID)
            {
                SendClientMessage(playerid, COLOR_ERROR, "* O jogador se desconectou!");
                playerReceiveHouse = 0;
                return 1;
            }

            new
                stringCat[600],
                string[100],
                string2[100],
                string3[100];

            GetPlayerName(playerIDOffer, playerName, MAX_PLAYER_NAME);
            TogglePlayerControllable(playerIDOffer, 1);

            strcat(stringCat, "{00F2FC}Há uma oferta para venda de uma casa para você!\n\n\n");

            format(string, sizeof string, "{00F2FC}Dono da casa a ser vendida: {46FE00}%s\n\n", houseData[houseSellingID][houseOwner]);
            format(string2, sizeof string2, "{00F2FC}Valor a ser pago pela casa: {FFFFFF}$%d\n", priceReceiveHouse);
            format(string3, sizeof string3, "{00F2FC}ID da casa a ser vendida: {FFFFFF}%d\n", houseSellingID);

            strcat(stringCat, string);
            strcat(stringCat, string2);
            strcat(stringCat, string3);
            strcat(stringCat, "{FD0900}ATENÇÃO:{FFFFFF} A casa dita acima vai ser sua e isso não pode ser desfeito,\nA menos que você a venda para o player do qual você comprou.\n");
            strcat(stringCat, "Você deseja comprar a casa, baseada nas informações acima descritas?\n");

            ShowPlayerDialog(playerReceiveHouse, DIALOG_HOUSE_SELL_PLAYER3, DIALOG_STYLE_MSGBOX, "Venda de casa", stringCat, "Comprar", "Negar");
        }
        case DIALOG_HOUSE_SELL_PLAYER3:
        {
            GetPlayerPos(playerid, X, Y, Z);
            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            if(!response)
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                TogglePlayerControllable(playerid, 1);

                new
                    string[128];

                format(string, sizeof string, "* O jogador {00F2FC}%s {FFFFFF}negou a sua oferta de comprar a casa número {00F2FC}%d {FFFFFF}por {00F2FC}$%d", playerName, houseSellingID, priceReceiveHouse);
                SendClientMessage(playerIDOffer, COLOR_INFO, string);
                return 1;
            }

            if(GetPlayerMoney(playerid) < priceReceiveHouse)
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                TogglePlayerControllable(playerid, 1);

                new
                    string[150];

                format(string, sizeof string, "* O jogador {00F2FC}%s {FFFFFF}não tem dinheiro o suficiente para comprar a casa número {00F2FC}%d {FFFFFF}por {00F2FC}$%d", playerName, houseSellingID, priceReceiveHouse);
                SendClientMessage(playerIDOffer, COLOR_INFO, string);
                SendClientMessage(playerid, COLOR_ERROR, "* Você não tem dinheiro o suficiente!");
                return 1;
            }

            new
                housePath2[200],
                playerName2[MAX_PLAYER_NAME],
                house = houseSellingID,
                ownerFile[200],
                ownerFile2[200];

            GivePlayerMoney(playerid, -priceReceiveHouse);
            GivePlayerMoney(playerIDOffer, priceReceiveHouse);

            SendClientMessage(playerid, COLOR_SUCCESS, "* Negócio fechado! Divirta-se!");
            SendClientMessage(playerIDOffer, COLOR_SUCCESS, "* Negócio fechado! Divirta-se!");

            GetPlayerName(playerIDOffer, playerName2, 24);

            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName2);
            format(ownerFile2, sizeof ownerFile2, "LHouse/Donos/%s.txt", playerName);
            DOF2_RenameFile(ownerFile, ownerFile2);

            format(housePath2, sizeof housePath2, "LHouse/Casas/Casa %d.txt", house);
			format(houseData[house][houseOwner], 255, playerName2);

			DOF2_SetString(housePath2, "Dono", playerName2);
			DOF2_SaveFile();

			SetPlayerPos(playerid, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
			SetPlayerVirtualWorld(playerid, house);
			SetPlayerInterior(playerid, houseData[house][houseInterior]);

			TogglePlayerControllable(playerid, 1);
			TogglePlayerControllable(playerIDOffer, 1);

			SendClientMessage(playerid, COLOR_INFO, "* Bem vindo!");

            new
                logString[128];

            format(logString, sizeof logString, "O jogador %s[%d], vendeu a casa %d para o jogador %s[%d] por $%d.", playerName2, playerIDOffer, house, playerName, playerid, priceReceiveHouse);
            WriteLog(LOG_HOUSES, logString);

			Update3DText(house);
        }
        case DIALOG_RENT:
        {
          	new
                house = GetProxHouse(playerid);

            GetPlayerPos(playerid, X, Y, Z);

            if(response)
            {
                if(houseData[house][houseRentable] == 1)
                {
                    SendClientMessage(playerid, COLOR_ERROR, "* O aluguel da sua casa já está ativado!");
                    PlayerPlaySound(playerid, 1085, X, Y, Z);
                    return 1;
                }
                ShowPlayerDialog(playerid, DIALOG_RENT_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Insira o valor do aluguel.", "{FFFFFF}Insira o valor do aluguel que você quer.\nEsse valor vai ser entregue na sua casa a cada 24 horas se haver um locador na sua casa\n{FFFFFF}Use somente números.\n", "Alugar!", "Cancelar");
            }
            else
            {
                if(houseData[house][houseRentable] == 0)
                {
                    SendClientMessage(playerid, COLOR_ERROR, "* O aluguel da sua casa já está desativado!");
                    PlayerPlaySound(playerid, 1085, X, Y, Z);
                    return 1;
                }

            	if(strcmp(houseData[house][houseTenant], "Ninguem", false))
                {
                    GetPlayerPos(playerid, X, Y, Z);
                    PlayerPlaySound(playerid, 1085, X, Y, Z);
                    SendClientMessage(playerid, COLOR_ERROR, "* Não é possível desativar o aluguel com alguém alugando sua casa.");
                    TogglePlayerControllable(playerid, 1);
                    return 1;
                }

                houseData[house][houseRentable] = 0;
                Update3DText(house);
                SendClientMessage(playerid, COLOR_SUCCESS, "* Aluguel desativado com sucesso.");


                new
                    logString[128];

                GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
                format(logString, sizeof logString, "O jogador %s[%d], desativou o aluguel da casa %d.", playerName, playerid, house);
                WriteLog(LOG_HOUSES, logString);
            }
        }
        case DIALOG_RENT_PRICE:
        {
            if(!response)
                return ShowHouseMenu(playerid);

            GetPlayerPos(playerid, X, Y, Z);

            if(!IsNumeric(inputtext))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Digite apenas números!");
                ShowPlayerDialog(playerid, DIALOG_RENT_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Insira o valor do aluguel.", "{FFFFFF}Insira o valor do aluguel que você quer.\nEsse valor vai ser entregue na sua casa a cada 24 horas se haver um locador na sua casa\n{FFFFFF}Use somente números.\n", "Alugar!", "Cancelar");
                return 1;
            }

            if(!strlen(inputtext))
            {
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Digite algo no campo ou cancele!");
                ShowPlayerDialog(playerid, DIALOG_RENT_PRICE, DIALOG_STYLE_INPUT, "{00F2FC}Insira o valor do aluguel.", "{FFFFFF}Insira o valor do aluguel que você quer.\nEsse valor vai ser entregue na sua casa a cada 24 horas se haver um locador na sua casa\n{FFFFFF}Use somente números.\n", "Alugar!", "Cancelar");
                return 1;
            }

            new
                house = GetProxHouse(playerid),
                logString[128],
                file[200];

            format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);

            houseData[house][houseRentable] = 1;
            houseData[house][houseRentPrice] = strval(inputtext);

            DOF2_SetInt(file, "Aluguel Ativado", houseData[house][houseRentable], "Aluguel");
            DOF2_SetInt(file, "Preço do Aluguel", houseData[house][houseRentPrice], "Aluguel");
            DOF2_SaveFile();

            Update3DText(house);
            SendClientMessage(playerid, COLOR_SUCCESS, "* Aluguel ativado com sucesso.");


            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
            format(logString, sizeof logString, "O jogador %s[%d], ativou o aluguel da casa %d por $%d.", playerName, playerid, house, houseData[house][houseRentPrice]);
            WriteLog(LOG_HOUSES, logString);

            return 1;
        }
        case DIALOG_CREATE_HOUSE:
        {
            if(!response)
                return 1;

            switch(listitem)
            {
                case 0:
                {
                    houseInteriorX[playerid] = 2196.84;
                    houseInteriorY[playerid] = -1204.36;
                    houseInteriorZ[playerid] = 1049.02;
                    houseInteriorFA[playerid] = 94.0010;
                    houseInteriorInt[playerid] = 6;
                    houseIntPrice[playerid] = 65000;
                }
                case 1:
                {
                    houseInteriorX[playerid] = 2259.38;
                    houseInteriorY[playerid] = -1135.89;
                    houseInteriorZ[playerid] = 1050.64;
                    houseInteriorFA[playerid] = 275.3992;
                    houseInteriorInt[playerid] = 10;
                    houseIntPrice[playerid] = 37000;
                }
                case 2:
                {
                    houseInteriorX[playerid] = 2282.99;
                    houseInteriorY[playerid] = -1140.28;
                    houseInteriorZ[playerid] = 1050.89;
                    houseInteriorFA[playerid] = 358.4660;
                    houseInteriorInt[playerid] = 11;
                    houseIntPrice[playerid] = 37000;
                }
                case 3:
                {
                    houseInteriorX[playerid] = 2233.69;
                    houseInteriorY[playerid] = -1115.26;
                    houseInteriorZ[playerid] = 1050.88;
                    houseInteriorFA[playerid] = 358.4660;
                    houseInteriorInt[playerid] = 5;
                    houseIntPrice[playerid] = 20000;
                }
                case 4:
                {
                    houseInteriorX[playerid] = 2218.39;
                    houseInteriorY[playerid] = -1076.21;
                    houseInteriorZ[playerid] = 1050.48;
                    houseInteriorFA[playerid] = 95.2635;
                    houseInteriorInt[playerid] = 1;
                    houseIntPrice[playerid] = 20000;
                }
                case 5:
                {
                    houseInteriorX[playerid] = 2496.00;
                    houseInteriorY[playerid] = -1692.08;
                    houseInteriorZ[playerid] = 1014.74;
                    houseInteriorFA[playerid] = 177.8159;
                    houseInteriorInt[playerid] = 3;
                    houseIntPrice[playerid] = 150000;
                }
                case 6:
                {
                    houseInteriorX[playerid] = 2365.25;
                    houseInteriorY[playerid] = -1135.58;
                    houseInteriorZ[playerid] = 1050.88;
                    houseInteriorFA[playerid] = 359.0367;
                    houseInteriorInt[playerid] = 8;
                    houseIntPrice[playerid] = 320000;
                }
                case 7:
                {
                    houseInteriorX[playerid] = 2317.77;
                    houseInteriorY[playerid] = -1026.76;
                    houseInteriorZ[playerid] = 1050.21;
                    houseInteriorFA[playerid] = 359.0367;
                    houseInteriorInt[playerid] = 9;
                    houseIntPrice[playerid] = 120000;
                }
                case 8:
                {
                    houseInteriorX[playerid] = 2324.41;
                    houseInteriorY[playerid] = -1149.54;
                    houseInteriorZ[playerid] = 1050.71;
                    houseInteriorFA[playerid] = 359.0367;
                    houseInteriorInt[playerid] = 12;
                    houseIntPrice[playerid] = 95000;
                }
                case 9:
                {
                    houseInteriorX[playerid] = 1260.6603;
                    houseInteriorY[playerid] = -785.4005;
                    houseInteriorZ[playerid] = 1091.9063;
                    houseInteriorFA[playerid] = 270.9891;
                    houseInteriorInt[playerid] = 5;
                    houseIntPrice[playerid] = 1200000;
                }
                case 10:
                {
                    houseInteriorX[playerid] = 140.28;
                    houseInteriorY[playerid] = 1365.92;
                    houseInteriorZ[playerid] = 1083.85;
                    houseInteriorFA[playerid] = 9.6901;
                    houseInteriorInt[playerid] = 5;
                    houseIntPrice[playerid] = 660000;
                }
            }

            new
                house,
                houseAtual[200],
                checkID[200],
                logString[128];

            GetPlayerPos(playerid, X, Y, Z);
            format(houseAtual, sizeof houseAtual, "LHouse/CasaAtual.txt");

            if(!DOF2_FileExists(houseAtual))
            {
                DOF2_CreateFile(houseAtual);
                DOF2_SetInt(houseAtual, "IDAtual", 1);
                DOF2_SaveFile();
                house = 1;
            }

            else
            {
                for(new i = 1; i < MAX_HOUSES; i++)
                {
                    format(checkID, sizeof checkID, "LHouse/Casas/Casa %d.txt", i);
                    if(!DOF2_FileExists(checkID))
                    {
                        DOF2_SetInt(houseAtual, "IDAtual", i);
                        DOF2_SaveFile();
                        house = i;
                        break;
                    }
                }
            }

            CreateHouse(house, X, Y, Z, houseInteriorX[playerid], houseInteriorY[playerid], houseInteriorZ[playerid], houseInteriorFA[playerid], houseIntPrice[playerid], houseInteriorInt[playerid]);
            SendClientMessage(playerid, COLOR_SUCCESS, "* Casa criada com sucesso.");
            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(logString, sizeof logString, "O administrador %s[%d], criou a casa %d.", playerName, playerid, house);
            WriteLog(LOG_ADMIN, logString);

        }
        case DIALOG_CAR_MENU:
        {
            if(!response)
                return 1;

            switch(listitem)
            {
                case 0:
                {
                    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

                    new
                        ownerFile[200];

                    format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

                    new
                        house = DOF2_GetInt(ownerFile, "houseID");

                    houseCarSet[playerid] = true;

                    if(!IsPlayerInVehicle(playerid, houseVehicle[house][vehicleHouse]))
                        return SendClientMessage(playerid, COLOR_INFO, "* Entre no carro, estacione em um local e digite {46FE00}/estacionar{FFFFFF}.");

                    SendClientMessage(playerid, COLOR_INFO, "* Estacione em um local e digite {46FE00}/estacionar{FFFFFF}.");
                }
                case 1:
                {
                    ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_1, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Insira a cor 1 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
                }
                case 2:
                {
                    new
                        stringCat[2500];

                    strcat(stringCat, "Modelo {FB1300}475 \t{FCEC00}Sabre       \t\t{00EAFA}R$ 19.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}496 \t{FCEC00}Blista      \t\t{00EAFA}R$ 25.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}560 \t{FCEC00}Sultan      \t\t{00EAFA}R$ 26.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}401 \t{FCEC00}Bravura     \t\t{00EAFA}R$ 27.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}404 \t{FCEC00}Perenniel   \t\t{00EAFA}R$ 28.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}559 \t{FCEC00}Jester      \t\t{00EAFA}R$ 29.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}402 \t{FCEC00}Buffalo     \t\t{00EAFA}R$ 32.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}562 \t{FCEC00}Elegy       \t\t{00EAFA}R$ 35.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}589 \t{FCEC00}Club        \t\t{00EAFA}R$ 38.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}603 \t{FCEC00}Phoenix     \t\t{00EAFA}R$ 42.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}400 \t{FCEC00}Landstalker \t\t{00EAFA}R$ 65.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}429 \t{FCEC00}Banshee     \t\t{00EAFA}R$ 131.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}415 \t{FCEC00}Cheetah     \t\t{00EAFA}R$ 145.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}411 \t{FCEC00}Infernus    \t\t{00EAFA}R$ 150.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}409 \t{FCEC00}Limosine    \t\t{00EAFA}R$ 230.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}477 \t{FCEC00}ZR-350      \t\t{00EAFA}R$ 250.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}506 \t{FCEC00}Super GT    \t\t{00EAFA}R$ 500.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}541 \t{FCEC00}Bullet      \t\t{00EAFA}R$ 700.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}451 \t{FCEC00}Turismo     \t\t{00EAFA}R$ 850.000,00 \n");
                    strcat(stringCat, "Modelo {FB1300}468 \t{FCEC00}Sanchez     \t\t{00EAFA}R$ 40.000,00 {FFFFFF} - MOTO\n");
                    strcat(stringCat, "Modelo {FB1300}461 \t{FCEC00}PCJ-600     \t\t{00EAFA}R$ 55.000,00 {FFFFFF} - MOTO\n");
                    strcat(stringCat, "Modelo {FB1300}521 \t{FCEC00}FCR-900     \t\t{00EAFA}R$ 60.000,00 {FFFFFF} - MOTO\n");
                    strcat(stringCat, "Modelo {FB1300}463 \t{FCEC00}Freeway     \t\t{00EAFA}R$ 80.000,00 {FFFFFF} - MOTO\n");
                    strcat(stringCat, "Modelo {FB1300}522 \t{FCEC00}NRG-500     \t\t{00EAFA}R$ 150.000,00 {FFFFFF} - MOTO\n");

                    ShowPlayerDialog(playerid, DIALOG_CAR_MODELS_CHANGE, DIALOG_STYLE_LIST, "{FFFFFF}Escolha um modelo e clique em continuar.", stringCat, "Continuar", "Voltar");
                }
                case 3:
                {
                    ShowPlayerDialog(playerid, DIALOG_CHANGE_PLATE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar a placa do seu carro.", "{FFFFFF}Digite a nova placa.\n{FFFFFF}O número máximo de caracteres é 8!", "Alterar", "Voltar");
                }
                case 4:
                {
                    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

                    new
                        ownerFile[200],
                        string[200];

                    format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

                    new
                        house = DOF2_GetInt(ownerFile, "houseID");

                    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
                    format(string, sizeof string, "{FFFFFF}Tem certeza que deseja vender seu carro por {FFFFFF}$%d {FFFFFF}?\n{FFFFFF}Essa ação não pode ser desfeita", houseVehicle[house][vehiclePrice]/2);
					ShowPlayerDialog(playerid, DIALOG_SELL_CAR, DIALOG_STYLE_MSGBOX, "{00F2FC}Você escolheu vender o seu carro.", string, "Sim", "Não");
                }
            }
        }
        case DIALOG_CAR_MODELS_CREATED:
        {
            new
                vehiclePath2[200];

            format(vehiclePath2, sizeof vehiclePath2, "LHouse/Casas/Casa %d.txt", houseIDReceiveCar);

            if(!response)
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Você cancelou!");

                DestroyVehicle(carSetted[playerid]);

        		houseVehicle[houseIDReceiveCar][vehicleX] = 0.0;
        		houseVehicle[houseIDReceiveCar][vehicleY] = 0.0;
        		houseVehicle[houseIDReceiveCar][vehicleZ] = 0.0;
                houseVehicle[houseIDReceiveCar][vehicleAngle] = 0.0;
    			houseVehicle[houseIDReceiveCar][vehicleColor1] = 0;
    			houseVehicle[houseIDReceiveCar][vehicleColor2] = 0;
    			houseVehicle[houseIDReceiveCar][vehicleRespawnTime] = 0;
                houseVehicle[houseIDReceiveCar][vehiclePrice] = 0;
            	houseVehicle[houseIDReceiveCar][vehicleModel] = 0;

            	DOF2_SetInt(vehiclePath2, "Modelo do Carro", houseVehicle[houseIDReceiveCar][vehicleModel], "Veículo");
    			DOF2_SetFloat(vehiclePath2, "Coordenada do Veículo X", houseVehicle[houseIDReceiveCar][vehicleX], "Veículo");
    			DOF2_SetFloat(vehiclePath2, "Coordenada do Veículo Y", houseVehicle[houseIDReceiveCar][vehicleY], "Veículo");
    	   		DOF2_SetFloat(vehiclePath2, "Coordenada do Veículo Z", houseVehicle[houseIDReceiveCar][vehicleZ], "Veículo");
                DOF2_SetFloat(vehiclePath2, "Angulo", houseVehicle[houseIDReceiveCar][vehicleAngle], "Veículo");
    			DOF2_SetInt(vehiclePath2, "Cor 1", houseVehicle[houseIDReceiveCar][vehicleColor1], "Veículo");
    			DOF2_SetInt(vehiclePath2, "Cor 2", houseVehicle[houseIDReceiveCar][vehicleColor2], "Veículo");
    			DOF2_SetInt(vehiclePath2, "Valor", houseVehicle[houseIDReceiveCar][vehiclePrice], "Veículo");
    			DOF2_SetInt(vehiclePath2, "Tempo de Respawn", houseVehicle[houseIDReceiveCar][vehicleRespawnTime], "Veículo");

                DOF2_SaveFile();
                return 1;
            }

            switch(listitem)
            {
                case 0:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 475;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 19000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 1:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 496;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 25000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 2:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 560;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 26000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 3:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 401;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 27000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 4:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 404;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 28000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 5:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 559;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 29000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 6:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 402;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 32000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 7:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 562;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 35000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 8:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 589;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 38000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 9:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 603;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 42000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 10:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 400;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 65000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 11:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 429;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 131000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 12:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 415;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 145000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 13:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 411;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 150000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 14:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 409;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 230000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 15:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 477;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 250000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 16:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 506;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 500000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 17:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 541;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 700000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 18:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 451;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 850000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 19:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 468;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 40000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 20:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 461;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 55000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 21:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 521;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 60000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 22:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 463;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 80000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
                case 23:
                {
            		houseVehicle[houseIDReceiveCar][vehicleModel] = 522;
                    houseVehicle[houseIDReceiveCar][vehiclePrice] = 150000;
                    CreateHouseVehicleBought(playerid, houseIDReceiveCar);
                }
            }
        }

        case DIALOG_CHANGE_PLATE:
        {
            if(!response)
                return ShowHouseVehicleMenu(playerid);

            if(!strlen(inputtext) || strlen(inputtext) > 8)
            {
                GetPlayerPos(playerid, X, Y, Z);
                PlayerPlaySound(playerid, 1085, X, Y, Z);
                SendClientMessage(playerid, COLOR_ERROR, "* Você não digitou nada ou digitou mais do que 8 caracteres!");

                ShowPlayerDialog(playerid, DIALOG_CHANGE_PLATE, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu alterar a placa do seu carro.", "{FFFFFF}Digite a nova placa.\n{FFFFFF}O número máximo de caracteres é 8!", "Alterar", "Voltar");
                return 1;
            }

            new
                housePath[200],
                plate[9],
                ownerFile[200],
                logString[128];

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

            new
                house = DOF2_GetInt(ownerFile, "houseID");

            format(housePath, sizeof housePath, "LHouse/Casas/Casa %d.txt", house);
			format(plate, sizeof plate, "%s", inputtext);

			houseVehicle[house][vehiclePlate] = plate;

            DestroyVehicle(houseVehicle[house][vehicleHouse]);
            houseVehicle[house][vehicleHouse] = CreateVehicle(houseVehicle[house][vehicleModel], houseVehicle[house][vehicleX], houseVehicle[house][vehicleY], houseVehicle[house][vehicleZ], houseVehicle[house][vehicleAngle], houseVehicle[house][vehicleColor1], houseVehicle[house][vehicleColor2], houseVehicle[house][vehicleRespawnTime]);
            SetVehicleNumberPlate(houseVehicle[house][vehicleHouse], plate);

			DOF2_SetString(housePath, "Placa", houseVehicle[house][vehiclePlate], "Veículo");
			DOF2_SaveFile();

			SendClientMessage(playerid, COLOR_SUCCESS, "* Veículo atualizado com sucesso.");

            format(logString, sizeof logString, "O jogador %s[%d], mudou a placa do carro da casa %d para %s.", playerName, playerid, house, plate);
            WriteLog(LOG_VEHICLES, logString);

            return 1;
        }
        case DIALOG_CAR_COLOR_1:
        {
			if(!response)
                return ShowHouseVehicleMenu(playerid);

            if (!strval(inputtext))
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Utilize somente números.");
                ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_1, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Insira a cor 1 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
                return 1;
            }

            else if (!strlen(inputtext))
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Nâo deixe o campo vazio.");
                ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_1, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Insira a cor 1 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
                return 1;
            }

            else if (0 > strval(inputtext) || strval(inputtext) > 255)
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Use somente IDs entre 0 e 255.");
                ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_1, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Insira a cor 1 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
                return 1;
            }

            globalColor1 = strval(inputtext);

            ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_2, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Agora insira a cor 2 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
        }
        case DIALOG_CAR_COLOR_2:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_1, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Insira a cor 1 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
                return 1;
            }

            if (!strval(inputtext))
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Utilize somente números.");
                ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_2, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Agora insira a cor 2 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
                return 1;
            }

            else if (!strlen(inputtext))
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Nâo deixe o campo vazio.");
                ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_2, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Agora insira a cor 2 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
                return 1;
            }

            else if (0 > strval(inputtext) || strval(inputtext) > 255)
            {
                SendClientMessage(playerid, COLOR_ERROR, "* Use somente IDs entre 0 e 255.");
                ShowPlayerDialog(playerid, DIALOG_CAR_COLOR_2, DIALOG_STYLE_INPUT, "{00F2FC}Você escolheu mudar a cor do seu carro.", "{FFFFFF}Agora insira a cor 2 do carro.\n{FFFFFF}Utilize somente números de 0 a 255!", "Continuar", "Voltar");
                return 1;
            }

            globalColor2 = strval(inputtext);

            new
                ownerFile[200];

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

            new
                house = DOF2_GetInt(ownerFile, "houseID");

            ChangeHouseVehicleColor(house, globalColor1, globalColor2);

            new
                logString[128];

            format(logString, sizeof logString, "O jogador %s[%d], alterou a cor do carro da casa %d.", playerName, playerid, house);
            WriteLog(LOG_VEHICLES, logString);

            SendClientMessage(playerid, COLOR_SUCCESS, "* Veículo atualizado com sucesso.");
        }
        case DIALOG_CAR_MODELS_CHANGE:
        {
            if(!response)
                return TogglePlayerControllable(playerid, 1);

            new
                filePath[200],
                ownerFile[200];

          	GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

            new
                house = DOF2_GetInt(ownerFile, "houseID");

            format(filePath, sizeof filePath, "LHouse/Casas/Casa %d.txt", house);

			switch(listitem)
			{
				case 0:
				{
					if(GetPlayerMoney(playerid) < 19000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 475, 19000, 0);
                    GivePlayerMoney(playerid, -19000);
				}
				case 1:
				{
					if(GetPlayerMoney(playerid) < 25000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 496, 25000, 1);
                    GivePlayerMoney(playerid, -25000);
				}
				case 2:
				{
					if(GetPlayerMoney(playerid) < 26000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 560, 26000, 1);
                    GivePlayerMoney(playerid, -26000);
				}
				case 3:
				{
					if(GetPlayerMoney(playerid) < 27000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 401, 27000, 1);
                    GivePlayerMoney(playerid, -27000);
				}
				case 4:
				{
					if(GetPlayerMoney(playerid) < 28000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

				    ChangeHouseVehicleModel(house, 404, 28000, 1);
                    GivePlayerMoney(playerid, -28000);
				}
				case 5:
				{
					if(GetPlayerMoney(playerid) < 29000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 559, 29000, 1);
                    GivePlayerMoney(playerid, -29000);
				}
				case 6:
				{
					if(GetPlayerMoney(playerid) < 32000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 402, 32000, 1);
                    GivePlayerMoney(playerid, -32000);
				}
				case 7:
				{
					if(GetPlayerMoney(playerid) < 35000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 562, 35000, 1);
                    GivePlayerMoney(playerid, -35000);
				}
				case 8:
				{
					if(GetPlayerMoney(playerid) < 38000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 589, 38000, 1);
                    GivePlayerMoney(playerid, -38000);
				}
				case 9:
				{
					if(GetPlayerMoney(playerid) < 42000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 603, 42000, 1);
                    GivePlayerMoney(playerid, -42000);
				}
				case 10:
				{
					if(GetPlayerMoney(playerid) < 65000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 400, 65000, 1);
                    GivePlayerMoney(playerid, -65000);
				}
				case 11:
				{
					if(GetPlayerMoney(playerid) < 131000)
			     	{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 429, 131000, 1);
                    GivePlayerMoney(playerid, -131000);
                }
				case 12:
				{
					if(GetPlayerMoney(playerid) < 145000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 415, 145000, 1);
                    GivePlayerMoney(playerid, -145000);
				}
				case 13:
				{
					if(GetPlayerMoney(playerid) < 150000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 411, 150000, 1);
                    GivePlayerMoney(playerid, -150000);
				}
				case 14:
				{
					if(GetPlayerMoney(playerid) < 230000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 409, 230000, 1);
                    GivePlayerMoney(playerid, -230000);
				}
				case 15:
				{
					if(GetPlayerMoney(playerid) < 250000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 477, 250000, 1);
                    GivePlayerMoney(playerid, -250000);
				}
				case 16:
				{
					if(GetPlayerMoney(playerid) < 500000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 506, 500000, 1);
                    GivePlayerMoney(playerid, -500000);
				}
				case 17:
				{
					if(GetPlayerMoney(playerid) < 700000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 541, 700000, 1);
                    GivePlayerMoney(playerid, -700000);
				}
				case 18:
				{
					if(GetPlayerMoney(playerid) < 850000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 451, 850000, 1);
                    GivePlayerMoney(playerid, -850000);
				}
				case 19:
				{
					if(GetPlayerMoney(playerid) < 40000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 468, 40000, 1);
                    GivePlayerMoney(playerid, -40000);
				}
				case 20:
				{
					if(GetPlayerMoney(playerid) < 55000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 461, 55000, 1);
                    GivePlayerMoney(playerid, -55000);
				}
				case 21:
				{
					if(GetPlayerMoney(playerid) < 60000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 521, 60000, 1);
                    GivePlayerMoney(playerid, -60000);
				}
				case 22:
				{
					if(GetPlayerMoney(playerid) < 80000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 463, 80000, 1);
                    GivePlayerMoney(playerid, -80000);
				}
				case 23:
				{
					if(GetPlayerMoney(playerid) < 150000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 522, 150000, 1);
                    GivePlayerMoney(playerid, -150000);
				}
            }
        }
        case DIALOG_VEHICLES_MODELS:
        {
            if(!response)
            {
                TogglePlayerControllable(playerid, 1);
                return 1;
            }
            new filePath[200];
          	GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
            new ownerFile[200];
            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);
            new house = DOF2_GetInt(ownerFile, "houseID");
            format(filePath, sizeof filePath, "LHouse/Casas/Casa %d.txt", house);
			switch(listitem)
			{
				case 0:
				{
					if(GetPlayerMoney(playerid) < 19000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 475, 19000, 0);
					GivePlayerMoney(playerid, -19000);
					HouseVehicleDelivery(playerid);
				}
				case 1:
				{
					if(GetPlayerMoney(playerid) < 25000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

					ChangeHouseVehicleModel(house, 496, 25000, 0);
                    GivePlayerMoney(playerid, -25000);
					HouseVehicleDelivery(playerid);
				}
				case 2:
				{
					if(GetPlayerMoney(playerid) < 26000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 560, 26000, 0);
				    GivePlayerMoney(playerid, -26000);
					HouseVehicleDelivery(playerid);
				}
				case 3:
				{
					if(GetPlayerMoney(playerid) < 27000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
                    }

					ChangeHouseVehicleModel(house, 401, 27000, 0);
                    GivePlayerMoney(playerid, -27000);
					HouseVehicleDelivery(playerid);
				}
				case 4:
				{
					if(GetPlayerMoney(playerid) < 28000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 404, 28000, 0);
                    GivePlayerMoney(playerid, -28000);
                    HouseVehicleDelivery(playerid);
				}
				case 5:
				{
					if(GetPlayerMoney(playerid) < 29000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 559, 28000, 0);
                    GivePlayerMoney(playerid, -29000);
                    HouseVehicleDelivery(playerid);
				}
				case 6:
				{
					if(GetPlayerMoney(playerid) < 32000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 402, 32000, 0);
                    GivePlayerMoney(playerid, -32000);
                    HouseVehicleDelivery(playerid);
				}
				case 7:
				{
					if(GetPlayerMoney(playerid) < 35000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 562, 35000, 0);
                    GivePlayerMoney(playerid, -35000);
                    HouseVehicleDelivery(playerid);
				}
				case 8:
				{
					if(GetPlayerMoney(playerid) < 38000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 589, 38000, 0);
                    GivePlayerMoney(playerid, -38000);
                    HouseVehicleDelivery(playerid);
				}
				case 9:
				{
					if(GetPlayerMoney(playerid) < 42000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 603, 42000, 0);
                    GivePlayerMoney(playerid, -42000);
                    HouseVehicleDelivery(playerid);
				}
				case 10:
				{
					if(GetPlayerMoney(playerid) < 65000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 400, 65000, 0);
                    GivePlayerMoney(playerid, -65000);
                    HouseVehicleDelivery(playerid);
				}
				case 11:
				{
					if(GetPlayerMoney(playerid) < 131000)
			     	{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 429, 131000, 0);
                    GivePlayerMoney(playerid, -131000);
                    HouseVehicleDelivery(playerid);
                }
				case 12:
				{
					if(GetPlayerMoney(playerid) < 145000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 415, 145000, 0);
                    GivePlayerMoney(playerid, -145000);
                    HouseVehicleDelivery(playerid);
				}
				case 13:
				{
					if(GetPlayerMoney(playerid) < 150000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 411, 150000, 0);
                    GivePlayerMoney(playerid, -145000);
                    HouseVehicleDelivery(playerid);
				}
				case 14:
				{
					if(GetPlayerMoney(playerid) < 230000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 409, 230000, 0);
                    GivePlayerMoney(playerid, -230000);
                    HouseVehicleDelivery(playerid);
				}
				case 15:
				{
					if(GetPlayerMoney(playerid) < 250000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 477, 250000, 0);
                    GivePlayerMoney(playerid, -250000);
                    HouseVehicleDelivery(playerid);
				}
				case 16:
				{
					if(GetPlayerMoney(playerid) < 500000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 506, 500000, 0);
                    GivePlayerMoney(playerid, -500000);
                    HouseVehicleDelivery(playerid);
				}
				case 17:
				{
					if(GetPlayerMoney(playerid) < 700000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 541, 700000, 0);
                    GivePlayerMoney(playerid, -700000);
                    HouseVehicleDelivery(playerid);
				}
				case 18:
				{
					if(GetPlayerMoney(playerid) < 850000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 451, 850000, 0);
                    GivePlayerMoney(playerid, -850000);
                    HouseVehicleDelivery(playerid);
				}
				case 19:
				{
					if(GetPlayerMoney(playerid) < 40000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 468, 40000, 0);
                    GivePlayerMoney(playerid, -40000);
                    HouseVehicleDelivery(playerid);
				}
				case 20:
				{
					if(GetPlayerMoney(playerid) < 55000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 461, 55000, 0);
                    GivePlayerMoney(playerid, -55000);
                    HouseVehicleDelivery(playerid);
				}
				case 21:
				{
					if(GetPlayerMoney(playerid) < 60000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 521, 60000, 0);
                    GivePlayerMoney(playerid, -60000);
                    HouseVehicleDelivery(playerid);
				}
				case 22:
				{
					if(GetPlayerMoney(playerid) < 80000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 463, 80000, 0);
                    GivePlayerMoney(playerid, -80000);
                    HouseVehicleDelivery(playerid);
				}
				case 23:
				{
					if(GetPlayerMoney(playerid) < 150000)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro insuficiente.");
						TogglePlayerControllable(playerid, 1);
						return 1;
					}

                    ChangeHouseVehicleModel(house, 522, 150000, 0);
                    GivePlayerMoney(playerid, -150000);
                    HouseVehicleDelivery(playerid);
				}
            }
        }
        case DIALOG_SELL_CAR:
        {
            if(!response)
                return ShowHouseVehicleMenu(playerid);

           	new
                string[200],
                filePath[200],
                ownerFile[200],
                logString[128];

           	GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);
            new
                house = DOF2_GetInt(ownerFile, "houseID");

            format(filePath, sizeof filePath, "LHouse/Casas/Casa %d.txt", house);

			DestroyVehicle(houseVehicle[house][vehicleHouse]);
			DestroyVehicle(vehicleHouseCarDefined[house]);

			houseVehicle[house][vehicleHouse] = 0;
			houseVehicle[house][vehicleModel] = 0;
			houseVehicle[house][vehicleX] = 0;
			houseVehicle[house][vehicleY] = 0;
			houseVehicle[house][vehicleZ] = 0;
			houseVehicle[house][vehicleColor1] = 0;
			houseVehicle[house][vehicleColor2] = 0;

			DOF2_SetInt(filePath, "Carro", 0, "Veículo");
			DOF2_SetInt(filePath, "Modelo do Carro", 0, "Veículo");
			DOF2_SetFloat(filePath, "Coordenada do Veículo X", 0.0, "Veículo");
			DOF2_SetFloat(filePath, "Coordenada do Veículo Y", 0.0, "Veículo");
			DOF2_SetFloat(filePath, "Coordenada do Veículo Z", 0.0, "Veículo");
			DOF2_SetFloat(filePath, "Angulo", 0.0, "Veículo");
			DOF2_SetInt(filePath, "Cor 1", 0, "Veículo");
			DOF2_SetInt(filePath, "Cor 2", 0, "Veículo");
			DOF2_SetInt(filePath, "Status", 0, "Veículo");
			DOF2_SetString(filePath, "Placa", "LHouse S", "Veículo");
			DOF2_SaveFile();

            carSell = houseVehicle[house][vehiclePrice]/2;
			GivePlayerMoney(playerid, carSell);

			format(string, sizeof string, "* Você vendeu seu carro por: {00EAFA}$%d", carSell);
			SendClientMessage(playerid, COLOR_SUCCESS, string);

            format(logString, sizeof logString, "O jogador %s[%d], vendeu o carro da casa %d.", playerName, playerid, house);
            WriteLog(LOG_VEHICLES, logString);

        }
        case DIALOG_HOUSE_STATUS:
        {
           	new
                filePath[200],
                house = GetProxHouse(playerid);

           	format(filePath, sizeof filePath, "LHouse/Casas/Casa %d.txt", house);

            GetPlayerPos(playerid, X, Y, Z);
            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            if(!response)
            {
                if(houseData[house][houseStatus] == 0)
                {
                    SendClientMessage(playerid, COLOR_ERROR, "* A casa já está destrancada!");
                    PlayerPlaySound(playerid, 1085, X, Y, Z);
                    return 1;
                }

                houseData[house][houseStatus] = 0;

                DOF2_SetInt(filePath, "Status", 0, "Informações");
                DOF2_SaveFile();

                SendClientMessage(playerid, COLOR_SUCCESS, "* Casa destrancada com sucesso");

                new
                    logString[128];

                format(logString, sizeof logString, "O jogador %s[%d], destrancou a casa %d.", playerName, playerid, house);
                WriteLog(LOG_HOUSES, logString);
                Update3DText(house);
            }
            else
            {
                if(houseData[house][houseStatus] == 1)
                {
                    PlayerPlaySound(playerid, 1085, X, Y, Z);
                    SendClientMessage(playerid, COLOR_ERROR, "* A casa já está trancada!");
                    return 1;
                }

                houseData[house][houseStatus] = 1;

                DOF2_SetInt(filePath, "Status", 1, "Informações");
                DOF2_SaveFile();

                SendClientMessage(playerid, COLOR_SUCCESS, "* Casa trancada com sucesso");

                new
                    logString[128];

                format(logString, sizeof logString, "O jogador %s[%d], destrancou a casa %d.", playerName, playerid, house);
                WriteLog(LOG_HOUSES, logString);
                Update3DText(house);
            }
        }
        case DIALOG_SELL_HOUSE:
        {
            if(!response)
                return ShowHouseMenu(playerid);

            new
                housePath[200],
                ownerFile[200],
                tenantFile[200],
                annMessage[128],
                logString[128],
                totalPrice;

            GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

            format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt",playerName);

            new
                house = DOF2_GetInt(ownerFile, "houseID");

            format(tenantFile, sizeof tenantFile, "LHouse/Locadores/%s.txt", houseData[house][houseTenant]);
            format(housePath, sizeof housePath, "LHouse/Casas/Casa %d.txt", house);

            totalPrice = houseData[house][housePrice]/2;

			GivePlayerMoney(playerid, totalPrice);

            format(annMessage, sizeof annMessage, "* Você vendeu sua casa por $%d", totalPrice);
			SendClientMessage(playerid, COLOR_SUCCESS, annMessage);

			houseData[house][houseStatus] = DOF2_SetInt(housePath, "Status", 1, "Informações");
			format(houseData[house][houseOwner], 255, "Ninguem");
			format(houseData[house][houseTenant], 255, "Ninguem");

			DOF2_SetString(housePath, "Dono", "Ninguem", "Informações");
			DOF2_SetString(housePath, "Locador", "Ninguem", "Aluguel");
			DOF2_RemoveFile(ownerFile);

            if(DOF2_FileExists(tenantFile))
                return DOF2_RemoveFile(tenantFile);

			DestroyDynamicPickup(housePickupIn[house]);
			DestroyDynamicMapIcon(houseMapIcon[house]);

			SetPlayerPos(playerid, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);

			Update3DText(house);
			DOF2_SaveFile();

			houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 31, -1, -1, 0, -1, 100.0);
			housePickupIn[house] = CreateDynamicPickup(1273, 23, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);

            format(logString, sizeof logString, "O jogador %s[%d], vendeu a casa %d.", playerName, playerid, house);
            WriteLog(LOG_HOUSES, logString);

        }
    }
    return 0;
}

//================= [COMANDOS CASAS] ==================//
CMD:menucarro(playerid)
{
    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

    new
        Float: X, Float: Y, Float: Z,
        house,
        ownerFile[200];

    format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

    house = DOF2_GetInt(ownerFile, "houseID");

    if(!DOF2_FileExists(ownerFile))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem casa!");
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    if(houseVehicle[house][vehicleModel] == 0)
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Sua casa não tem um veículo!");
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    new
        Float: vehiclePos[3];

    GetVehiclePos(houseVehicle[house][vehicleHouse], vehiclePos[0], vehiclePos[1], vehiclePos[2]);

    if(!IsPlayerInRangeOfPoint(playerid, 20, vehiclePos[0], vehiclePos[1], vehiclePos[2]))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* O veículo está muito longe!");
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    ShowHouseVehicleMenu(playerid);
    return 1;
}

CMD:rebocarcarro(playerid)
{
    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

    new
        Float: X, Float: Y, Float: Z,
        house,
        ownerFile[200];

    format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

    house = DOF2_GetInt(ownerFile, "houseID");

    if(!DOF2_FileExists(ownerFile))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não tem casa!");
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    if(houseVehicle[house][vehicleModel] == 0)
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Sua casa não tem um veículo!");
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    if(GetPlayerMoney(playerid) < houseVehicle[house][vehiclePrice]/20)
    {
        GetPlayerPos(playerid, X, Y, Z);
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        SendClientMessage(playerid, COLOR_ERROR, "* Dinheiro Insuficiente!");
        TogglePlayerControllable(playerid, 1);

        return 1;
    }

    new
        string[128];

    format(string, 128, "Você solicitou o reboque do seu veículo por $%d.", houseVehicle[house][vehiclePrice]/20);
    SendClientMessage(playerid, COLOR_INFO, string);

    SendClientMessage(playerid, COLOR_INFO, "Ele será entregue na sua casa em até 3 minutos nas condições em que for encontrado");

    towRequired[house] = 1;
    GivePlayerMoney(playerid, -houseVehicle[house][vehiclePrice]/20);

    new
        logString[128];

    format(logString, sizeof logString, "O jogador %s[%d], solicitou o reboque do carro da casa %d.", playerName, playerid, house);
    WriteLog(LOG_VEHICLES, logString);

    return 1;
}

CMD:estacionar(playerid)
{
    new
        Float: X, Float: Y, Float: Z;

    GetPlayerPos(playerid, X, Y, Z);

    if(!IsPlayerInAnyVehicle(playerid))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Você não está em nenhum veículo!");
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    else if(carSet[playerid] == 0 && !houseCarSet[playerid] && houseCarSetPos[playerid] == 0)
        return false;

    TogglePlayerControllable(playerid, 1);

    new
        housePath[200],
        vehiclePath[200],
        house,
        vehiclePath2[200],
        vehicleid = GetPlayerVehicleID(playerid);

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

    new
        ownerFile[200];

    format(ownerFile, sizeof ownerFile, "LHouse/Donos/%s.txt", playerName);

    house = DOF2_GetInt(ownerFile, "houseID");

	format(vehiclePath, sizeof vehiclePath, "LHouse/Casas/Casa %d.txt", house);

    if(vehicleid == carSetted[playerid])
    {
        if(carSet[playerid] == 1)
        {
        	format(vehiclePath2, sizeof vehiclePath2, "LHouse/Casas/Casa %d.txt", houseIDReceiveCar);

            new
                Float:PlayerFA;

            GetVehiclePos(carSetted[playerid], X, Y, Z);
            GetVehicleZAngle(carSetted[playerid], PlayerFA);

            carSet[playerid] = 0;

            new
                stringCat[2500];

            strcat(stringCat, "Modelo {FB1300}475 \t{FCEC00}Sabre                      \n");
            strcat(stringCat, "Modelo {FB1300}496 \t{FCEC00}Blista                     \n");
            strcat(stringCat, "Modelo {FB1300}560 \t{FCEC00}Sultan                     \n");
            strcat(stringCat, "Modelo {FB1300}401 \t{FCEC00}Bravura                    \n");
            strcat(stringCat, "Modelo {FB1300}404 \t{FCEC00}Perenniel                  \n");
            strcat(stringCat, "Modelo {FB1300}559 \t{FCEC00}Jester                     \n");
            strcat(stringCat, "Modelo {FB1300}402 \t{FCEC00}Buffalo                    \n");
            strcat(stringCat, "Modelo {FB1300}562 \t{FCEC00}Elegy                      \n");
            strcat(stringCat, "Modelo {FB1300}589 \t{FCEC00}Club                       \n");
            strcat(stringCat, "Modelo {FB1300}603 \t{FCEC00}Phoenix                    \n");
            strcat(stringCat, "Modelo {FB1300}400 \t{FCEC00}Landstalker                \n");
            strcat(stringCat, "Modelo {FB1300}429 \t{FCEC00}Banshee                    \n");
            strcat(stringCat, "Modelo {FB1300}415 \t{FCEC00}Cheetah                    \n");
            strcat(stringCat, "Modelo {FB1300}411 \t{FCEC00}Infernus                   \n");
            strcat(stringCat, "Modelo {FB1300}409 \t{FCEC00}Limosine                   \n");
            strcat(stringCat, "Modelo {FB1300}477 \t{FCEC00}ZR-350                     \n");
            strcat(stringCat, "Modelo {FB1300}506 \t{FCEC00}Super GT                   \n");
            strcat(stringCat, "Modelo {FB1300}541 \t{FCEC00}Bullet                     \n");
            strcat(stringCat, "Modelo {FB1300}451 \t{FCEC00}Turismo                    \n");
            strcat(stringCat, "Modelo {FB1300}468 \t{FCEC00}Sanchez     {FFFFFF} - MOTO\n");
            strcat(stringCat, "Modelo {FB1300}461 \t{FCEC00}PCJ-600     {FFFFFF} - MOTO\n");
            strcat(stringCat, "Modelo {FB1300}521 \t{FCEC00}FCR-900     {FFFFFF} - MOTO\n");
            strcat(stringCat, "Modelo {FB1300}463 \t{FCEC00}Freeway     {FFFFFF} - MOTO\n");
            strcat(stringCat, "Modelo {FB1300}522 \t{FCEC00}NRG-50      {FFFFFF} - MOTO\n");
            ShowPlayerDialog(playerid, DIALOG_CAR_MODELS_CREATED, DIALOG_STYLE_LIST, "{FFFFFF}Escolha um modelo e clique em continuar.", stringCat, "Continuar", "Cancelar");

            houseCarSet[playerid] = false;
    		houseVehicle[houseIDReceiveCar][vehicleX] = X;
    		houseVehicle[houseIDReceiveCar][vehicleY] = Y;
    		houseVehicle[houseIDReceiveCar][vehicleZ] = Z;
            houseVehicle[houseIDReceiveCar][vehicleAngle] = PlayerFA;
			houseVehicle[houseIDReceiveCar][vehicleColor1] = random(255);
			houseVehicle[houseIDReceiveCar][vehicleColor2] = random(255);
			houseVehicle[houseIDReceiveCar][vehicleRespawnTime] = 60*5;
            houseVehicle[houseIDReceiveCar][vehiclePrice] = 15000;

			DOF2_SetFloat(vehiclePath2, "Coordenada do Veículo X", houseVehicle[houseIDReceiveCar][vehicleX], "Veículo");
			DOF2_SetFloat(vehiclePath2, "Coordenada do Veículo Y", houseVehicle[houseIDReceiveCar][vehicleY], "Veículo");
			DOF2_SetFloat(vehiclePath2, "Coordenada do Veículo Z", houseVehicle[houseIDReceiveCar][vehicleZ], "Veículo");
            DOF2_SetFloat(vehiclePath2, "Angulo", houseVehicle[houseIDReceiveCar][vehicleAngle], "Veículo");
			DOF2_SetInt(vehiclePath2, "Cor 1", houseVehicle[houseIDReceiveCar][vehicleColor1], "Veículo");
			DOF2_SetInt(vehiclePath2, "Cor 2", houseVehicle[houseIDReceiveCar][vehicleColor2], "Veículo");
			DOF2_SetInt(vehiclePath2, "Valor", houseVehicle[houseIDReceiveCar][vehiclePrice], "Veículo");
			DOF2_SetInt(vehiclePath2, "Tempo de Respawn", houseVehicle[houseIDReceiveCar][vehicleRespawnTime], "Veículo");
            DOF2_SaveFile();

            adminCreatingVehicle[playerid] = false;
        }
    }
    else if(vehicleid == vehicleHouseCarDefined[house])
    {
        if(houseCarSet[playerid])
        {
            new
                Float:PlayerFA;

            GetVehiclePos(vehicleHouseCarDefined[house], X, Y, Z);
            GetVehicleZAngle(vehicleHouseCarDefined[house], PlayerFA);
            DestroyVehicle(vehicleHouseCarDefined[house]);
            SendClientMessage(playerid, COLOR_INFO, "* Carro salvo com sucesso!");

            houseCarSet[playerid] = false;
    		houseVehicle[house][vehicleX] = X;
    		houseVehicle[house][vehicleY] = Y;
    		houseVehicle[house][vehicleZ] = Z+3;
            houseVehicle[house][vehicleAngle] = PlayerFA;
			houseVehicle[house][vehicleColor1] = 0;
			houseVehicle[house][vehicleColor2] = 0;
			houseVehicle[house][vehicleRespawnTime] = 60*5;
            houseVehicle[house][vehiclePlate] = "LHouse S";

            DOF2_SetString(housePath, "Placa", houseVehicle[house][vehiclePlate], "Veículo");
            houseVehicle[house][vehicleHouse] = CreateVehicle(houseVehicle[house][vehicleModel], X, Y, Z, PlayerFA, 0, 0, 5*60);
    		DOF2_SetInt(vehiclePath, "Modelo do Carro", houseVehicle[house][vehicleModel], "Veículo");
			DOF2_SetFloat(vehiclePath, "Coordenada do Veículo X", houseVehicle[house][vehicleX], "Veículo");
			DOF2_SetFloat(vehiclePath, "Coordenada do Veículo Y", houseVehicle[house][vehicleY], "Veículo");
			DOF2_SetFloat(vehiclePath, "Coordenada do Veículo Z", houseVehicle[house][vehicleZ], "Veículo");
            DOF2_SetFloat(vehiclePath, "Angulo", houseVehicle[house][vehicleAngle], "Veículo");
			DOF2_SetInt(vehiclePath, "Cor 1", houseVehicle[house][vehicleColor1], "Veículo");
			DOF2_SetInt(vehiclePath, "Cor 2", houseVehicle[house][vehicleColor2], "Veículo");
			DOF2_SetInt(vehiclePath, "Valor", houseVehicle[house][vehiclePrice], "Veículo");
			DOF2_SetInt(vehiclePath, "Tempo de Respawn", houseVehicle[house][vehicleRespawnTime], "Veículo");
            DOF2_SaveFile();
        }
    }
    if(houseCarSetPos[playerid] == 1)
    {
        SendClientMessage(playerid, COLOR_INFO, "* Carro salvo com sucesso!");

        new
            CarroP = GetPlayerVehicleID(playerid),
            Float:PlayerFA;

        houseCarSetPos[playerid] = 0;

        GetVehiclePos(CarroP, X, Y, Z);
        GetVehicleZAngle(CarroP, PlayerFA);

    	houseVehicle[house][vehicleX] = X;
    	houseVehicle[house][vehicleY] = Y;
    	houseVehicle[house][vehicleZ] = Z;
        houseVehicle[house][vehicleAngle] = PlayerFA;

		DOF2_SetFloat(vehiclePath, "Coordenada do Veículo X", houseVehicle[house][vehicleX]);
		DOF2_SetFloat(vehiclePath, "Coordenada do Veículo Y", houseVehicle[house][vehicleY]);
		DOF2_SetFloat(vehiclePath, "Coordenada do Veículo Z", houseVehicle[house][vehicleZ]);
        DOF2_SetFloat(vehiclePath, "Angulo", houseVehicle[house][vehicleAngle]);
        DOF2_SaveFile();
    }
    return 1;
}

CMD:ircasa(playerid, params[])
{
    new
        Float: X, Float: Y, Float: Z;

    GetPlayerPos(playerid, X, Y, Z);

    if(!IsPlayerAdmin(playerid))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Sem autorização.");

        GetPlayerPos(playerid, X, Y, Z);
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    new
        house;

    if(sscanf(params, "i", house))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Use: {46FE00}/ircasa {00E5FF}[houseID]");
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    new
        filePath[150];

	format(filePath, sizeof filePath, "LHouse/Casas/Casa %d.txt", house);

    if(!DOF2_FileExists(filePath))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Essa casa não existe!");
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    new
        string[200];

    if(!IsPlayerInAnyVehicle(playerid))
    {
        SetPlayerPos(playerid, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, -1);
    } else {
        new v = GetPlayerVehicleID(playerid);
        SetPlayerPos(playerid, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
        SetVehiclePos(v, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ] + 5);
        SetPlayerInterior(playerid, 0);
        LinkVehicleToInterior(v, 0);
        SetPlayerVirtualWorld(playerid, -1);
        SetVehicleVirtualWorld(v, -1);
        PutPlayerInVehicle(playerid, v, 0);
    }

    format(string, sizeof string, "* Você foi até a casa de ID {00E5FF}%d", house);
    SendClientMessage(playerid, COLOR_INFO, string);

    new
        logString[128];

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
    format(logString, sizeof logString, "O administrador %s[%d], foi até a casa %d.", playerName, playerid, house);
    WriteLog(LOG_ADMIN, logString);

    return 1;
}

CMD:criarcasa(playerid, params[])
{
    ShowCreateHouseDialog(playerid);
    return 1;
}

CMD:criaraqui(playerid, params[])
{
    if (IsPlayerAdmin(playerid))
    {
        if (adminCreatingVehicle[playerid])
        {
            CreateHouseVehicleToPark(playerid);
            return 1;
        }
        else
            return 0;
    }
    else
        return 0;
}

//=========================================== [STOCKS] =============================//
ShowAdminMenu(playerid)
{
    new
        stringCat[1200];

    strcat(stringCat, "Visualizar interior\n");
    strcat(stringCat, "Alterar Preço\n");
    strcat(stringCat, "Alterar Preço Aluguel\n");
    strcat(stringCat, "Alterar Interior\n");
    strcat(stringCat, "Alterar Status\n");
    strcat(stringCat, "Alterar Título\n");
    strcat(stringCat, "Mudar dono\n");
    strcat(stringCat, "Criar Carro\n");
    strcat(stringCat, "{FD0100}Vender casa\n");
    strcat(stringCat, "{FD0100}Deletar casa\n");
    ShowPlayerDialog(playerid, DIALOG_EDIT_HOUSE, DIALOG_STYLE_LIST, "Menu Administrativo", stringCat, "Selecionar", "Cancelar");
    return 1;
}

ShowHouseMenu(playerid)
{
	GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

	new
        house = GetProxHouse(playerid),
        stringCat[1200];

	if(!strcmp(houseData[house][houseOwner], "Ninguem", true))
    {
        ShowPlayerDialog(playerid, DIALOG_HOUSE_SELL_MENU, DIALOG_STYLE_LIST, "Menu house", "Comprar Casa\n", "Selecionar", "Cancelar");
        TogglePlayerControllable(playerid, 0);
    }

    else if(!strcmp(houseData[house][houseOwner], playerName, true))
    {
        strcat(stringCat, "{00FAF7}Entrar em casa\n");
        strcat(stringCat, "{09FD00}Ativar{46FE00}/{FD0300}Desativar {FFFFFF}aluguel da casa\n");
        strcat(stringCat, "{09FD00}Trancar{46FE00}/{FD0300}Destrancar {FFFFFF}a casa\n");
        strcat(stringCat, "Comprar um carro para a casa\n");
        strcat(stringCat, "Vender sua casa\n");
        strcat(stringCat, "Vender sua casa para um player\n");
        strcat(stringCat, "Despejar Locador\n");
        strcat(stringCat, "Alterar Título da casa\n");
        strcat(stringCat, "{0080C0}Armazenamento da casa\n");

        ShowPlayerDialog(playerid, DIALOG_HOUSE_OWNER_MENU, DIALOG_STYLE_LIST, "Menu house", stringCat, "Selecionar", "Cancelar");
        TogglePlayerControllable(playerid, 0);
    }
    else if(strcmp(houseData[house][houseOwner], playerName, true))
    {
        if(houseData[house][houseRentable] == 1)
        {
            if(strcmp(houseData[house][houseTenant], playerName, true))
            {
                strcat(stringCat, "{00FAF7}Entrar na casa\n");
                strcat(stringCat, "Alugar casa\n");
                ShowPlayerDialog(playerid, DIALOG_RENTING_GUEST, DIALOG_STYLE_LIST, "Menu house", stringCat, "Selecionar", "Cancelar");
                TogglePlayerControllable(playerid, 0);
                return 1;
            }

            else
            {
                strcat(stringCat, "{00FAF7}Entrar em casa\n");
                strcat(stringCat, "{09FD00}Trancar{46FE00}/{FD0300}Destrancar {FFFFFF}a casa\n");
                strcat(stringCat, "{FD0100}Desalugar\n");
                ShowPlayerDialog(playerid, DIALOG_HOUSE_TENANT_MENU, DIALOG_STYLE_LIST, "Menu house", stringCat, "Selecionar", "Cancelar");
                TogglePlayerControllable(playerid, 0);
            }
        }
        else
        {
            ShowPlayerDialog(playerid, DIALOG_GUEST, DIALOG_STYLE_MSGBOX, "Menu house", "{FFFFFF}Você deseja entrar nesta casa?", "Sim", "Não");
            TogglePlayerControllable(playerid, 0);
            return 1;
        }
    }

    new
        logString[128];

    format(logString, sizeof logString, "O jogador %s[%d], abriu o menu da casa %d.", playerName, playerid, house);
    WriteLog(LOG_HOUSES, logString);
    return 1;
}

ShowHouseVehicleMenu(playerid)
{
    new
        stringCat[300];

    strcat(stringCat, "Estacionar Carro\n");
    strcat(stringCat, "Mudar cor do carro\n");
    strcat(stringCat, "Escolher novo modelo\n");
    strcat(stringCat, "Mudar Placa\n");
    strcat(stringCat, "Vender Carro\n");
    ShowPlayerDialog(playerid, DIALOG_CAR_MENU, DIALOG_STYLE_LIST, "Menu Carro", stringCat, "Selecionar", "Cancelar");
    return 1;
}

ShowStorageMenu(playerid, type)
{
    //1 = colete
    if (type == 1)
    {
        new
            stringCat[1000],
            string[256],
            slotid,
            house = GetProxHouse(playerid);

        GetPlayerArmour(playerid, oldArmour);

        for(new s; s < MAX_ARMOUR; s++)
        {
            slotid = s + 1;

            if(houseData[house][houseArmourStored][s] > 0)
            {
                format(string, sizeof string, "{FFFFFF}SLOT {46FE00}%d{FFFFFF}:\t\t%.2f%%\n", slotid, houseData[house][houseArmourStored][s]);
                strcat(stringCat, string);
            }
            else if(houseData[house][houseArmourStored][s] == 0)
            {
                format(string, sizeof string, "{FFFFFF}SLOT {46FE00}%d{FFFFFF}:\t\t{FFFFFF}VAZIO\n", slotid);
                strcat(stringCat, string);
            }
        }
        ShowPlayerDialog(playerid, DIALOG_STORAGE_ARMOUR, DIALOG_STYLE_LIST, "{00F2FC}Coletes armazenados.", stringCat, "Equipar", "Voltar");
    }
    return 1;
}

ShowCreateHouseDialog(playerid)
{
    new
        Float: X, Float: Y, Float: Z;

    if(!IsPlayerAdmin(playerid))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Sem autorização.");

        GetPlayerPos(playerid, X, Y, Z);
        PlayerPlaySound(playerid, 1085, X, Y, Z);
        return 1;
    }

    new
        stringCat[1200];

    strcat(stringCat, "Interior {FB1300}1 \t{FCEC00}6 {FFFFFF}Comodos \t\t{00EAFA}R$ 65.000,00 \n");
    strcat(stringCat, "Interior {FB1300}2 \t{FCEC00}3 {FFFFFF}Comodos \t\t{00EAFA}R$ 37.000,00 \n");
    strcat(stringCat, "Interior {FB1300}3 \t{FCEC00}3 {FFFFFF}Comodos \t\t{00EAFA}R$ 37.000,00 \n");
    strcat(stringCat, "Interior {FB1300}4 \t{FCEC00}1 {FFFFFF}Comodo  \t\t{00EAFA}R$ 20.000,00 \n");
    strcat(stringCat, "Interior {FB1300}5 \t{FCEC00}1 {FFFFFF}Comodo  \t\t{00EAFA}R$ 20.000,00 \n");
    strcat(stringCat, "Interior {FB1300}6 \t{FCEC00}3 {FFFFFF}Comodos \t\t{00EAFA}R$ 150.000,00 {FFFFFF}| (Casa do CJ)\n");
    strcat(stringCat, "Interior {FB1300}7 \t{FCEC00}5 {FFFFFF}Comodos \t\t{00EAFA}R$ 320.000,00 \n");
    strcat(stringCat, "Interior {FB1300}8 \t{FCEC00}7 {FFFFFF}Comodos \t\t{00EAFA}R$ 120.000,00 \n");
    strcat(stringCat, "Interior {FB1300}9 \t{FCEC00}4 {FFFFFF}Comodos \t\t{00EAFA}R$ 95.000,00 \n");
    strcat(stringCat, "Interior {FB1300}10 \t{FCEC00}Muitos {FFFFFF}Comodos \t{00EAFA}R$ 1.200.000,00 {FFFFFF}| (Casa do Madd Dog)\n");
    strcat(stringCat, "Interior {FB1300}11 \t{FCEC00}7 {FFFFFF}Comodos \t\t{00EAFA}R$ 660.000,00 \n");
    ShowPlayerDialog(playerid, DIALOG_CREATE_HOUSE, DIALOG_STYLE_LIST,"Criando Casa", stringCat, "Continuar", "Cancelar");
    return 1;
}

CreateHouse(house, Float:PickupX, Float:PickupY, Float:PickupZ, Float:InteriorX, Float:InteriorY, Float:InteriorZ, Float:InteriorFA, houseValue, houseInt)
{
	new
        storageFile[100],
        file[100];

	format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);
    format(storageFile, sizeof storageFile, "LHouse/Armazenamento/Casa %d.txt", house);

	if(!DOF2_FileExists(file))
    {
        format(houseData[house][houseOwner], 24, "Ninguem");
        format(houseData[house][houseTenant], 24, "Ninguem");
        format(houseData[house][houseTitle], 32, "Título não definido");

        houseData[house][houseX] = PickupX;
        houseData[house][houseY] = PickupY;
        houseData[house][houseZ] = PickupZ;
        houseData[house][houseIntX] = InteriorX;
        houseData[house][houseIntY] = InteriorY;
        houseData[house][houseIntZ] = InteriorZ;
        houseData[house][houseIntFA] = InteriorFA;
        houseData[house][houseInterior] = houseInt;
        houseData[house][housePrice] = houseValue;
        houseData[house][houseVirtualWorld] = house;
        houseData[house][houseStatus] = 1;
        houseData[house][houseRentable] = 0;
        houseData[house][houseRentPrice] = 0;
        houseVehicle[house][vehicleHouse] = 0;
        houseVehicle[house][vehicleModel] = 0;
        houseVehicle[house][vehicleX] = 0;
        houseVehicle[house][vehicleY] = 0;
        houseVehicle[house][vehicleZ] = 0;
        houseVehicle[house][vehicleColor1] = 0;
        houseVehicle[house][vehicleColor2] = 0;
        houseVehicle[house][vehiclePrice] = 0;

        DOF2_CreateFile(file);

        DOF2_SetInt(file, "ID", house, "Informações");
        DOF2_SetInt(file, "Preço", houseValue, "Informações");
        DOF2_SetString(file, "Dono", "Ninguem", "Informações");
        DOF2_SetString(file, "Título", "Título não definido", "Informações");
        DOF2_SetInt(file, "Status", 1, "Informações");

        DOF2_SetInt(file, "Aluguel Ativado", 0, "Aluguel");
        DOF2_SetInt(file, "Preço do Aluguel", 0, "Aluguel");
        DOF2_SetString(file, "Locador", "Ninguem", "Aluguel");

        DOF2_SetInt(file, "Interior", houseInt, "Coordenadas");
        DOF2_SetFloat(file, "Exterior X", PickupX, "Coordenadas");
        DOF2_SetFloat(file, "Exterior Y", PickupY, "Coordenadas");
        DOF2_SetFloat(file, "Exterior Z", PickupZ, "Coordenadas");
        DOF2_SetFloat(file, "Interior X", InteriorX, "Coordenadas");
        DOF2_SetFloat(file, "Interior Y", InteriorY, "Coordenadas");
        DOF2_SetFloat(file, "Interior Z", InteriorZ, "Coordenadas");
        DOF2_SetFloat(file, "Interior Facing Angle", InteriorFA, "Coordenadas");
        DOF2_SetInt(file, "Virtual World", house, "Coordenadas");

        DOF2_SetInt(file, "Modelo do Carro", 0, "Veículo");
        DOF2_SetFloat(file, "Coordenada do Veículo X", 0, "Veículo");
        DOF2_SetFloat(file, "Coordenada do Veículo Y", 0, "Veículo");
        DOF2_SetFloat(file, "Coordenada do Veículo Z", 0, "Veículo");
        DOF2_SetFloat(file, "Angulo", 0, "Veículo");
        DOF2_SetInt(file, "Cor 1", 0, "Veículo");
        DOF2_SetInt(file, "Cor 2", 0, "Veículo");
    	DOF2_SetInt(file, "Valor", 0, "Veículo");
        DOF2_SetInt(file, "Tempo de Respawn", 0, "Veículo");
        DOF2_SetString(file, "Placa", "LHouse", "Veículo");

        DOF2_SaveFile();

        DOF2_CreateFile(storageFile);

        new
            slotStorageID[20];

        for(new s; s < MAX_ARMOUR; s++)
        {
            format(slotStorageID, sizeof slotStorageID, "SLOT %d", s);
            DOF2_SetFloat(storageFile, slotStorageID, 0, "Colete");
        }

        DOF2_SaveFile();
    }
    else
    {
	    houseData[house][housePrice] = DOF2_GetInt(file, "Preço", "Informações");
        format(houseData[house][houseOwner], 24, DOF2_GetString(file, "Dono", "Informações"));
        format(houseData[house][houseTitle], 32, DOF2_GetString(file, "Título", "Informações"));
        houseData[house][houseStatus] = DOF2_GetInt(file, "Status", "Informações");

        houseData[house][houseRentable] = DOF2_GetInt(file, "Aluguel Ativado", "Aluguel");
        houseData[house][houseRentPrice] = DOF2_GetInt(file, "Preço do Aluguel", "Aluguel");
        format(houseData[house][houseTenant], 24, DOF2_GetString(file, "Locador", "Aluguel"));

        houseData[house][houseX] = DOF2_GetFloat(file, "Exterior X", "Coordenadas");
        houseData[house][houseY] = DOF2_GetFloat(file, "Exterior Y", "Coordenadas");
        houseData[house][houseZ] = DOF2_GetFloat(file, "Exterior Z", "Coordenadas");
        houseData[house][houseIntX] = DOF2_GetFloat(file, "Interior X", "Coordenadas");
        houseData[house][houseIntY] = DOF2_GetFloat(file, "Interior Y", "Coordenadas");
        houseData[house][houseIntZ] = DOF2_GetFloat(file, "Interior Z", "Coordenadas");
        houseData[house][houseInterior] = DOF2_GetInt(file, "Interior", "Coordenadas");
        houseData[house][houseVirtualWorld] = DOF2_GetInt(file, "Virtual World", "Coordenadas");

        new
            slotStorageID[20],
            Float:valueOnFile;

        if(!DOF2_FileExists(storageFile))
            DOF2_CreateFile(storageFile);

        for(new s; s < MAX_ARMOUR; s++)
        {
            format(slotStorageID, sizeof slotStorageID, "SLOT %d", s);

            if(!DOF2_IsSet(storageFile, slotStorageID, "Colete"))
                DOF2_SetFloat(storageFile, slotStorageID, 0, "Colete");

            valueOnFile = DOF2_GetFloat(storageFile, slotStorageID, "Colete");

            if(valueOnFile != 0)
                houseData[house][houseArmourStored][s] = valueOnFile;
        }

    }

    new
        houseStatusName[20],
        houseRentName[20],
        textlabel[200];

    if(!strcmp(houseData[house][houseOwner], "Ninguem", true))
    {
		housePickupIn[house] = CreateDynamicPickup(1273, 1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
        housePickupOut[house] = CreateDynamicPickup(1318, 1, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
 		houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 31, -1, -1, 0, -1, 100.0);
        if(houseData[house][houseStatus] == 1) houseStatusName = "Trancada";
        else if(houseData[house][houseStatus] == 0) houseStatusName = "Destrancada";
        format(textlabel, sizeof textlabel, TEXT_SELLING_HOUSE, houseData[house][housePrice], house);
        houseLabel[house] = CreateDynamic3DTextLabel(textlabel, -1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 20.0);
    }
    else
	{
        if(houseData[house][houseRentable] == 1)
        {
    		housePickupIn[house] = CreateDynamicPickup(1272, 1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
            housePickupOut[house] = CreateDynamicPickup(1318, 1, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
            houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 32, -1, -1, 0, -1, 100.0);
            if(houseData[house][houseStatus] == 1) houseStatusName = "Trancada";
            else if(houseData[house][houseStatus] == 0) houseStatusName = "Destrancada";
            format(textlabel, sizeof textlabel, TEXT_RENT_HOUSE, houseData[house][houseTitle], houseData[house][houseOwner], houseData[house][houseTenant], houseData[house][houseRentPrice], houseStatusName, house);
            houseLabel[house] = CreateDynamic3DTextLabel(textlabel, -1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 20.0);
            return 1;
        }

        else
        {
    		housePickupIn[house] = CreateDynamicPickup(1272, 1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
            housePickupOut[house] = CreateDynamicPickup(1318, 1, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
            houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 32, -1, -1, 0, -1, 100.0);
            if(houseData[house][houseStatus] == 1) houseStatusName = "Trancada";
            else if(houseData[house][houseStatus] == 0) houseStatusName = "Destrancada";
            if(houseData[house][houseRentable] == 1) houseRentName = "Ativado";
            else if(houseData[house][houseRentable] == 0) houseRentName = "Desativado";
            format(textlabel, sizeof textlabel, TEXT_HOUSE, houseData[house][houseTitle], houseData[house][houseOwner], houseRentName, houseStatusName, house);
            houseLabel[house] = CreateDynamic3DTextLabel(textlabel, -1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 20.0);
            return 1;
        }
    }

    new
        logString[128];

    format(logString, sizeof logString, "-------- A CASA DE ID %d FOI CRIADA COM SUCESSO! --------", house);
    WriteLog(LOG_SYSTEM, logString);
    return 1;
}

public SaveHouses()
{
    new
        storageFile[100],
        file[200];

    for(new house = 1; house < MAX_HOUSES; house++)
    {
        format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);
        format(storageFile, sizeof storageFile, "LHouse/Armazenamento/Casa %d.txt", house);

        if(DOF2_FileExists(file))
        {
            DOF2_SetInt(file, "ID", house, "Informações");
            DOF2_SetInt(file, "Preço", houseData[house][housePrice], "Informações");
            DOF2_SetString(file, "Dono", houseData[house][houseOwner], "Informações");
            DOF2_SetString(file, "Título", houseData[house][houseTitle], "Informações");
            DOF2_SetInt(file, "Status", houseData[house][houseStatus], "Informações");

            DOF2_SetString(file, "Locador", houseData[house][houseTenant], "Aluguel");
            DOF2_SetInt(file, "Aluguel Ativado", houseData[house][houseRentable], "Aluguel");
            DOF2_SetInt(file, "Preço do Aluguel", houseData[house][houseRentPrice], "Aluguel");

            DOF2_SetInt(file, "Interior", houseData[house][houseInterior], "Coordenadas");
            DOF2_SetFloat(file, "Exterior X", houseData[house][houseX], "Coordenadas");
            DOF2_SetFloat(file, "Exterior Y", houseData[house][houseY], "Coordenadas");
            DOF2_SetFloat(file, "Exterior Z", houseData[house][houseZ], "Coordenadas");
            DOF2_SetFloat(file, "Interior X", houseData[house][houseIntX], "Coordenadas");
            DOF2_SetFloat(file, "Interior Y", houseData[house][houseIntY], "Coordenadas");
            DOF2_SetFloat(file, "Interior Z", houseData[house][houseIntZ], "Coordenadas");
            DOF2_SetFloat(file, "Interior Facing Angle", houseData[house][houseIntFA], "Coordenadas");
            DOF2_SetInt(file, "Virtual World", houseData[house][houseVirtualWorld], "Coordenadas");

    		DOF2_SetInt(file, "Modelo do Carro", houseVehicle[house][vehicleModel], "Veículo");
			DOF2_SetFloat(file, "Coordenada do Veículo X", houseVehicle[house][vehicleX], "Veículo");
			DOF2_SetFloat(file, "Coordenada do Veículo Y", houseVehicle[house][vehicleY], "Veículo");
			DOF2_SetFloat(file, "Coordenada do Veículo Z", houseVehicle[house][vehicleZ], "Veículo");
            DOF2_SetFloat(file, "Angulo", houseVehicle[house][vehicleAngle], "Veículo");
			DOF2_SetInt(file, "Cor 1", houseVehicle[house][vehicleColor1], "Veículo");
			DOF2_SetInt(file, "Cor 2", houseVehicle[house][vehicleColor2], "Veículo");
            DOF2_SetInt(file, "Status do Carro", houseVehicle[house][vehicleStatus], "Veículo");
			DOF2_SetInt(file, "Valor", houseVehicle[house][vehiclePrice], "Veículo");
			DOF2_SetInt(file, "Tempo de Respawn", houseVehicle[house][vehicleRespawnTime], "Veículo");
            DOF2_SetString(file, "Placa", houseVehicle[house][vehiclePlate], "Veículo");

            DOF2_SaveFile();

            if(!DOF2_FileExists(storageFile))
                DOF2_CreateFile(storageFile);

            new
                slotStorageID[20];

            for(new s; s < MAX_ARMOUR; s++)
            {
                format(slotStorageID, sizeof slotStorageID, "SLOT %d", s);
                DOF2_SetFloat(storageFile, slotStorageID, houseData[house][houseArmourStored][s], "Colete");
            }

            DOF2_SaveFile();

            return 1;
        }
    }
    return 1;
}

public SaveHouse(house)
{
    new
        storageFile[100],
        file[200];

    format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);
    format(storageFile, sizeof storageFile, "LHouse/Armazenamento/Casa %d.txt", house);

    if(DOF2_FileExists(file))
    {
        DOF2_SetInt(file, "ID", house, "Informações");
        DOF2_SetInt(file, "Preço", houseData[house][housePrice], "Informações");
        DOF2_SetString(file, "Dono", houseData[house][houseOwner], "Informações");
        DOF2_SetString(file, "Título", houseData[house][houseTitle], "Informações");
        DOF2_SetInt(file, "Status", houseData[house][houseStatus], "Informações");

        DOF2_SetString(file, "Locador", houseData[house][houseTenant], "Aluguel");
        DOF2_SetInt(file, "Aluguel Ativado", houseData[house][houseRentable], "Aluguel");
        DOF2_SetInt(file, "Preço do Aluguel", houseData[house][houseRentPrice], "Aluguel");

        DOF2_SetInt(file, "Interior", houseData[house][houseInterior], "Coordenadas");
        DOF2_SetFloat(file, "Exterior X", houseData[house][houseX], "Coordenadas");
        DOF2_SetFloat(file, "Exterior Y", houseData[house][houseY], "Coordenadas");
        DOF2_SetFloat(file, "Exterior Z", houseData[house][houseZ], "Coordenadas");
        DOF2_SetFloat(file, "Interior X", houseData[house][houseIntX], "Coordenadas");
        DOF2_SetFloat(file, "Interior Y", houseData[house][houseIntY], "Coordenadas");
        DOF2_SetFloat(file, "Interior Z", houseData[house][houseIntZ], "Coordenadas");
        DOF2_SetFloat(file, "Interior Facing Angle", houseData[house][houseIntFA], "Coordenadas");
        DOF2_SetInt(file, "Virtual World", houseData[house][houseVirtualWorld], "Coordenadas");

        DOF2_SetInt(file, "Modelo do Carro", houseVehicle[house][vehicleModel], "Veículo");
        DOF2_SetFloat(file, "Coordenada do Veículo X", houseVehicle[house][vehicleX], "Veículo");
        DOF2_SetFloat(file, "Coordenada do Veículo Y", houseVehicle[house][vehicleY], "Veículo");
        DOF2_SetFloat(file, "Coordenada do Veículo Z", houseVehicle[house][vehicleZ], "Veículo");
        DOF2_SetFloat(file, "Angulo", houseVehicle[house][vehicleAngle], "Veículo");
        DOF2_SetInt(file, "Cor 1", houseVehicle[house][vehicleColor1], "Veículo");
        DOF2_SetInt(file, "Cor 2", houseVehicle[house][vehicleColor2], "Veículo");
        DOF2_SetInt(file, "Status do Carro", houseVehicle[house][vehicleStatus], "Veículo");
        DOF2_SetInt(file, "Valor", houseVehicle[house][vehiclePrice], "Veículo");
        DOF2_SetInt(file, "Tempo de Respawn", houseVehicle[house][vehicleRespawnTime], "Veículo");
        DOF2_SetString(file, "Placa", houseVehicle[house][vehiclePlate], "Veículo");

        DOF2_SaveFile();

        if(!DOF2_FileExists(storageFile))
            DOF2_CreateFile(storageFile);

        new
            slotStorageID[20];

        for(new s; s < MAX_ARMOUR; s++)
        {
            format(slotStorageID, sizeof slotStorageID, "SLOT %d", s);
            DOF2_SetFloat(storageFile, slotStorageID, houseData[house][houseArmourStored][s], "Colete");
        }

        DOF2_SaveFile();

        return 1;
    }
    return 1;
}

GetProxHouse(playerid)
{
    for(new i = 1; i < MAX_HOUSES; i++)
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2, houseData[i][houseX], houseData[i][houseY], houseData[i][houseZ]))
	    {
	        return i;
		}
	    else if(IsPlayerInRangeOfPoint(playerid, 2, houseData[i][houseIntX], houseData[i][houseIntY], houseData[i][houseIntZ]))
	    {
	        return i;
		}
	}
	return -255;
}

GetHouseByOwner(playerid)
{
    new
        ownerFilePath[200],
        house;

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
    format(ownerFilePath, sizeof ownerFilePath, "LHouse/Donos/%s.txt", playerName);

    if(!DOF2_FileExists(ownerFilePath))
        return -255;

    house = DOF2_GetInt(ownerFilePath, "houseID");
    return house;
}

CreateAllHousesVehicles()
{
    new
        vehiclesCreated,
        houseStatusName[20],
        vehiclePath[128],
        logString[128],
        engine,lights,alarm,doors,bonnet,boot,objective;

    for(new houses = 1; houses < MAX_HOUSES; houses++)
    {
	    format(vehiclePath, sizeof vehiclePath, "LHouse/Casas/Casa %d.txt", houses);
		if(DOF2_GetInt(vehiclePath, "Modelo do Carro", "Veículo") != 0)
		{
            houseVehicle[houses][vehicleModel] = DOF2_GetInt(vehiclePath, "Modelo do Carro", "Veículo");
    	    houseVehicle[houses][vehicleX] = DOF2_GetFloat(vehiclePath, "Coordenada do Veículo X", "Veículo");
        	houseVehicle[houses][vehicleY] = DOF2_GetFloat(vehiclePath, "Coordenada do Veículo Y", "Veículo");
        	houseVehicle[houses][vehicleZ] = DOF2_GetFloat(vehiclePath, "Coordenada do Veículo Z", "Veículo");
        	houseVehicle[houses][vehicleAngle] = DOF2_GetFloat(vehiclePath, "Angulo", "Veículo");
        	houseVehicle[houses][vehicleColor1] = DOF2_GetInt(vehiclePath, "Cor 1", "Veículo");
        	houseVehicle[houses][vehicleColor2] = DOF2_GetInt(vehiclePath, "Cor 2", "Veículo");
            houseVehicle[houses][vehiclePrice] = DOF2_GetInt(vehiclePath, "Valor", "Veículo");
        	houseVehicle[houses][vehicleRespawnTime] = DOF2_GetInt(vehiclePath, "Tempo de Respawn", "Veículo");
            houseVehicle[houses][vehicleStatus] = DOF2_GetInt(vehiclePath, "Status do Carro", "Veículo");
    	    format(houseVehicle[houses][vehiclePlate], 10, DOF2_GetString(vehiclePath, "Placa", "Veículo"));
            houseVehicle[houses][vehicleHouse] = CreateVehicle(houseVehicle[houses][vehicleModel], houseVehicle[houses][vehicleX], houseVehicle[houses][vehicleY], houseVehicle[houses][vehicleZ], houseVehicle[houses][vehicleAngle], houseVehicle[houses][vehicleColor1], houseVehicle[houses][vehicleColor2], houseVehicle[houses][vehicleRespawnTime]);
            SetVehicleNumberPlate(houseVehicle[houses][vehicleHouse], houseVehicle[houses][vehiclePlate]);
            vehiclesCreated++;

			if(houseVehicle[houses][vehicleStatus] == 1)
                houseStatusName = "Trancado";

			else if(houseVehicle[houses][vehicleStatus] == 0)
                houseStatusName = "Destrancado";

            format(logString, sizeof logString, "-------- O CARRO DA CASA DE ID %d FOI CRIADO COM SUCESSO! --------", houses);
            WriteLog(LOG_SYSTEM, logString);

            GetVehicleParamsEx(houseVehicle[houses][vehicleHouse], engine, lights, alarm, doors, bonnet, boot, objective);
            if(houseVehicle[houses][vehicleStatus] == 1)
            {
                SetVehicleParamsEx(houseVehicle[houses][vehicleHouse], engine, lights, alarm, 1, bonnet, boot, objective);
            }
            else
            {
                SetVehicleParamsEx(houseVehicle[houses][vehicleHouse], engine, lights, alarm, 0, bonnet, boot, objective);
            }
        }
    }
    if(vehiclesCreated == 0)
    {
        print("\n\t Não foi detectado nenhum carro de casa criado. ");
        print("\t Para criar um, logue no servidor, entre na RCON  ");
        print("\t e abra o menu administrativo da casa.            ");
    }
    else
    {
        printf("\t Foram criados %d carros.                                 ", vehiclesCreated);
    }
    return 1;
}

CreateAllHouses()
{
    new
        housesCreated,
        file[200],
        houseStatusName[20],
        textlabel[250],
        houseRentName[20],
        storageFile[100],
        logString[700];

    for(new house = 1; house < MAX_HOUSES; house++)
    {
	    format(file, sizeof file, "LHouse/Casas/Casa %d.txt", house);
        format(storageFile, sizeof storageFile, "LHouse/Armazenamento/Casa %d.txt", house);

		if(DOF2_FileExists(file))
		{
            houseData[house][housePrice] = DOF2_GetInt(file, "Preço", "Informações");
            houseData[house][houseStatus] = DOF2_GetInt(file, "Status", "Informações");
            format(houseData[house][houseOwner], 24, DOF2_GetString(file, "Dono", "Informações"));
            format(houseData[house][houseTitle], 32, DOF2_GetString(file, "Título", "Informações"));

            houseData[house][houseRentable] = DOF2_GetInt(file, "Aluguel Ativado", "Aluguel");
            houseData[house][houseRentPrice] = DOF2_GetInt(file, "Preço do Aluguel", "Aluguel");
            format(houseData[house][houseTenant], 24, DOF2_GetString(file, "Locador", "Aluguel"));

            houseData[house][houseX] = DOF2_GetFloat(file, "Exterior X", "Coordenadas");
            houseData[house][houseY] = DOF2_GetFloat(file, "Exterior Y", "Coordenadas");
            houseData[house][houseZ] = DOF2_GetFloat(file, "Exterior Z", "Coordenadas");
            houseData[house][houseIntX] = DOF2_GetFloat(file, "Interior X", "Coordenadas");
            houseData[house][houseIntY] = DOF2_GetFloat(file, "Interior Y", "Coordenadas");
            houseData[house][houseIntZ] = DOF2_GetFloat(file, "Interior Z", "Coordenadas");
            houseData[house][houseVirtualWorld] = DOF2_GetInt(file, "Virtual World", "Coordenadas");
            houseData[house][houseInterior] = DOF2_GetInt(file, "Interior", "Coordenadas");

            if(!DOF2_FileExists(storageFile))
                DOF2_CreateFile(storageFile);

            new
                slotStorageID[20],
                Float:valueOnFile;

            for(new s; s < MAX_ARMOUR; s++)
            {
                format(slotStorageID, sizeof slotStorageID, "SLOT %d", s);

                if(!DOF2_IsSet(storageFile, slotStorageID, "Colete"))
                    DOF2_SetFloat(storageFile, slotStorageID, 0, "Colete");

                valueOnFile = DOF2_GetFloat(storageFile, slotStorageID, "Colete");

                if(valueOnFile != 0)
                    houseData[house][houseArmourStored][s] = valueOnFile;
            }

            if(houseData[house][houseStatus] == 1)
                houseStatusName = "Trancada";

            else if(houseData[house][houseStatus] == 0)
                houseStatusName = "Destrancada";

            if(houseData[house][houseRentable] == 1)
                houseRentName = "Ativado";

            else if(houseData[house][houseRentable] == 0)
                houseRentName = "Desativado";

            housesCreated++;

            format(logString, sizeof logString, "-------- A CASA DE ID %d FOI CRIADA COM SUCESSO! --------", house);
            WriteLog(LOG_SYSTEM, logString);

            if(!strcmp(houseData[house][houseOwner], "Ninguem", true))
            {
		        housePickupIn[house] = CreateDynamicPickup(1273, 1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
                housePickupOut[house] = CreateDynamicPickup(1318, 1, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
 		        houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 31, -1, -1, 0, -1, 100.0);
                format(textlabel, sizeof textlabel, TEXT_SELLING_HOUSE, houseData[house][housePrice], house);
                houseLabel[house] = CreateDynamic3DTextLabel(textlabel, -1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 20.0);
            }
            else
	        {
                if(houseData[house][houseRentable] == 1)
                {
    		        housePickupIn[house] = CreateDynamicPickup(1272, 1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
                    housePickupOut[house] = CreateDynamicPickup(1318, 1, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
                    houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 32, -1, -1, 0, -1, 100.0);
                    format(textlabel, sizeof textlabel, TEXT_RENT_HOUSE, houseData[house][houseTitle], houseData[house][houseOwner], houseData[house][houseTenant], houseData[house][houseRentPrice], houseStatusName, house);
                    houseLabel[house] = CreateDynamic3DTextLabel(textlabel, -1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 20.0);
                }
                else
                {
    		        housePickupIn[house] = CreateDynamicPickup(1272, 1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ]);
                    housePickupOut[house] = CreateDynamicPickup(1318, 1, houseData[house][houseIntX], houseData[house][houseIntY], houseData[house][houseIntZ]);
                    houseMapIcon[house] = CreateDynamicMapIcon(houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 32, -1, -1, 0, -1, 100.0);
                    format(textlabel, sizeof textlabel, TEXT_HOUSE, houseData[house][houseTitle], houseData[house][houseOwner], houseRentName, houseStatusName, house);
                    houseLabel[house] = CreateDynamic3DTextLabel(textlabel, -1, houseData[house][houseX], houseData[house][houseY], houseData[house][houseZ], 20.0);
                }
            }
        }
    }
    if(housesCreated == 0)
    {
        print("\n\n\t========================= LHOUSE ========================");
        print("\t Não foi detectado nenhuma casa criada.                  ");
        print("\t Para criar uma, logue no servidor, entre na RCON        ");
        print("\t e digite /criarcasa.                                   ");
    }
    else
    {
        print("\n\n\t========================= LHOUSE ========================");
        printf("\t Foram criadas %d casa(s).                                ", housesCreated);
    }
    return 1;
}

IsNumeric(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}

HouseVehicleDelivery(playerid)
{
    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

    new
        house = GetHouseByOwner(playerid),
        logString[128];

    format(logString, sizeof logString, "O jogador %s[%d], comprou um carro novo para a casa %d.", playerName, playerid, house);
    WriteLog(LOG_VEHICLES, logString);

    #if LHOUSE_CITY == 1
    	#if LHOUSE_DELIVERY_METHOD == 1
    		new
                rand = random(sizeof vehicleRandomSpawnLS);

    		houseCarSet[playerid] = true;
    		vehicleHouseCarDefined[house] = CreateVehicle(houseVehicle[house][vehicleModel], vehicleRandomSpawnLS[rand][0], vehicleRandomSpawnLS[rand][1], vehicleRandomSpawnLS[rand][2], vehicleRandomSpawnLS[rand][3], 0, 0, 5*60);
    		PutPlayerInVehicle(playerid, vehicleHouseCarDefined[house], 0);
    		SendClientMessage(playerid, COLOR_INFO, "* Estacione seu carro aonde quer que ele de spawn e digite {46FE00}/estacionar");

    		return 1;
    	#else
    		new
                rand = random(sizeof vehicleRandomSpawnLS);

    		houseCarSet[playerid] = true;
    		vehicleHouseCarDefined[house] = CreateVehicle(houseVehicle[house][vehicleModel], vehicleRandomSpawnLS[rand][0], vehicleRandomSpawnLS[rand][1], vehicleRandomSpawnLS[rand][2], vehicleRandomSpawnLS[rand][3], 0, 0, 5*60);
    		SendClientMessage(playerid, COLOR_INFO, "* Vá buscar seu carro na concessionária grotti.");

    		return 1;
    	#endif
	#elseif LHOUSE_CITY == 2
    	#if LHOUSE_DELIVERY_METHOD == 1
    		new
                rand = random(sizeof vehicleRandomSpawnSF);

    		houseCarSet[playerid] = true;
    		vehicleHouseCarDefined[house] = CreateVehicle(houseVehicle[house][vehicleModel], vehicleRandomSpawnSF[rand][0], vehicleRandomSpawnSF[rand][1], vehicleRandomSpawnSF[rand][2], vehicleRandomSpawnSF[rand][3], 0, 0, 5*60);
    		PutPlayerInVehicle(playerid, vehicleHouseCarDefined[house], 0);
    		SendClientMessage(playerid, COLOR_INFO, "* Estacione seu carro aonde quer que ele de spawn e digite {46FE00}/estacionar");

    		return 1;
    	#else
    		new
                rand = random(sizeof vehicleRandomSpawnSF);
    		houseCarSet[playerid] = true;
    		vehicleHouseCarDefined[house] = CreateVehicle(houseVehicle[house][vehicleModel], vehicleRandomSpawnSF[rand][0], vehicleRandomSpawnSF[rand][1], vehicleRandomSpawnSF[rand][2], vehicleRandomSpawnSF[rand][3], 0, 0, 5*60);
    		SendClientMessage(playerid, COLOR_INFO, "* Vá buscar seu carro na concessionária Otto's Auto.");

    		return 1;
    	#endif
	#else
	   #if LHOUSE_DELIVERY_METHOD == 1
    		new
                rand = random(sizeof vehicleRandomSpawnLV);

    		houseCarSet[playerid] = true;
    		vehicleHouseCarDefined[house] = CreateVehicle(houseVehicle[house][vehicleModel], vehicleRandomSpawnLV[rand][0], vehicleRandomSpawnLV[rand][1], vehicleRandomSpawnLV[rand][2], vehicleRandomSpawnLV[rand][3], 0, 0, 5*60);
    		PutPlayerInVehicle(playerid, vehicleHouseCarDefined[house], 0);
    		SendClientMessage(playerid, COLOR_INFO, "* Estacione seu carro aonde quer que ele de spawn e digite {46FE00}/estacionar");

    		return 1;
    	#else
    		new
                rand = random(sizeof vehicleRandomSpawnLV);

    		houseCarSet[playerid] = true;
    		vehicleHouseCarDefined[house] = CreateVehicle(houseVehicle[house][vehicleModel], vehicleRandomSpawnLV[rand][0], vehicleRandomSpawnLV[rand][1], vehicleRandomSpawnLV[rand][2], vehicleRandomSpawnLV[rand][3], 0, 0, 5*60);
    		SendClientMessage(playerid, COLOR_INFO, "* Vá buscar seu carro na Auto Bahn.");

    		return 1;
    	#endif
	#endif
}

Update3DText(house)
{
    new
        houseRentName[20],
        textlabel[200],
        houseStatusName[20];

    if(!strcmp(houseData[house][houseOwner], "Ninguem", true))
    {
        if(houseData[house][houseStatus] == 1)
            houseStatusName = "Trancada";

        else if(houseData[house][houseStatus] == 0)
            houseStatusName = "Destrancada";

        format(textlabel, sizeof textlabel, TEXT_SELLING_HOUSE, houseData[house][housePrice], house);
        UpdateDynamic3DTextLabelText(houseLabel[house], -1, textlabel);
        return 1;
    }

    else if(strcmp(houseData[house][houseOwner], "Ninguem", true))
    {
        if(houseData[house][houseRentable] == 1)
        {
            if(houseData[house][houseStatus] == 1)
                houseStatusName = "Trancada";

            else if(houseData[house][houseStatus] == 0)
                houseStatusName = "Destrancada";

            format(textlabel, sizeof textlabel, TEXT_RENT_HOUSE, houseData[house][houseTitle], houseData[house][houseOwner], houseData[house][houseTenant], houseData[house][houseRentPrice], houseStatusName, house);
            UpdateDynamic3DTextLabelText(houseLabel[house], -1, textlabel);
            return 1;
        }
        else
        {
            if(houseData[house][houseStatus] == 1)
                houseStatusName = "Trancada";

            else if(houseData[house][houseStatus] == 0)
                houseStatusName = "Destrancada";

            if(houseData[house][houseRentable] == 1)
                houseRentName = "Ativado";

            else if(houseData[house][houseRentable] == 0)
                houseRentName = "Desativado";

            format(textlabel, sizeof textlabel, TEXT_HOUSE, houseData[house][houseTitle], houseData[house][houseOwner], houseRentName, houseStatusName, house);
            UpdateDynamic3DTextLabelText(houseLabel[house], -1, textlabel);
            return 1;
        }
    }
    return 1;
}

GetTenantID(house)
{
    new
        tenantID;

    for(new s = GetMaxPlayers(), i; i < s; i++) {
        GetPlayerName(i, playerName, MAX_PLAYER_NAME);
        if (!strcmp(playerName, houseData[house][houseTenant], true)) {
            if (IsPlayerConnected(i)) {
                tenantID = i;
                break;
            }
            else {
                tenantID = -255;
            }
        }
    }

    return tenantID;
}

CreateHouseVehicleBought(playerid, house)
{
    new
        vehiclePath[200];

    format(vehiclePath, sizeof vehiclePath, "LHouse/Casas/Casa %d.txt", house);

    houseVehicle[house][vehiclePlate] = "LHouse S";
    houseVehicle[house][vehicleHouse] = \
        CreateVehicle(houseVehicle[house][vehicleModel], \
            houseVehicle[house][vehicleX], \
            houseVehicle[house][vehicleY], \
            houseVehicle[house][vehicleZ], \
            houseVehicle[house][vehicleAngle], \
            houseVehicle[house][vehicleColor1], \
            houseVehicle[house][vehicleColor2], \
            houseVehicle[house][vehicleRespawnTime]);

    DestroyVehicle(carSetted[playerid]);

    DOF2_SetString(vehiclePath, "Placa", houseVehicle[house][vehiclePlate], "Veículo");
    DOF2_SetInt(vehiclePath, "Modelo do Carro", houseVehicle[house][vehicleModel], "Veículo");
    DOF2_SetInt(vehiclePath, "Valor", houseVehicle[house][vehiclePrice], "Veículo");
    DOF2_SaveFile();

    return 1;
}

ChangeHouseVehicleColor(house, carColor1, carColor2)
{
    new
        housePath[200];

    format(housePath, sizeof housePath, "LHouse/Casas/Casa %d.txt", house);

    houseVehicle[house][vehicleColor1] = carColor1;
    houseVehicle[house][vehicleColor2] = carColor2;

    DOF2_SetInt(housePath, "Cor 1", houseVehicle[house][vehicleColor1], "Veículo");
    DOF2_SetInt(housePath, "Cor 2", houseVehicle[house][vehicleColor2], "Veículo");
    DOF2_SaveFile();

    ChangeVehicleColor(houseVehicle[house][vehicleHouse], houseVehicle[house][vehicleColor1], houseVehicle[house][vehicleColor2]);
    return 1;
}

ChangeHouseVehicleModel(house, model, price, mode)
{
    new
        housePath[200];

    format(housePath, sizeof housePath, "LHouse/Casas/Casa %d.txt", house);

    houseVehicle[house][vehicleModel] = model;
    houseVehicle[house][vehiclePrice] = price;

    DOF2_SetInt(housePath, "Modelo do Carro", houseVehicle[house][vehicleModel], "Veículo");
    DOF2_SetInt(housePath, "Valor", houseVehicle[house][vehiclePrice], "Veículo");
    DOF2_SaveFile();

    if(mode > 0)
    {
        DestroyVehicle(houseVehicle[house][vehicleHouse]);
        houseVehicle[house][vehicleHouse] = CreateVehicle(houseVehicle[house][vehicleModel], houseVehicle[house][vehicleX], houseVehicle[house][vehicleY], houseVehicle[house][vehicleZ], houseVehicle[house][vehicleAngle], houseVehicle[house][vehicleColor1], houseVehicle[house][vehicleColor2], houseVehicle[house][vehicleRespawnTime]);
    }

    return 1;
}
