

function resource_getEntry(rTree, hierList)
{
    for (var i = 0; i < hierList.length; i++)
    {
        if (typeof rTree.numEntries === "undefined")
        {
            break;
        }
        for (var j = 0; j < rTree.numEntries; j++)
        {
            if (rTree.entries[j].id === hierList[i])
            {
                break;
            }
        }
        if (j === rTree.numEntries)
        {
            rTree = -(i + 1);
            break;
        }
        rTree = rTree.entries[j];
    }
    return rTree;
}

function resource_file(rsrcAddr, addrOffset, id)
{
    this.id = id;
    this.addr = rsrcAddr + addrOffset;
    this.dataAddr = pe.vaToRaw(pe.fetchDWord(this.addr) + pe.getImageBase());
    this.dataSize = pe.fetchDWord(this.addr + 4);
}

function resource_dir(rsrcAddr, addrOffset, id)
{
    this.id = id;
    this.addr = rsrcAddr + addrOffset;
    this.numEntries = pe.fetchWord(this.addr + 12) + pe.fetchWord(this.addr + 14);
    this.entries = [];

    for (var i = 0; i < this.numEntries; i++)
    {
        id = pe.fetchDWord(this.addr + 16 + i * 8);
        addrOffset = pe.fetchDWord(this.addr + 16 + i * 8 + 4);

        if (addrOffset < 0)
        {
            this.entries.push(new resource_dir(rsrcAddr, addrOffset & 0x7FFFFFFF, id));
        }
        else
        {
            this.entries.push(new resource_file(rsrcAddr, addrOffset, id));
        }
    }
}

function resource_readIconFile(fname)
{
    var fp = new BinFile();
    fp.open(fname);

    var icondir = {};
    var pos = 0;

    icondir.idReserved = fp.readHex(pos, 2).unpackToInt();
    icondir.idType     = fp.readHex(pos + 2, 2).unpackToInt();
    icondir.idCount    = fp.readHex(pos + 4, 2).unpackToInt();
    icondir.idEntries  = [];
    pos += 6;

    for (var i = 0; i < icondir.idCount; i++)
    {
        var icondirentry = {};
        icondirentry.bWidth        = fp.readHex(pos, 1).unpackToInt();
        icondirentry.bHeight       = fp.readHex(pos + 1, 1).unpackToInt();
        icondirentry.bColorCount   = fp.readHex(pos + 2, 1).unpackToInt();
        icondirentry.bReserved     = fp.readHex(pos + 3, 1).unpackToInt();
        icondirentry.wPlanes       = fp.readHex(pos + 4, 2).unpackToInt();
        icondirentry.wBitCount     = fp.readHex(pos + 6, 2).unpackToInt();
        icondirentry.dwBytesInRes  = fp.readHex(pos + 8, 4).unpackToInt();
        icondirentry.dwImageOffset = fp.readHex(pos + 12, 4).unpackToInt();
        icondirentry.iconimage     = fp.readHex(icondirentry.dwImageOffset, icondirentry.dwBytesInRes);
        icondir.idEntries[i]       = icondirentry;
        pos += 16;
    }

    fp.close();

    return icondir;
}

function resource_selectIconFile(varName, def)
{
    var fp = new BinFile();
    var iconfile = GetInputFile(fp, varName, _("File Input - Use Custom Icon"), _("Enter the Icon File"), def);
    if (!iconfile)
    {
        throw "Patch Cancelled";
    }
    fp.close();

    return resource_readIconFile(iconfile);
}

function registerResource()
{
    resource = Object();
    resource.getEntry = resource_getEntry;
    resource.dir = resource_dir;
    resource.file = resource_file;
    resource.readIconFile = resource_readIconFile;
    resource.selectIconFile = resource_selectIconFile;
}
