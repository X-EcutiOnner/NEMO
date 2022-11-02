

function ChangeDefaultBGM()
{
    var org_name = "bgm\\01.mp3";
    var offset = pe.stringVa(org_name);
    if (offset === -1)
    {
        return "Failed in Step 1a - Default BGM file name not found";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1b - Default BGM reference not found";
    }

    var myfile = input.getString(
        "$newBGMPath",
        _("String input - maximum 100 characters"),
        _("Please enter new BGM file path"),
        org_name,
        100
    );
    if (myfile === org_name)
    {
        return "Patch Cancelled - New value is same as old";
    }

    var free = alloc.find(myfile.length);
    if (free === -1)
    {
        return "Failed in Step 2 - Not enough free space";
    }

    pe.insertAt(free, myfile.length, myfile);
    pe.replaceDWord(offset + 1, pe.rawToVa(free));

    return true;
}

function ChangeDefaultBGM_()
{
    return pe.stringRaw("bgm\\01.mp3") !== -1;
}
