

function ExtractMsgTableTranslate()
{
    var offset = table.getRaw(table.msgStringTable) - 4;

    var fp = new TextFile();
    var refList = [];
    var msgStr = "";

    fp.open(APP_PATH + "/Input/msgStringRef.txt", "r");

    var parts;
    var i;
    while (!fp.eof())
    {
        parts = fp.readline().split("#");

        for (i = 1; i <= parts.length; i++)
        {
            msgStr += parts[i - 1].replace(/\\r/g, "0D ").replace(/\\n/g, "0A ");

            if (i < parts.length)
            {
                refList.push(msgStr.toAscii());
                msgStr = "";
            }
        }
    }

    fp.close();

    msgStr = "";
    var index = 0;
    var engMap = {};

    fp = new BinFile();
    fp.open(APP_PATH + "/Input/msgStringEng.txt", "r");
    var data = fp.readHex(0, 0).toAscii();
    fp.close();

    data = data.replace(/\r/g, "").replaceAll("\n", "");

    parts = data.split("#");
    for (i = 1; i <= parts.length; i++)
    {
        msgStr += parts[i - 1];
        msgStr = msgStr.replace("#", "_");

        if (i < parts.length)
        {
            engMap[refList[index]] = msgStr;
            msgStr = "";
            index++;
        }
    }

    var done = false;
    var id = 0;

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

            if (engMap[msgStr])
            {
                fp.appendLine(engMap[msgStr] + "#");
            }
            else
            {
                msgStr = msgStr.replace(/\r/g, "\\r");
                msgStr = msgStr.replace(/\n/g, "\\n");
                msgStr = msgStr.replace("#", "_");
                fp.appendLine(msgStr + "#");
            }

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
