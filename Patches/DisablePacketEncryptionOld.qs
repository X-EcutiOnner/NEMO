

function DisablePacketEncryptionOld()
{
    var patches = getActivePatches();
    for (var i = 0; i < 3; i++)
    {
        if (patches.indexOf(92 + i) !== -1)
        {
            return "Patch Cancelled - One or more of the Packet Key Patches are ON";
        }
    }

    var info = FetchPacketKeyInfo();
    if (typeof info === "string")
    {
        return info;
    }

    var code = info.refMov;

    if (info.type !== 0)
    {
        code += " 6A 00";
    }

    code += " E8";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    code =
        " 33 C0" +
        " EB" + code.hexlength().packToHex(1);

    pe.replaceHex(offset, code);

    return true;
}

function DisablePacketEncryptionOld_()
{
    return table.get(table.comboFunction) <= 0;
}
