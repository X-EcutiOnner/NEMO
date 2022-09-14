//==================================================================//
// UseRagnarokIcon patch is already achieved in UseCustomIcon patch //
// so we use the true argument to make the patch stop there         //
//==================================================================//

function UseRagnarokIcon()
{
    return UseCustomIcon(true);
}

//###################################################################################
//# Purpose: Modify Resource Table to use the 8bpp 32x32 icon present in the client # <- UseRagnarokIcon stops here
//#          and overwrite the icon data with the one from user specified icon file #
//###################################################################################

function UseCustomIcon(nomod)
{

  //Step 1a - Find Resource Table
  var offset = pe.getSubSection(2).offset;
  if (offset === -1)
    throw "found wrong offset in GetDataDirectory";

  //Step 1b - Get the Resource Tree (Check the function in core)
  var rsrcTree = new resource.dir(offset, 0, 0);

  //Step 2a - Find the resource dir of RT_GROUP_ICON = 0xE (check the function in core)
  var entry = resource.getEntry(rsrcTree, [0xE]);
  if (entry === -1)
    return "Failed in Step 2 - Unable to find icongrp";

  offset = entry.addr + 0x10;
  var id = pe.fetchDWord(offset);

  //Step 2b - Adjust 114 subdir to use 119 data - thus same icon will be used for both
  if (id === 119)
  {
    var newvalue = pe.fetchDWord(offset + 0x4);
    pe.replaceDWord(offset + 0x8 + 0x4, newvalue);
  }
  else
  {
    var newvalue = pe.fetchDWord(offset + 0x8 + 0x4);
    pe.replaceDWord(offset + 0x4, newvalue);
  }

  if (nomod)
    return true;

  //============================================//
  // Now that icon is enabled lets overwrite it //
  //============================================//

  //Step 4 - Find the RT_GROUP_ICON , 119, 1042 resource entry address
  var entry = resource.getEntry(rsrcTree, [0xE, 0x77, 0x412]);//RT_GROUP_ICON , 119, 1042
  switch (entry)
  {
    case -2: return "Failed in Step 4 - Unable to find icongrp/lang";
    case -3: return "Failed in Step 4 - Unable to find icongrp/lang/bundle";
  }

  var icogrpOff = entry.dataAddr;

  //Step 5a - Load the new icon
  var icondir = resource.selectIconFile("$inpIconFile", APP_PATH + "/Input/NEMO.ico");

  //Step 5b - Find the image that meets the spec = 8bpp 32x32
  for (var i = 0; i < icondir.idCount; i++)
  {
    var entry = icondir.idEntries[i];
    if (entry.bHeight == 32 && entry.bWidth == 32 && entry.wBitCount == 8 && entry.bColorCount == 0)
      break;
  }

  if (i === icondir.idCount)
    return "Invalid icon file specified";

  var icondirentry = icondir.idEntries[i];

  //Step 6 - Find a valid RT_ICON - colorcount = 0, bpp = 8, and ofcourse the id will belong to valid resource
  var idCount = pe.fetchWord(icogrpOff + 4);
  var pos = icogrpOff + 6;

  for (var i = 0; i < idCount; i++)
  {
    var memicondirentry = new Object();
    memicondirentry.bWidth       = pe.fetchByte(pos);
    memicondirentry.bHeight      = pe.fetchByte(pos+1);
    memicondirentry.bColorCount  = pe.fetchByte(pos+2);
    memicondirentry.bReserved    = pe.fetchByte(pos+3);
    memicondirentry.wPlanes      = pe.fetchWord(pos+4);
    memicondirentry.wBitCount    = pe.fetchWord(pos+6);
    memicondirentry.dwBytesInRes = pe.fetchDWord(pos+8);
    memicondirentry.nID          = pe.fetchWord(pos+12);

    if (memicondirentry.bColorCount == 0 && memicondirentry.wBitCount == 8 && memicondirentry.bWidth == 32 && memicondirentry.bWidth == 32)
    { //8bpp 32x32 image
      entry = resource.getEntry(rsrcTree, [0x3, memicondirentry.nID, 0x412]);//returns negative number on fail or ResourceEntry object on success
      if (entry < 0) continue;
      break;
    }

    pos += 14;
  }

  if (i === idCount)
    return "Failed in Step 6 - no suitable icon found in exe";

  if (memicondirentry.dwBytesInRes < icondirentry.dwBytesInRes)
    return "Failed in Step 6 - Icon wont fit";//size should be 40 (header) + 256*4 (palette) + 32*32 (xor mask) + 32*32/8 (and mask)

  //Step 7a - Update the size in bytes dwBytesInRes and wPlanes as per the uploaded icon
  pe.replaceWord(pos - 14 + 4, icondirentry.wPlanes);
  pe.replaceWord(pos - 14 + 8, icondirentry.dwBytesInRes);

  //Step 7b - Finally update the icon image
  pe.replaceDWord(entry.addr + 4, icondirentry.dwBytesInRes);
  pe.replaceHex(entry.dataAddr, icondirentry.iconimage);

  return true;
}
