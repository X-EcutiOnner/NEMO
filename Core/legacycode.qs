

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
