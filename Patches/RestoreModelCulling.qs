

function RestoreModelCulling()
{
    var offsets = pe.findCodes(" 80 BE 54 01 00 00 01");

    var i;
    if (offsets.length === 2)
    {
        for (i = 0; i < offsets.length; i++)
        {
            if (pe.fetchUByte(offsets[i] + 7) != 0x75)
            {
                return "Failed in Step 1a - No JNZ found.";
            }
            pe.replaceHex(offsets[i] + 7, " 90 90");
        }
        return true;
    }

    var pBase = pe.findCode(" 8D 86 30 01 00 00 50");
    if (pBase === -1)
    {
        return "Failed in Step 1 - No match for C3dActor::CullByOBB!";
    }

    var jmpCodes = [" 74 1D", " 74 1E", " 74 1F"];
    var pJmpHideCheck = -1;

    for (i = 0; i < jmpCodes.length; i++)
    {
        pJmpHideCheck = pe.find(jmpCodes[i], pBase - 10, pBase);
        if (pJmpHideCheck !== -1)
        {
            break;
        }
    }

    if (pJmpHideCheck === -1)
    {
        return "Failed in Step 2 - Missing jump condition for m_isHideCheck";
    }

    pe.replaceHex(pJmpHideCheck, " 90 90");

    var pSetAlpha = pe.find(" 8B 0E E8", pBase + 7, pBase + 30);
    if (pSetAlpha === -1)
    {
        return "Failed in Step 3 - Missing SetToAlpha call";
    }

    pe.replaceHex(pSetAlpha, " C6 86 EC 01 00 00 01");

    return true;
}
