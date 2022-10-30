

function DisableChatInSkill(txtname)
{
    var offset = pe.stringRaw("english\\" + txtname);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offset, 0);

    offset = pe.stringRaw(txtname);
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    pe.replaceByte(offset, 0);

    return true;
}

function DisableBAFrostJoke()
{
    return DisableChatInSkill("BA_frostjoke.txt");
}

function DisableDCScream()
{
    return DisableChatInSkill("DC_scream.txt");
}
