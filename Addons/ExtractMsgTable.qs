

function ExtractMsgTable()
{
    var offset = table.getRaw(table.msgStringTable) - 4;

    var done = false;
    var id = 0;
    var msgStr = "";

    var fp = new BinFile();
    fp.open(APP_PATH + "/Output/msgstringtable_" + pe.getDate() + ".txt", "w");

    while (!done)
    {
        if (pe.fetchDWord(offset) === id)
        {
            var start_offset = pe.vaToRaw(pe.fetchDWord(offset + 4));
            if (start_offset === -1)
            {
                msgStr = "empty";
            }
            else
            {
                var end_offset = pe.find("00 ", start_offset);
                msgStr = pe.fetch(start_offset, end_offset - start_offset);
            }

            msgStr = msgStr.replace(/\r/g, "\\r");
            msgStr = msgStr.replace(/\n/g, "\\n");
            msgStr = msgStr.replace("#", "_");
            fp.appendLine(msgStr + "#");

            offset += 8;
            id++;
        }
        else
        {
            done = true;
        }
    }

    fp.close();

    return "Success - msgStringTable.txt has been Extracted to Output folder";
}
