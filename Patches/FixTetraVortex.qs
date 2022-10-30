function FixTetraVortex()
{
    for (var i = 1; i <= 8; i++)
    {
        var code = "effect\\tv-" + i + ".bmp";
        var offset = pe.stringRaw(code);
        if (offset === -1)
        {
            return "Failed in Step 1." + i;
        }

        pe.replaceByte(offset, 0);
    }
    return true;
}
