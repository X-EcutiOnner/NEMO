

function RenameLicenseTxt()
{
    var offset = pe.stringVa("..\\licence.txt");
    if (offset === -1)
    {
        return "Failed in Step 1 - File string missing";
    }

    offset = pe.findCode(" C7 05 ?? ?? ?? 00" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - String reference missing";
    }

    var txtFile = input.getString(
        "$licenseTXT",
        _("String Input"),
        _("Enter the name of the Txt file"),
        "..\\licence.txt",
        20
    );
    if (txtFile === "" || txtFile === "..\\licence.txt")
    {
        return "Failed in Step 2 - Patch Cancelled";
    }

    txtFile += "\x00";

    var free = alloc.find(txtFile.length);
    if (free === -1)
    {
        return "Failed in Step 2 - Not enough free space";
    }

    pe.insertAt(free, txtFile.length, txtFile);

    pe.replaceDWord(offset + 6, pe.rawToVa(free));

    offset = pe.stringVa("No EULA text file. (licence.txt)");
    if (offset === -1)
    {
        return "Failed in Step 3 - Error string missing";
    }

    txtFile = "No EULA text file. (" + txtFile.replace("..\\", "").replace("\x00", ")\x00");

    free = alloc.find(txtFile.length);
    if (free === -1)
    {
        return "Failed in Step 3 - Not enough free space";
    }

    pe.insertAt(free, txtFile.length, txtFile);

    var prefixes = [" 6A 20 68", " BE", " BF"];
    var freeRva = pe.rawToVa(free);

    for (var i = 0; i < prefixes.length; i++)
    {
        var offsets = pe.findCodes(prefixes[i] + offset.packToHex(4));
        for (var j = 0; j < offsets.length; j++)
        {
            pe.replaceDWord(offsets[j] + prefixes[i].hexlength(), freeRva);
        }
    }

    return true;
}
