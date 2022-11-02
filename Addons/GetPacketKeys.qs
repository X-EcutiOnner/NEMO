

function GetPacketKeys()
{
    var info = FetchPacketKeyInfo();

    if (typeof info === "string")
    {
        throw info;
    }

    if (info.type === -1)
    {
        throw "Failed to find any Patterns";
    }

    var keys = [];
    keys[0] = "0x" + info.keys[0].toBE();
    keys[1] = "0x" + info.keys[1].toBE();
    keys[2] = "0x" + info.keys[2].toBE();

    var fp = new TextFile();
    fp.open(APP_PATH + "/Output/PacketKeys_" + pe.getDate() + ".txt", "w");
    fp.writeline("Packet Keys : (" + keys.join(",") + ")");
    fp.close();

    return "Packet Keys have been written to Output folder";
}
