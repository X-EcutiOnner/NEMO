

function TranslateClient()
{
    var f = new TextFile();
    if (!f.open(APP_PATH + "/Patches/TranslateClient.txt"))
    {
        return "Failed in Step 1 - Unable to open file";
    }

    var offset = -1;
    var msg = "";
    var failmsgs = [];
    var fStr = "";
    var fStr0 = "";
    var rStr = "";

    var found = false;
    while (!f.eof())
    {
        var str = f.readline().trim();

        if (str.charAt(0) === "M")
        {
            msg = str.substring(2).trim();
        }
        else if (str.charAt(0) === "F")
        {
            fStr0 = str;
            str = str.substring(2).trim();

            if (str.charAt(0) === "'")
            {
                str = str.substring(1, str.length - 1);
            }
            else
            {
                str = str.toAscii();
            }
            fStr = str;
        }
        else if (str.charAt(0) === "R")
        {
            offset = pe.stringRaw(fStr);
            if (offset === -1)
            {
                failmsgs.push(msg);
                continue;
            }

            str = str.substring(2).trim();

            if (str.charAt(0) === "'")
            {
                str = str.substring(1, str.length - 1);
                rStr = str;
                pe.replace(offset, str + "\x00");
            }
            else
            {
                rStr = str.toAscii();
                pe.replaceHex(offset, str + " 00");
            }

            if (rStr.length > fStr.length)
            {
                return "Error: translation for '" + fStr0 + "' too long. Lengths: " + rStr.length + " vs " + fStr.length;
            }

            found = true;
            offset = -1;
        }
    }
    f.close();

    if (failmsgs.length != 0)
    {
        var outfile = new TextFile();

        if (outfile.open(APP_PATH + "/FailedTranslations.txt", "w"))
        {
            for (var i = 0; i < failmsgs.length; i++)
            {
                outfile.writeline(failmsgs[i]);
            }
        }

        outfile.close();
    }
    if (found === false)
    {
        return "Found nothing to translate";
    }
    return true;
}
