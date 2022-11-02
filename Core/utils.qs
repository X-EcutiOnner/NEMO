

function GenVarHex(num)
{
    return (0xCCCCCCC0 + num).packToHex(4);
}

function ReplaceVarHex(code, nums, values)
{
    if (typeof nums === "number")
    {
        nums = [nums];
        values = [values];
    }

    for (var i = 0; i < nums.length; i++)
    {
        var value = values[i];

        if (typeof value === "number")
        {
            value = value.packToHex(4);
        }

        code = code.replace(GenVarHex(nums[i]), value);
    }

    return code;
}

function IsZero()
{
    return pe.find("53 6F 66 74 77 61 72 65 5C 47 72 61 76 69 74 79 20 53 6F 66 74 5C 52 65 6E 65 77 53  65 74 75 70 20 5A 65 72 6F") !== -1;
}

function GetLangType()
{
    var offset = pe.stringVa("america");
    if (offset === -1)
    {
        return ["'america' not found"];
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return ["'america' reference missing"];
    }

    offset = pe.find(" C7 05 ?? ?? ?? ?? 01 00 00 00", offset + 5);
    if (offset === -1)
    {
        return ["g_serviceType assignment missing"];
    }

    var lang = pe.fetchHex(offset + 2, 4);
    if (lang !== table.getHex4(table.g_serviceType))
    {
        return ["found wrong g_serviceType"];
    }
    return lang;
}

function GetServerType()
{
    var offset = pe.stringVa("sakray");
    if (offset === -1)
    {
        throw "'sakray' not found";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        throw "'sakray' reference missing";
    }

    offset = pe.find(" C7 05 ?? ?? ?? ?? 01 00 00 00", offset + 5);
    if (offset === -1)
    {
        throw "g_serverType assignment missing";
    }

    return pe.fetchDWord(offset + 2);
}

function GetWinMgrInfo(skipError)
{
    var offset = pe.stringVa("NUMACCOUNT");
    if (offset === -1)
    {
        return "NUMACCOUNT missing";
    }

    var code =
        getEcxWindowMgrHex() +
        "E8 ?? ?? ?? ?? " +
        "6A 00 " +
        "6A 00 " +
        "68 " + offset.packToHex(4);

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "NUMACCOUNT reference missing";
    }

    return {
        "gWinMgr": pe.fetchHex(offset, 5),
        "makeWin": pe.fetchDWord(offset + 6) + pe.rawToVa(offset) + 10,
    };
}

function HasFramePointer()
{
    return (pe.fetch(pe.sectionRaw(CODE)[0], 3) === "\x55\x8B\xEC") || table.get(table.packetVersion) > 20190000;
}

function GetInputFile(f, varname, title, prompt, fpath)
{
    var inp = "";
    while (inp === "")
    {
        inp = exe.getUserInput(varname, XTYPE_FILE, title, prompt, fpath);
        if (inp === "")
        {
            return false;
        }

        f.open(inp);
        if (f.eof())
        {
            f.close();
            inp = "";
        }
    }
    return inp;
}

function FetchPacketKeyInfo()
{
    var retVal =
  {
      "type": -1,
      "funcRva": -1,
      "keys": [0, 0, 0],
      "refMov": "",
      "ovrAddr": -1,
  };

    var offset = pe.stringVa("PACKET_CZ_ENTER");

    if (offset !== -1)
    {
        offset = pe.findCode(" 68" + offset.packToHex(4));
    }

    var code;

    if (offset === -1)
    {
        code =
        " E8 ?? ?? ?? ??" +
        " 8B C8" +
        " E8 ?? ?? ?? ??";

        code =
            code +

            " 50" +
            code +

            " 6A 01" +
            code +

            " 6A 06";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "PKI: Failed to find any reference locations";
    }

    code =
        " 8B 0D ?? ?? ?? 00" +
        " 68 ?? ?? ?? ??" +
        " 68 ?? ?? ?? ??" +
        " 68 ?? ?? ?? ??" +
        " E8";

    var offset2 = pe.find(code, offset - 0x100, offset);
    if (offset2 !== -1)
    {
        retVal.type = 0;
        retVal.refMov = pe.fetchHex(offset2, 6);

        offset2 += code.hexlength();
        retVal.funcAddr = pe.rawToVa(offset2 + 4) + pe.fetchDWord(offset2);
        retVal.keys = [pe.fetchDWord(offset2 - 5), pe.fetchDWord(offset2 - 10), pe.fetchDWord(offset2 - 15)];

        return retVal;
    }

    code =
        " 8B 0D ?? ?? ?? 00" +
        " 6A 01" +
        " E8";

    offset2 = pe.find(code, offset - 0x100, offset);
    if (offset2 == -1)
    {
        code =
            " 8B 0D ?? ?? ?? ??" +
            " 6A 01" +
            " E8";
        offset2 = pe.find(code, offset - 0x100, offset);
    }
    if (offset2 == -1)
    {
        return "PKI: Failed to find Encryption call";
    }

    retVal.refMov = pe.fetchHex(offset2, 6);

    offset2 += code.hexlength();
    offset = offset2 + 4 + pe.fetchDWord(offset2);

    retVal.funcAddr = pe.rawToVa(offset);

    var prefix =
        " 83 F8 01" +
        " 75 ??";
    code =
        prefix +
        " C7 41 ?? ?? ?? ?? ??" +
        " C7 41 ?? ?? ?? ?? ??" +
        " C7 41 ?? ?? ?? ?? ??";
    offset2 = pe.find(code, offset, offset + 0x50);

    if (offset2 !== -1)
    {
        retVal.type = 1;
        offset2 += prefix.hexlength();

        retVal.keys[pe.fetchByte(offset2 + 2) / 4]  = pe.fetchDWord(offset2 + 3);
        retVal.keys[pe.fetchByte(offset2 + 9) / 4]  = pe.fetchDWord(offset2 + 10);
        retVal.keys[pe.fetchByte(offset2 + 16) / 4] = pe.fetchDWord(offset2 + 17);
        retVal.keys.shift();

        retVal.ovrAddr = offset2;

        return retVal;
    }

    code =
    prefix +
        " B8 ?? ?? ?? ??" +
        " 89 41 ??" +
        " 89 41 ??" +
        " C7 41";

    offset2 = pe.find(code, offset, offset + 0x50);

    if (offset2 != -1)
    {
        retVal.type = 1;
        offset2 += prefix.hexlength();

        retVal.keys[pe.fetchByte(offset2 + 7) / 4]   = pe.fetchDWord(offset2 + 1);
        retVal.keys[pe.fetchByte(offset2 + 10) / 4]  = pe.fetchDWord(offset2 + 1);
        retVal.keys[pe.fetchByte(offset2 + 13) / 4]  = pe.fetchDWord(offset2 + 14);
        retVal.keys.shift();

        retVal.ovrAddr = offset2;

        return retVal;
    }

    var f = new TextFile();
    if (!f.open(APP_PATH + "/Input/PacketKeyMap.txt"))
    {
        return "PKI: Unable to open map file";
    }

    var cdate = pe.getDate();
    while (!f.eof())
    {
        var str = f.readline().trim();
        if (str.length < 16) continue;
        if (str.search(cdate) === 0)
        {
            var keys = str.split("=")[1].trim().split(",");
            if (keys.length === 3)
            {
                break;
            }

            delete keys;
        }
    }

    if (typeof keys !== "undefined")
    {
        retVal.type = 2;
        retVal.keys = [parseInt(keys[0], 16), parseInt(keys[1], 16), parseInt(keys[2], 16)];
        retVal.ovrAddr = pe.vaToRaw(retVal.funcAddr);

        if (HasFramePointer())
        {
            retVal.ovrAddr += 3;
        }

        return retVal;
    }

    return retVal;
}

function GetOpDetails(opcode, modrm, offset)
{
    var details = {};
    var opcode2 = -1;

    for (var i = 0; i < OpcodeSizeMap.length; i += 2)
    {
        if (OpcodeSizeMap[i].indexOf(opcode) !== -1)
        {
            details.codesize = OpcodeSizeMap[i + 1];
            break;
        }
    }

    if (opcode === 0x0F)
    {
        opcode2 = modrm;
        modrm = pe.fetchUByte(offset + 2);
    }

    if (typeof details.codesize === "undefined")
    {
        details.mode = (modrm & 0xC0) >> 6;
        details.ro   = (modrm & 0x38) >> 3;
        details.rm   = modrm & 0x07;

        details.codesize = 2;

        if (details.rm === 0x4 && details.mode !== 0x3)
        {
            details.codesize++;
        }

        if (details.mode === 0x1)
        {
            details.tgtImm = pe.fetchByte(offset + details.codesize);
            details.codesize++;
        }

        if (details.mode === 0x2 || (details.mode === 0x0 && (details.rm === 0x5 || details.rm === 0x4)))
        {
            details.tgtImm = pe.fetchDWord(offset + details.codesize);
            details.codesize += 4;
        }

        if (opcode2 !== -1)
        {
            details.codesize++;
        }
    }

    switch (opcode)
    {
        case 0xEB:
        case 0x70:
        case 0x71:
        case 0x72:
        case 0x73:
        case 0x74:
        case 0x75:
        case 0x76:
        case 0x77:
        case 0x78:
        case 0x79:
        case 0x7A:
        case 0x7B:
        case 0x7C:
        case 0x7D:
        case 0x7E:
        case 0x7F:
        {
            details.tgtImm   = pe.fetchByte(offset + 1);

            break;
        }

        case 0xE8:
        case 0xE9: {
            details.tgtImm    = pe.fetchDWord(offset + 1);

            break;
        }

        case 0x0F:
        {
            if (opcode2 >= 0x80 && opcode2 <= 0x8F)
            {
                details.tgtImm   = pe.fetchDWord(offset + 2);

                details.codesize = 6;
            }
            break;
        }

        case 0x69:
        case 0x81:
        case 0xC7:
        {
            details.srcImm   = pe.fetchDWord(offset + details.codesize);
            details.codesize += 4;
            break;
        }

        case 0x6B:
        case 0xC0:
        case 0xC1:
        case 0xC6:
        case 0x80:
        case 0x82:
        case 0x83:
        {
            details.srcImm   = pe.fetchByte(offset + details.codesize);
            details.codesize++;
            break;
        }
        default:
            break;
    }

    details.nextOff = offset + details.codesize;

    return details;
}

function FetchTillEnd(offset, refReg, refOff, tgtReg, langType, endFunc, assigner)
{
    var done = false;
    var extract = "";
    var regAssigns = ["", "", "", "", "", "", "", ""];

    if (typeof langType === "string")
    {
        langType = langType.unpackToInt();
    }

    if (typeof assigner === "undefined")
    {
        assigner = -1;
    }
    var cnt = 0;
    while (!done)
    {
        if (cnt > 1000)
        {
            throw "FetchTillEnd: Infinite loop in FetchTillEnd";
        }
        if (offset < 0)
        {
            throw "FetchTillEnd: Negative offset found";
        }

        var opcode = pe.fetchUByte(offset);
        var modrm  = pe.fetchUByte(offset + 1);

        var details = GetOpDetails(opcode, modrm, offset);

        done = endFunc(opcode, modrm, offset, details, assigner);
        if (done)
        {
            continue;
        }

        var skip = false;

        switch (opcode)
        {
            case 0x8B:
            {
                if (tgtReg !== -1)
                {
                    break;
                }

                skip = true;

                if (refOff !== 0 && details.tgtImm === refOff)
                {
                    tgtReg = details.ro;
                }
                else if (details.mode === 0 && details.rm === refReg)
                {
                    tgtReg = details.ro;
                }
                else
                {
                    skip = false;
                }

                break;
            }

            case 0xC7:
            case 0x89:
            {
                if (tgtReg !== -1 && details.rm === tgtReg && (details.mode !== 3))
                {
                    tgtReg = -1;
                    skip = true;
                }

                if (skip && regAssigns[details.ro] !== "" && opcode === 0x89)
                {
                    extract = extract.replace(regAssigns[details.ro], "");
                    regAssigns[details.ro] = "";
                }

                break;
            }

            case 0xB8:
            case 0xB9:
            case 0xBA:
            case 0xBB:
            case 0xBC:
            case 0xBD:
            case 0xBE:
            case 0xBF:
            {
                regAssigns[opcode - 0xB8] = pe.fetchHex(offset, details.codesize);
                break;
            }

            case 0x0F:
            {
                skip = modrm >= 0x80 && modrm <= 0x8F;
                if (skip)
                {
                    details.nextOff += details.tgtImm;
                }

                break;
            }

            case 0xE9:
            case 0xEB:
            case 0x70:
            case 0x71:
            case 0x72:
            case 0x73:
            case 0x74:
            case 0x75:
            case 0x76:
            case 0x77:
            case 0x78:
            case 0x79:
            case 0x7A:
            case 0x7B:
            case 0x7C:
            case 0x7D:
            case 0x7E:
            case 0x7F:
            {
                skip = true;
                details.nextOff += details.tgtImm;
                break;
            }

            case 0x83:
            {
                skip = modrm === 0x3D && details.tgtImm === langType;
                break;
            }

            case 0x39:
            {
                skip = details.mode === 0 && details.rm === 5 && details.tgtImm === langType;
                break;
            }

            case 0x6A:
            case 0x68:
            {
                if (assigner === -1)
                {
                    break;
                }

                var offset2 = details.nextOff + 7;

                if (pe.fetchUByte(details.nextOff + 2) === 0xC7)
                {
                    offset2 += 6;
                }

                skip = pe.fetchUByte(offset2 - 5) === 0xE8 && pe.fetchDWord(offset2 - 4) === (assigner - offset2);
                if (skip)
                {
                    details.nextOff = offset2;
                    tgtReg = 0;
                }
                break;
            }

            case 0xE8:
            {
                if (assigner === -1)
                {
                    break;
                }

                if (details.tgtImm === (assigner - details.nextOff))
                {
                    skip = true;
                    extract += " 83 C4 04";
                    tgtReg = 0;
                }
                break;
            }

            default:
                break;
        }

        if (!skip)
        {
            extract += pe.fetchHex(offset, details.codesize);
        }

        offset = details.nextOff;
        cnt += 1;
    }

    return {"endOff": offset, "code": extract};
}

