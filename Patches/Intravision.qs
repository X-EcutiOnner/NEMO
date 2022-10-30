
function Intravision()
{
    var code =
        " 0F 84 ?? ?? ?? ??"   +
        " 83 C0 ??"   +
        " 3B C1"   +
        " 75";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceHex(offset, " 90 E9");

    return true;
}
