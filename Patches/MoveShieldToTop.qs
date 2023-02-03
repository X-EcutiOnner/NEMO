//
// Copyright (C) 2018-2023 Andrei Karas (4144)
//
// Hercules is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// #############################################################
// # Change shield z offset to draw shield over other sprites  #
// # in CPc_RenderBodyLayer                                    #
// #############################################################

function MoveShieldToTopPatch(floatAddr, offset, offset2, patchAddrOffset, continueOffset, cntOffset)
{
    var oowOffset = 0x10;
    var oowUpOffset = 0x14;
    var stolenCodeSize = 7;
    var patchAddr = offset + patchAddrOffset;
    var continueAddr = pe.rawToVa(offset) + continueOffset;
    var stolenCode = pe.fetchHex(offset + patchAddrOffset, stolenCodeSize);
    var cntHex = pe.fetchDWord(offset2 + cntOffset).packToHex(4);

    var code =
        stolenCode +

        "8B 85 " + cntHex +
        "83 F8 00 " +
        "75 26" +
        "58" +
        "50 " +
        "F3 0F 10 40 " + oowOffset.packToHex(1) +
        "F3 0F 58 05 " + floatAddr.packToHex(4) +
        "F3 0F 11 40 " + oowOffset.packToHex(1) +
        "F3 0F 10 40 " + oowUpOffset.packToHex(1) +
        "F3 0F 58 05 " + floatAddr.packToHex(4) +
        "F3 0F 11 40 " + oowUpOffset.packToHex(1) +
        "B8" + continueAddr.packToHex(4) +
        "FF E0" +
        "";

    var free = alloc.find(code.hexlength());
    if (free === -1)
    {
        throw "Not enough free space";
    }
    pe.insertHexAt(free, code.hexlength(), code);

    pe.setJmpRaw(patchAddr, free);
}

function MoveShieldToTop()
{
    var floatAddr = alloc.find(4);
    if (floatAddr === -1)
    {
        return "Not enough free space";
    }
    var code =

        floatToHex(0.001);
    pe.insertHexAt(floatAddr, 4, code);
    floatAddr = pe.rawToVa(floatAddr);

    code =
        getEcxSessionHex() +
        "E8 ?? ?? ?? ?? " +
        "83 EC 08 " +
        "3C 01 " +
        "8B 45 ?? " +
        "8B CF " +
        "75 25 " +
        "F3 0F 10 45 ?? " +
        "F3 0F 11 44 24 ?? " +
        "F3 0F 10 45 ?? " +
        "F3 0F 11 04 ?? " +
        "56 " +
        "50 " +
        "8D 85 ?? ?? ?? ?? " +
        "50 " +
        "E8 ?? ?? ?? ?? " +
        "EB 1D " +
        "C7 44 24 ?? 00 00 00 00 " +
        "C7 04 ?? 00 00 00 00 " +
        "56 " +
        "50 " +
        "8D 85 ?? ?? ?? ?? " +
        "50 " +
        "E8 ";
    var sprOffset1 = 47;
    var sprOffset2 = 78;
    var aOffset1 = 32;
    var aOffset2 = 62;
    var bOffset1 = 42;
    var bOffset2 = 69;
    var patchAddrOffset1 = 45;
    var continueOffset1 = 52;
    var patchAddrOffset2 = 76;
    var continueOffset2 = 83;
    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        code =
            getEcxSessionHex() +
            "E8 ?? ?? ?? ?? " +
            "3C 01 " +
            "75 2D " +
            "F3 0F 10 45 ?? " +
            "8B 45 ?? " +
            "83 EC 08 " +
            "8B CF " +
            "F3 0F 11 44 24 ?? " +
            "F3 0F 10 45 ?? " +
            "F3 0F 11 04 ?? " +
            "56 " +
            "50 " +
            "8D 85 ?? ?? ?? ?? " +
            "50 " +
            "E8 ?? ?? ?? ?? " +
            "EB 50 " +
            "83 7D ?? ?? " +
            "75 25 " +
            "0F BE 45 ?? " +
            "48 " +
            "74 13 " +
            "48 " +
            "75 1B " +
            "85 DB " +
            "74 05 " +
            "83 FB ?? " +
            "75 12 " +
            "BE ?? ?? ?? ?? " +
            "EB 0B " +
            "83 FB ?? " +
            "B8 ?? ?? ?? ?? " +
            "0F 44 F0 " +
            "8B 45 ?? " +
            "83 EC 08 " +
            "8B CF " +
            "C7 44 24 ?? 00 00 00 00 " +
            "C7 04 ?? 00 00 00 00 " +
            "56 " +
            "50 " +
            "8D 85 ?? ?? ?? ?? " +
            "50 " +
            "E8 ";

        sprOffset1 = 47;
        sprOffset2 = 129;
        aOffset1 = 32;
        aOffset2 = 113;
        bOffset1 = 42;
        bOffset2 = 120;
        patchAddrOffset1 = 45;
        continueOffset1 = 52;
        patchAddrOffset2 = 127;
        continueOffset2 = 134;
        offsets = pe.findCodes(code);
    }

    if (offsets.length === 0)
    {
        return "Failed in Step 2 - pattern not found";
    }
    if (offsets.length !== 1)
    {
        return "Failed in Step 2 - found too many patterns";
    }

    var offset = offsets[0];

    var spr1 = pe.fetchDWord(offset + sprOffset1);
    var spr2 = pe.fetchDWord(offset + sprOffset2);
    if (spr1 != spr2)
    {
        return "Failed in Step 2 - found different spr offsets";
    }
    var a1 = pe.fetchUByte(offset + aOffset1);
    var a2 = pe.fetchUByte(offset + aOffset2);
    if (a1 != a2)
    {
        return "Failed in Step 2 - found different a offsets";
    }
    var b1 = pe.fetchUByte(offset + bOffset1);
    var b2 = pe.fetchUByte(offset + bOffset2);
    if (b1 != b2)
    {
        return "Failed in Step 2 - found different b offsets";
    }

    code =
        "BB 07 00 00 00 " +
        "89 9D ?? ?? ?? ?? " +
        "8B 4F ?? " +
        "8B 57 ?? " +
        "8B C1 " +
        "2B 47 ?? " +
        "83 C0 FE " +
        "83 F8 03 ";
    var cntOffset = 7;

    var offset2 = pe.find(code, offset - 0x1000, offset);
    if (offset2 === -1)
    {
        return "Failed in step 3 - cnt not found";
    }

    MoveShieldToTopPatch(floatAddr, offset, offset2, patchAddrOffset1, continueOffset1, cntOffset);
    MoveShieldToTopPatch(floatAddr, offset, offset2, patchAddrOffset2, continueOffset2, cntOffset);

    return true;
}
