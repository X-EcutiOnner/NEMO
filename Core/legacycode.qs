

function GetFunction(funcName, dllName, ordinal)
{
    if (typeof dllName === "undefined")
    {
        dllName = "";
    }
    else
    {
        dllName = dllName.toUpperCase();
    }

    if (typeof ordinal === "undefined")
    {
        ordinal = -1;
    }

    var funcAddr = -1;
    var offset = pe.getSubSection(1).offset;
    var imgBase = pe.getImageBase();

    for (;; offset += 20)
    {
        var nameOff = pe.fetchDWord(offset + 12);
        var iatOff  = pe.fetchDWord(offset + 16);

        if (nameOff <= 0) break;
        if (iatOff  <= 0) continue;

        if (dllName !== "")
        {
            nameOff = pe.vaToRaw(nameOff + imgBase);
            var nameEnd = pe.find("00", nameOff);
            if (dllName !== pe.fetch(nameOff, nameEnd - nameOff).toUpperCase()) continue;
        }

        var offset2 = pe.vaToRaw(iatOff + imgBase);

        for (;; offset2 += 4)
        {
            var funcData = pe.fetchDWord(offset2);

            if (funcData === 0) break;

            if (funcData > 0)
            {
                nameOff = pe.vaToRaw((funcData & 0x7FFFFFFF) + imgBase) + 2;
                nameEnd = pe.find("00", nameOff);

                if (funcName === pe.fetch(nameOff, nameEnd - nameOff))
                {
                    funcAddr = pe.rawToVa(offset2);
                    break;
                }
            }
            else if ((funcData & 0xFFFF) === ordinal)
            {
                funcAddr = pe.rawToVa(offset2);
                break;
            }
        }

        if (funcAddr !== -1) break;
    }

    return funcAddr;
}

function GetDataDirectory(index)
{
    var offset = pe.getPeHeader() + 0x18 + 0x60;
    if (offset === 0x67)
    {
        return -2;
    }

    var size = pe.fetchDWord(offset + 0x8 * index + 0x4);
    offset = pe.vaToRaw(pe.fetchDWord(offset + 0x8 * index) + pe.getImageBase());
    return {"offset": offset, "size": size};
}

OpcodeSizeMap =
[
    [
        0x06, 0x07, 0x0E,
        0x16, 0x17, 0x1E, 0x1F,
        0x26, 0x27, 0x2E, 0x2F,
        0x36, 0x37, 0x3E, 0x3F,
        0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
        0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
        0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,
        0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
        0x60, 0x61, 0x64, 0x65, 0x66, 0x67,
        0x6C, 0x6D, 0x6E, 0x6F,
        0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
        0x98, 0x99, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F,
        0xA4, 0xA5, 0xA6, 0xA7,
        0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF,
        0xC3,
        0xC9,
        0xD6, 0xD7,
        0xEC, 0xED, 0xEE, 0xEF,
        0xF1, 0xF2, 0xF3, 0xF4, 0xF5,
        0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD,
    ],
    1,
    [
        0x0C,
        0x1C,
        0x2C,
        0x3C,
        0x6A,
        0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,
        0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F,
        0xA8,
        0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7,
        0xE4, 0xE5, 0xE6, 0xE7,
        0xEB,
    ],
    2,
    [
        0xC2,
    ],
    3,
    [
        0xC8,
    ],
    4,
    [
        0x0D,
        0x1D,
        0x2D,
        0x3D,
        0x68,
        0xA0, 0xA1, 0xA2, 0xA3,
        0xA9,
        0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF,
        0xE8, 0xE9,
    ],
    5,
    [
        0x9A,
        0xEA,
    ],
    7,
];

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
