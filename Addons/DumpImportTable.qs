

function DumpImportTable()
{
    var offset = pe.getSubSection(1).offset;
    if (offset === -1)
    {
        throw "Wrong offset";
    }

    var fp = new TextFile();
    if (!fp.open(APP_PATH + "/Output/importTable_Dump_" + pe.getDate() + ".txt", "w"))
    {
        throw "Error: Unable to create text file in Output folder";
    }

    fp.writeline("IMPORT TABLE (RAW) = 0x" + offset.toBE());

    for (;; offset += 20)
    {
        var ilt = pe.fetchDWord(offset);
        var ts = pe.fetchDWord(offset + 4);
        var fchain = pe.fetchDWord(offset + 8);
        var dllName = pe.fetchDWord(offset + 12);
        var iatRva = pe.fetchDWord(offset + 16);

        if (dllName <= 0) break;

        dllName = pe.vaToRaw(dllName + pe.getImageBase());
        var offset2 = pe.find("00", dllName);

        fp.writeline("Lookup Table = 0x" + ilt.toBE() +
                ", TimeStamp = " + ts +
                ", Forwarder = " + fchain +
                ", Name = " + pe.fetch(dllName, offset2 - dllName) +
                ", Import Address Table = 0x" + (iatRva + pe.getImageBase()).toBE());

        offset2 = pe.vaToRaw(iatRva + pe.getImageBase());

        for (;; offset2 += 4)
        {
            var funcData = pe.fetchDWord(offset2);

            if (funcData === 0)
            {
                fp.writeline("");
                break;
            }
            else if (funcData > 0)
            {
                funcData &= 0x7FFFFFFF;
                var offset3 = pe.vaToRaw(funcData + pe.getImageBase());
                if (offset3 === -1)
                {
                    break;
                }
                var offset4 = pe.find("00", offset3 + 2);
                fp.writeline("  Thunk Address (RVA) = 0x" + pe.rawToVa(offset2).toBE() +
                    ", Thunk Address(RAW) = 0x" + offset2.toBE() +
                    ", Function Hint = 0x" + pe.fetchHex(offset3, 2).replace(/ /g, "") +
                    ", Function Name = " + pe.fetch(offset3 + 2, offset4 - (offset3 + 2)));
            }
            else
            {
                funcData &= 0xFFFF;
                fp.writeline("  Thunk Address (RVA) = 0x" + pe.rawToVa(offset2).toBE() +
                    ", Thunk Address(RAW) = 0x" + offset2.toBE() +
                    ", Function Ordinal = " + funcData);
            }
        }
    }
    fp.close();

    return "Import Table has been dumped to Output folder";
}
