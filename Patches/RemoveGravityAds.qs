

function RemoveGravityAds()
{
    var offset = pe.halfStringRaw("\\T_\xC1\xDF\xB7\xC2\xBC\xBA\xC0\xCE.tga");
    if (offset !== -1)
    {
        pe.replaceByte(offset + 1, 0);
    }
    else if (!IsZero())
    {
        return "Failed in Step 1";
    }

    offset = pe.halfStringRaw("\\T_GameGrade.tga");
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    pe.replaceByte(offset + 1, 0);

    offset = pe.halfStringRaw("\\T_\xC5\xD7\xC0\xD4%d.tga");
    if (offset === -1)
    {
        return "Failed in Step 3";
    }

    pe.replaceByte(offset + 1, 0);

    return true;
}
