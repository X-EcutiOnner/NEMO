// ######################################################################################
// # Purpose: Find the RVA of the Function specified. Optionally dllName can be used    #
// #          to pinpoint to a DLL and ordinal can be used in case of import by ordinal #
// ######################################################################################

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
