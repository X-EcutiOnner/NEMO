

function RemoveGravityLogo()
{
    var offset = pe.halfStringRaw("\\T_R%d.tga");
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offset + 1, 0);

    return true;
}
