

function DisableHallucinationWavyScreen()
{
    var isEffectOn = table.getSessionAbsHex4(table.CSession_isEffectOn);

    var code =
        " 8B ??" +
      " E8 ?? ?? ?? ??" +
      " 83 3D" + isEffectOn + " 00" +
      " 0F 84";

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " 8B ??" +
          " E8 ?? ?? ?? ??" +
          " A1 " + isEffectOn + " 85 C0" +
          " 0F 84";
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    pe.replaceHex(offset + code.hexlength() - 2, "90 E9");

    return true;
}
