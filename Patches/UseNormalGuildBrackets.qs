

function UseNormalGuildBrackets()
{
    var offset = pe.stringRaw("%s\xA1\xBA%s\xA1\xBB");
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replace(offset, "%s (%s) ");

    return true;
}
