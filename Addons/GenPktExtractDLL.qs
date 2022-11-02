

function GenPktExtractDLL()
{
    var code =
      " E8 ?? ?? ?? ??" +
    " 50" +
    " E8 ?? ?? ?? ??" +
    " 8B C8" +
    " E8 ?? ?? ?? ??" +
    " 6A 01" +
    " E8";
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        throw "SendPacket not found";
    }

    code =
      " 8B 0D ?? ?? ?? 00" +
    " 68 ?? ?? ?? ??" +
    " 68 ?? ?? ?? ??" +
    " 68 ?? ?? ?? ??" +
    " E8";
    var offset2 = pe.find(code, offset - 0x100, offset);
    var KeyFetcher = 0;

    if (offset2 === -1)
    {
        code =
            " 8B 0D ?? ?? ?? 00" +
            " 6A 01" +
            " E8";
        offset2 = pe.find(code, offset - 0x100, offset);
        KeyFetcher = -1;
    }

    if (offset2 !== -1 && KeyFetcher === -1)
    {
        offset2 += code.hexlength();
        KeyFetcher = pe.rawToVa(offset2 + 4) + pe.fetchDWord(offset2);
    }

    offset += pe.fetchDWord(offset + 1) + 5;

    code =
        " B9 ?? ?? ?? ??" +
        " E8 ?? ?? ?? ??" +
        " 8B ?? 04";

    offset = pe.find(code, offset, offset + 0x60);
    if (offset === -1)
    {
        throw "g_PacketLenMap not found";
    }

    var gPacketLenMap = pe.fetchHex(offset, 5);

    offset += pe.fetchDWord(offset + 6) + 10;

    code =
        " 8B ?? ??" +
        " 83 ?? FF" +
        " 75 ??" +
        " 8B";

    offset2 = pe.find(code, offset, offset + 0x60);
    if (offset2 === -1)
    {
        throw "PktOff not found";
    }

    var PktOff = pe.fetchByte(offset2 + 2) - 4;

    code =
      gPacketLenMap +
    " E8 ?? ?? ?? ??" +
    " 68 ?? ?? ?? 00" +
    " E8 ?? ?? ?? ??" +
    " 59" +
    " C3";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        throw "InitPacketMap not found";
    }

    var ExitAddr = pe.rawToVa(offset + 15);

    offset += pe.fetchDWord(offset + 6) + 10;

    code =
        " 8B CE" +
        " E8 ?? ?? ?? ??" +
        " C7";

    offset = pe.find(code, offset, offset + 0x140);
    if (offset === -1)
    {
        throw "InitPacketLenWithClient not found";
    }

    offset += pe.fetchDWord(offset + 3) + 7;

    var funcs = [];

    while (true)
    {
        offset = pe.find("E8 ?? ?? FF FF", offset + 1);
        if (offset === -1) break;
        var func = offset + pe.fetchDWord(offset + 1) + 5;
        if (funcs.indexOf(func) !== -1) break;
        funcs.push(func);
    }

    if (offset === -1 || funcs.length === 0)
    {
        throw "std::map not found";
    }

    offset = funcs[funcs.length - 1];

    code =
        " E8 ?? ?? FF FF" +
        " 8B ??" +
        " 8B";

    var HookAddrs = pe.findAll(code, offset, offset + 0x100);
    if (HookAddrs.length < 1 || HookAddrs.length > 2)
    {
        throw "std::_tree call count is different";
    }

    var fp = new BinFile();
    if (!fp.open(APP_PATH + "/Input/ws2_pe.dll"))
    {
        throw "Base File - ws2_pe.dll is missing from Input folder";
    }

    var dllHex = fp.readHex(0, 0x1800);
    fp.close();

    dllHex = dllHex.replace(" 64".repeat(8), ("" + pe.getDate()).toHex());

    code =
      PktOff.packToHex(4) +
    ExitAddr.packToHex(4) +
    pe.rawToVa(HookAddrs[0]).packToHex(4);
    if (HookAddrs.length === 1)
    {
        code += " 00 00 00 00";
    }
    else
    {
        code += pe.rawToVa(HookAddrs[1]).packToHex(4);
    }

    code += KeyFetcher.packToHex(4);
    dllHex = dllHex.replace(/ 01 FF 00 FF 02 FF 00 FF 03 FF 00 FF 04 FF 00 FF 05 FF 00 FF/i, code);

    if (!fp.open(APP_PATH + "/Output/ws2_pe_" + pe.getDate() + ".dll", "w"))
    {
        throw "Unable to create output file";
    }

    fp.writeHex(0, dllHex);
    fp.close();

    return "DLL has been generated - Dont forget to rename it.";
}

