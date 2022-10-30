

function offsetStack(loc, sign)
{
    if (typeof sign === "undefined") sign = -1;
    var obyte = pe.fetchByte(loc) + sign * 16;
    pe.replaceByte(loc, obyte);
}

function IncreaseAtkDisplay()
{
    var code =
        " 81 ?? 3F 42 0F 00" +
        " 7E 07" +
        " ?? 3F 42 0F 00";
    var refOffset = pe.findCode(code);

    if (refOffset === -1)
    {
        code = code.replace(" 7E", " ?? 7E");
        refOffset = pe.findCode(code);
    }

    if (refOffset === -1)
    {
        return "Failed in Step 1 - 999999 comparison missing";
    }

    code =
        " 6A FF" +
        " 68 ?? ?? ?? 00" +
        " 64 A1 00 00 00 00" +
        " 50" +
        " 83 EC";
    var offset = pe.find(code, refOffset - 0x40, refOffset);

    if (offset === -1)
    {
        code = code.replace(" 50", " 50 64 89 25 00 00 00 00");
        offset = pe.find(code, refOffset - 0x40, refOffset);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Function start missing";
    }

    offset += code.hexlength();

    offsetStack(offset, 1);

    var fpEnb = HasFramePointer();

    if (fpEnb)
    {
        code = "C7 45 ?? 01 00 00 00";
    }
    else
    {
        code = "C7 44 24 ?? 01 00 00 00";
    }

    offset = pe.find(code, refOffset + 0x10, refOffset + 0x28);

    if (offset === -1)
    {
        code =
            " 7E 07" +
            " ?? 06 00 00 00" +
            " EB";
        offset = pe.find(code, refOffset + 0x10, refOffset + 0x28);
    }

    if (offset === -1)
    {
        return "Failed in Step 2 - Digit Counter missing";
    }

    var offByte;
    var offset2;
    if (pe.fetchUByte(offset) === 0xC7)
    {
        offByte = pe.fetchByte(offset + code.hexlength() - 5);
    }
    else
    {
        offByte = pe.fetchUByte(offset + 2) - 0xB8;

        code = (offByte << 3) | 0x44;
        if (fpEnb)
        {
            code = " 89" + (code + 1).packToHex(1) + " ?? 8D";
        }
        else
        {
            code = " 89" + code.packToHex(1) + " 24 ?? 8D";
        }

        offset2 = pe.find(code, offset, offset + 0x80);

        if (offset2 === -1)
        {
            offByte = " 89" + (0xF0 | offByte).packToHex(1);
        }
        else
        {
            offByte = pe.fetchByte(offset2 + code.hexlength() - 2);
        }
    }

    offset = pe.find("B8 67 66 66 66", offset);
    if (offset === -1)
    {
        return "Failed in Step 2 - Digit Extractor missing";
    }

    if (fpEnb)
    {
        code = " 89 ?? ??";
    }
    else
    {
        code = " 89 ?? 24 ??";
    }

    offset2 = pe.find(code + " 8B", offset + 0x5, offset + 0x28);

    if (offset2 === -1)
    {
        offset2 = pe.find(code + " F7", offset + 0x5, offset + 0x28);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 2 - Digit movement missing";
    }

    offset2 += code.hexlength();

    var offByte2 = pe.fetchByte(offset2 - 1);

    offset = pe.find(getEcxModeMgrHex(), offset2);
    if (offset === -1)
    {
        return "Failed in Step 2 - g_modeMgr assignment missing";
    }

    var movECX = pe.fetchHex(offset, 5);

    offset = pe.find(" E8 ?? ?? ?? FF", offset + 5);
    if (offset === -1)
    {
        return "Failed in Step 2 - GetGameMode call missing";
    }

    if (fpEnb)
    {
        if (typeof offByte === "number" && offByte < offByte2)
        {
            offByte -= 16;
        }

        offByte2 -= 16;
    }
    else
    if (typeof offByte === "number" && offByte >= (offByte2 + 4 * 6))
    {
        offByte += 16;
    }

    code =
        " 89" + (0xC1 + ((pe.fetchByte(refOffset + 1) & 0x7) << 3)).packToHex(1) +
        " BE" + offByte2.packToHex(4) +
        " B8 67 66 66 66" +
        " F7 E9" +
        " C1 FA 02" +
        " 8D 04 92" +
        " D1 E0" +
        " 29 C1" +
        " MovDigit" +
        " 83 C6 04" +
        " 89 D1" +
        " 85 C9" +
        " 75 E2" +
        " 83 EE" + offByte2.packToHex(1) +
        " C1 FE 02" +
        " MovEsi"  +
        movECX +
        " E9" + GenVarHex(1);

    if (fpEnb)
    {
        code = code.replace(" MovDigit", " 89 4C 35 00");
        if (typeof offByte === "number")
        {
            code = code.replace(" MovEsi", " 89 75" + offByte.packToHex(1));
        }
        else
        {
            code = code.replace(" MovEsi", offByte);
        }
    }
    else
    {
        code = code.replace(" MovDigit", " 89 0C 34 90");
        code = code.replace(" MovEsi", " 89 74 24" + offByte.packToHex(1));
    }

    code = ReplaceVarHex(code, 1, offset - (refOffset + code.hexlength()));

    pe.replaceHex(refOffset, code);

    if (fpEnb)
    {
        code = "8B E5 5D";
    }
    else
    {
        code = "83 C4 ??";
    }

    code += "C2 10 00";

    var offset3 = pe.find(code, offset, offset + 0x200);
    if (offset3 === -1)
    {
        return "Failed in Step 4 - Function end missing";
    }

    offset2 = offset + 5;
    var soff;
    if (fpEnb)
    {
        soff = 16;
    }
    else
    {
        soff = 4 * 6;
    }

    while (offset2 < offset3)
    {
        var opcode = pe.fetchUByte(offset2);
        var modrm = pe.fetchUByte(offset2 + 1);

        var details = GetOpDetails(opcode, modrm, offset2);

        switch (opcode)
        {
            case 0x89:
            case 0x8B:
            case 0x8D:
            case 0xC7:
            case 0x3B:
            case 0xFF:
            case 0x83:
            {
                if (opcode === 0xFF && !fpEnb && details.ro === 2)
                {
                    soff = 6 * 4;
                }

                if (fpEnb && details.mode === 1)
                {
                    if (details.rm === 5 && pe.fetchByte(offset2 + 2) <= (offByte2 + soff))
                    {
                        offsetStack(offset2 + 2);
                    }
                    else if (details.rm === 4 && (pe.fetchByte(offset2 + 2) & 0x7) === 5 &&  pe.fetchByte(offset2 + 3) <= (offByte2 + soff))
                    {
                        offsetStack(offset2 + 3);
                    }
                }
                else if (!fpEnb && details.mode === 1 && details.rm === 4 && (pe.fetchByte(offset2 + 2) & 0x7) === 4 && pe.fetchByte(offset2 + 3) >= (offByte2 + soff))
                {
                    offsetStack(offset2 + 3, 1);
                }

                break;
            }
            case 0x68:
            case 0x6A:
            {
                if (!fpEnb)
                {
                    soff += 4;
                }

                break;
            }
            case 0xE8:
            {
                if (!fpEnb)
                {
                    soff = 6 * 4;
                }

                break;
            }
            default:
                break;
        }

        offset2 = details.nextOff;
    }

    if (fpEnb)
    {
        if (typeof offByte === "number")
        {
            offset = pe.find("89 ?? ?? 81", refOffset - 6, refOffset);

            if (offset === -1)
            {
                offset = pe.find("89 ?? ?? 8B", refOffset - 6, refOffset);
            }

            if (offset === -1)
            {
                return "Failed in Step 2 - MOV missing";
            }

            offsetStack(offset + 2);
        }
    }
    else
    {
        offsetStack(offset3 + 2, 1);

        offset = pe.find("8D ?? 24", refOffset - 0x28, refOffset);
        if (offset === -1)
        {
            return "Failed in Step 2 - LEA missing";
        }

        offsetStack(offset + 3, 1);

        offset = pe.find("8B ?? 24", refOffset - 8, refOffset);
        if (offset === -1)
        {
            return "Failed in Step 2 - ARG.2 assignment missing";
        }

        offsetStack(offset + 3, 1);
    }

    return true;
}
