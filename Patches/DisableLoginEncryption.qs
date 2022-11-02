

function DisableLoginEncryption()
{
    var code =
        " E8 ?? ?? ?? FF" +
        " B9 06 00 00 00" +
        " 8D";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - Encryptor call missing";
    }

    var regPush = pe.fetchByte(offset - 1) - 0x50;

    offset += code.hexlength();
    code =
        ((pe.fetchUByte(offset) & 0x38) | regPush).packToHex(1) +
        " 90 90 90 90";

    pe.replaceHex(offset, code);

    return true;
}

function DisableLoginEncryption_()
{
    return pe.getDate() < 20100803;
}
