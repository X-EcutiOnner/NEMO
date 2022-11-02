

function GenMapEffectPlugin()
{
    var fp = new BinFile();
    if (!fp.open(APP_PATH + "/Input/rdll2.asi"))
    {
        throw "Error: Base File - rdll2.asi is missing from Input folder";
    }

    var offset = pe.stringVa("xmas_fild01.rsw");
    if (offset === -1)
    {
        throw "Error: xmas_fild01 missing";
    }

    offset = pe.findCode(offset.packToHex(4) + " 8A");
    if (offset === -1)
    {
        throw "Error: xmas_fild01 reference missing";
    }

    var CI_Entry = offset - 1;

    var code =
        " B9 ?? ?? ?? 00" +
        " E8";

    offset = pe.find(code, CI_Entry - 0x10, CI_Entry);
    if (offset === -1)
    {
        code =
            " B9 ?? ?? ?? 01" +
            " E8";
        offset = pe.find(code, CI_Entry - 0x10, CI_Entry);
    }
    if (offset === -1)
    {
        throw "Error: g_Weather assignment missing";
    }

    var gWeather = pe.fetchHex(offset + 1, 4);

    code =
        " 74 0A" +
        " B9" + gWeather +
        " E8";

    offset = pe.find(code, CI_Entry + 1);
    if (offset === -1)
    {
        throw "Error: CI_Return missing";
    }

    var CI_Return = offset + code.hexlength() + 4;

    var CW_LPokJuk = (pe.rawToVa(CI_Return) + pe.fetchDWord(CI_Return - 4)).packToHex(4);

    var offset2 = pe.stringVa("yuno.rsw");
    if (offset2 === -1)
    {
        throw "Error: yuno.rsw missing";
    }

    offset = pe.find(offset2.packToHex(4) + " 8A", CI_Entry + 1, CI_Return);
    if (offset === -1)
    {
        throw "Error: yuno.rsw reference missing";
    }

    offset = pe.find("0F 84 ?? ?? 00 00", offset + 5);
    if (offset === -1)
    {
        throw "Error: LaunchCloud JZ missing";
    }

    offset += pe.fetchDWord(offset + 2) + 6;

    var opcode = pe.fetchByte(offset) & 0xFF;
    var gUseEffect;
    if (opcode === 0xA1)
    {
        gUseEffect = pe.fetchHex(offset + 1, 4);
    }
    else
    {
        gUseEffect = pe.fetchHex(offset + 2, 4);
    }

    code =
        " B9" + gWeather +
        " E8";

    offset = pe.find(code, offset);
    if (offset === -1)
    {
        throw "Error: LaunchCloud call missing";
    }

    offset += code.hexlength();

    var CW_LCloud = (pe.rawToVa(offset + 4) + pe.fetchDWord(offset)).packToHex(4);

    offset = pe.find("B8 " + offset2.packToHex(4), 0, CI_Entry - 1);

    if (offset === -1)
    {
        offset = pe.find("B8 " + offset2.packToHex(4), CI_Return + 1);
    }

    if (offset === -1)
    {
        throw "Error: 2nd yuno.rsw reference missing";
    }

    var CO_Entry = offset;

    offset = pe.find("0F 84 ?? ?? 00 00 ", CO_Entry + 1);
    if (offset === -1)
    {
        throw "Error: JZ after CO_Entry missing";
    }

    offset += pe.fetchDWord(offset + 2) + 6 + 1;

    opcode = pe.fetchByte(offset - 1) & 0xFF;
    if (opcode !== 0xA1)
    {
        offset++;
    }

    var gRenderer = pe.fetchHex(offset, 4);
    if (gRenderer != table.getHex4(table.g_renderer))
    {
        throw "Found wrong g_renderer";
    }
    var gR_clrColor = pe.fetchHex(offset + 6, 1);

    code =
        gRenderer +
        " C7 ??" + gR_clrColor + " 33 00 33 FF" +
        " EB";

    offset = pe.find(code, offset + 11);
    if (offset === -1)
    {
        throw "Error: CO_Return missing";
    }

    offset += code.hexlength();
    offset += pe.fetchByte(offset) + 1;

    opcode = pe.fetchByte(offset) & 0xFF;
    if (opcode != 0xA1 && (opcode !== 0x8B || (pe.fetchByte(offset + 1) & 0xC7) !== 5))
    {
        code =
            gRenderer +
            " C7 ??" + gR_clrColor;
        offset = pe.find(code, offset + 1, offset + 0x100);
        if (offset === -1)
        {
            throw "Error: CO_Return missing 2";
        }

        offset += code.hexlength() + 4;
    }

    var CO_Return = offset;

    offset = pe.findCode("C6 01 01 C3");
    if (offset === -1)
    {
        throw "Error: LaunchNight missing";
    }

    var CW_LNight = pe.rawToVa(offset).packToHex(4);

    code =
        " 74 07" +
        " E8 ?? ?? ?? ??" +
        " EB 05" +
        " E8";

    offset = pe.find(code, CI_Entry);
    if (offset === -1)
    {
        throw "Error: LaunchSnow call missing";
    }

    var CW_LSnow = (pe.rawToVa(offset + 7) + pe.fetchDWord(offset + 3)).packToHex(4);

    offset = pe.findCode("68 4D 01 00 00 89");
    if (offset === -1)
    {
        throw "Error: LaunchMaple missing";
    }

    code =
        " 83 EC 0C" +
        " 56" +
        " 8B F1";
    offset2 = pe.find("55 8B EC" + code, offset - 0x70, offset);

    if (offset2 === -1)
    {
        offset2 = pe.find(code, offset - 0x60, offset);
    }

    if (offset2 === -1)
    {
        throw "Error: LaunchMaple start missing";
    }

    var CW_LMaple = pe.rawToVa(offset2).packToHex(4);

    offset = pe.findCode("68 A3 00 00 00 89");
    if (offset === -1)
    {
        throw "Error: LaunchSakura missing";
    }

    offset2 = pe.find("55 8B EC" + code, offset - 0x70, offset);

    if (offset2 === -1)
    {
        offset2 = pe.find(code, offset - 0x60, offset);
    }

    if (offset2 === -1)
    {
        throw "Error: LaunchSakura start missing";
    }

    var CW_LSakura = pe.rawToVa(offset2).packToHex(4);

    var dll = fp.readHex(0, 0x2000);
    fp.close();

    dll = dll.replace(/ C1 C1 C1 C1/i, gWeather);
    dll = dll.replace(/ C2 C2 C2 C2/i, gRenderer);
    dll = dll.replace(/ C3 C3 C3 C3/i, gUseEffect);

    code =
        CW_LCloud +
        CW_LSnow +
        CW_LMaple +
        CW_LSakura +
        CW_LPokJuk +
        CW_LNight;
    dll = dll.replace(/ C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4 C4/i, code);

    dll = dll.replace(/ C5 C5 C5 C5/i, pe.rawToVa(CI_Entry).packToHex(4));
    dll = dll.replace(/ C6 C6 C6 C6/i, pe.rawToVa(CO_Entry).packToHex(4));
    dll = dll.replace(/ C7 C7 C7 C7/i, pe.rawToVa(CI_Return).packToHex(4));
    dll = dll.replace(/ C8 C8 C8 C8/i, pe.rawToVa(CO_Return).packToHex(4));

    dll = dll.replace(/ 6C 5D C3/i, gR_clrColor + " 5D C3");

    fp.open(APP_PATH + "/Output/rdll2_" + pe.getDate() + ".asi", "w");
    fp.writeHex(0, dll);
    fp.close();

    var fp2 = new TextFile();
    fp2.open(APP_PATH + "/Output/client_" + pe.getDate() + ".h", "w");
    fp2.writeline("#include <WTypes.h>");
    fp2.writeline("\n// Client Date : " + pe.getDate());
    fp2.writeline("\n// Client offsets - some are #define because they were appearing in multiple locations unnecessarily");
    fp2.writeline("#define G_WEATHER 0x" + gWeather.toBE() + ";");
    fp2.writeline("#define G_RENDERER 0x" + gRenderer.toBE() + ";");
    fp2.writeline("#define G_USEEFFECT 0x" + gUseEffect.toBE() + ";");
    fp2.writeline("\nDWORD CWeather_EffectId2LaunchFuncAddr[] = {\n\tNULL, //CEFFECT_NONE");
    fp2.writeline("\t0x" + CW_LCloud.toBE() + ", // CEFFECT_SKY -> void CWeather::LaunchCloud(CWeather this<ecx>, char param)");
    fp2.writeline("\t0x" + CW_LSnow.toBE() + ", // CEFFECT_SNOW -> void CWeather::LaunchSnow(CWeather this<ecx>)");
    fp2.writeline("\t0x" + CW_LMaple.toBE() + ", // CEFFECT_MAPLE -> void CWeather::LaunchMaple(CWeather this<ecx>)");
    fp2.writeline("\t0x" + CW_LSakura.toBE() + ", // CEFFECT_SAKURA -> void CWeather::LaunchSakura(CWeather this<ecx>)");
    fp2.writeline("\t0x" + CW_LPokJuk.toBE() + ", // CEFFECT_POKJUK -> void CWeather::LaunchPokJuk(CWeather this<ecx>)");
    fp2.writeline("\t0x" + CW_LNight.toBE() + ", // CEFFECT_NIGHT -> void CWeather::LaunchNight(CWeather this<ecx>)");
    fp2.writeline("};\n");

    fp2.writeline("#define CGameMode_Initialize_EntryPtr (void*)0x" + pe.rawToVa(CI_Entry).toBE(4) + ";");
    fp2.writeline("#define CGameMode_OnInit_EntryPtr (void*)0x"     + pe.rawToVa(CO_Entry).toBE(4) + ";");
    fp2.writeline("void* CGameMode_Initialize_RetPtr = (void*)0x"   + pe.rawToVa(CI_Return).toBE(4) + ";");
    fp2.writeline("void* CGameMode_OnInit_RetPtr = (void*)0x"       + pe.rawToVa(CO_Return).toBE(4) + ";");

    fp2.writeline("\r\n#define GR_CLEAR " + (parseInt(gR_clrColor, 16) / 4) + ";");
    fp2.close();

    return "MapEffect plugin for the loaded client has been generated in Output folder";
}
