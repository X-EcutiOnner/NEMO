

PEncKeys = [];
delete PEncInsert;
delete PEncActive;

function PacketEncryptionKeys(varname, index)
{
    if (getActivePatches().indexOf(61) !== -1)
    {
        return "Patch Cancelled - Disable Packet Encryption is ON";
    }

    var info = FetchPacketKeyInfo();
    if (typeof info === "string")
    {
        return info;
    }

    if (info.type === -1)
    {
        return "Failed in Step 1 - No Packet Key Patterns matched";
    }

    var newKey = parseInt(exe.getUserInput(varname, XTYPE_HEXSTRING, _("Hex input"), _("Enter the new key"), info.keys[index].toBE()),  16);
    if (newKey === info.keys[index])
    {
        return "Patch Cancelled - Key not changed";
    }

    var i;
    if (info.type === 0)
    {
        var code =
            " 68" + info.keys[2].packToHex(4) +
            " 68" + info.keys[1].packToHex(4) +
            " 68" + info.keys[0].packToHex(4) +
            " E8";

        var offsets = pe.findCodes(code);
        if (offsets.length === 0)
        {
            return "Failed in Step 2";
        }

        for (i = 0; i < offsets.length; i++)
        {
            pe.replace(offsets[i] + code.hexlength() - (index + 1) * 5, varname);
        }
    }
    else
    {
        code = "";

        if (PEncKeys.length === 0)
        {
            PEncKeys = info.keys;
        }

        PEncKeys[index] = newKey;

        var suffix = "";
        if (HasFramePointer())
        {
            suffix += " 5D";
        }

        suffix += " C2 04 00";

        if (info.type === 2)
        {
            if (HasFramePointer())
            {
                code += " 8B 45 08";
            }
            else
            {
                code += " 8B 44 24 04";
            }

            code +=
        " 85 C0" +
      " 75 19" +
      " 8B 41 08" +
      " 0F AF 41 04" +
      " 03 41 0C" +
      " 89 41 04" +
      " C1 E8 10" +
      " 25 FF 7F 00 00" +
      suffix +
      " 83 F8 01" +
      " 74 0F" +
      " 31 C0" +
      " 89 41 04" +
      " 89 41 08" +
      " 89 41 0C" +
      suffix;
            if (suffix.hexlength() !== 4)
            {
                code = code.replace(" 75 19", "75 18").replace(" 74 0F", " 74 0E");
            }
        }

        code +=
            " C7 41 04" + PEncKeys[0].packToHex(4) +
            " C7 41 08" + PEncKeys[1].packToHex(4) +
            " C7 41 0C" + PEncKeys[2].packToHex(4) +
            " 33 C0" +
            suffix;

        if (typeof PEncInsert !== "undefined")
        {
            for (i = 0; i < 3; i++)
            {
                if (i === index) continue;
                exe.emptyPatch(92 + i);
            }
        }

        var csize = code.hexlength();
        var free = alloc.find(csize);
        if (free === -1)
        {
            return "Failed in Step 4 - Not Enough Free Space";
        }

        PEncInsert = pe.rawToVa(free);

        pe.insertHexAt(free, csize, code);

        code = " E9" + (PEncInsert - pe.rawToVa(info.ovrAddr + 5)).packToHex(4);
        pe.replaceHex(info.ovrAddr, code);

        PEncActive = index;
    }

    return true;
}

function PacketFirstKeyEncryption_()
{
    return table.get(table.comboFunction) <= 0;
}

function PacketSecondKeyEncryption_()
{
    return table.get(table.comboFunction) <= 0;
}

function PacketThirdKeyEncryption_()
{
    return table.get(table.comboFunction) <= 0;
}

function _PacketEncryptionKeys(index)
{
    if (typeof PEncInsert === "undefined")
    {
        return undefined;
    }

    if (PEncActive === index)
    {
        var patches = getActivePatches();
        for (var i = 0; i < 3; i++)
        {
            if (patches.indexOf(92 + i) !== -1)
            {
                PEncActive = i;
                break;
            }
        }
    }

    if (PEncActive === index)
    {
        delete PEncActive;
        delete PEncInsert;
        PEncKeys = [];
        return false;
    }

    exe.setCurrentPatch(92 + PEncActive);
    exe.emptyPatch(92 + PEncActive);

    var info = FetchPacketinfo();

    PEncKeys[index] = info.keys[index];

    var code =
        " C7 41 04" + PEncKeys[0].packToHex(4) +
        " C7 41 08" + PEncKeys[1].packToHex(4) +
        " C7 41 0C" + PEncKeys[2].packToHex(4) +
        " 33 C0";

    if (HasFramePointer())
    {
        code += "5D";
    }

    code += " C2 04 00";

    var csize = code.hexlength();

    pe.insertHexAt(pe.vaToRaw(PEncInsert), csize, code);

    code = " E9" + (PEncInsert - pe.rawToVa(info.ovrAddr + 5)).packToHex(4);
    pe.replaceHex(info.ovrAddr, code);
    return true;
}

function PacketFirstKeyEncryption()
{
    return PacketEncryptionKeys("$firstkey", 0);
}

function PacketSecondKeyEncryption()
{
    return PacketEncryptionKeys("$secondkey", 1);
}

function PacketThirdKeyEncryption()
{
    return PacketEncryptionKeys("$thirdkey", 2);
}

function _PacketFirstKeyEncryption()
{
    return _PacketEncryptionKeys(0);
}

function _PacketSecondKeyEncryption()
{
    return _PacketEncryptionKeys(1);
}

function _PacketThirdKeyEncryption()
{
    return _PacketEncryptionKeys(2);
}
