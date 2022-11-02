

function ExtractTxtNames()
{
    var offset = pe.sectionRaw(DATA)[0];
    var offsets = pe.findAll(" 2E 74 78 74 00", offset, pe.sectionRaw(DATA)[1]);
    if (offsets.length === 0)
    {
        throw "Error: No .txt files found";
    }

    var fp = new TextFile();
    fp.open(APP_PATH + "/Output/loaded_txt_files_" + pe.getDate() + ".txt", "w");
    fp.writeline("Extracted with NEMO");
    fp.writeline("-------------------");

    for (var i = 0; i < offsets.length; i++)
    {
        offset = offsets[i];
        var end = offset + 3;
        do
        {
            offset--;
            var code = pe.fetchByte(offset);
        } while (code !== 0 && code !== 0x40);

        var str = pe.fetch(offset + 1, end - offset);
        if (str !== ".txt")
        {
            fp.writeline(str);
        }
    }

    fp.close();

    return "Txt File list has been extracted to Output folder";
}
