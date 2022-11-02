//
// Copyright (C) 2020  CH.C
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

function AutoMute()
{
    var code =
        " 68 ?? ?? ?? ??" +
        " E8 ?? ?? ?? ??" +
        " 50" +
        " 8B CE" +
        " E8 ?? ?? ?? ??" +
        " 8B 35 ?? ?? ?? ??" +
        " 8B CE" +
        " E8 ?? ?? ?? ??" +
        " 50" +
        " 8B CE" +
        " E8 ?? ?? ?? ??" +
        " 8B 0D ?? ?? ?? ??" +
        " 57" +
        " E8 ?? ?? ?? ??" +
        " 8B 0D ?? ?? ?? ??" +
        " 57" +
        " E8 ?? ?? ?? ??";

    var SetStreamVolumeOffset = 14;
    var Set2DEffectVolumeOffset = 47;
    var Set3DEffectVolumeOffset = 59;
    var soundMgrOffsets = [20, 41, 53];

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        code =
            "68 ?? ?? ?? ?? " +
            "8B CB " +
            "8B F8 " +
            "E8 ?? ?? ?? ?? " +
            "50 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B 35 ?? ?? ?? ?? " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "50 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "8B 0D ?? ?? ?? ?? " +
            "57 " +
            "E8 ?? ?? ?? ?? " +
            "8B 0D ?? ?? ?? ?? " +
            "57 " +
            "E8 ?? ?? ?? ?? ";
        SetStreamVolumeOffset = 18;
        Set2DEffectVolumeOffset = 51;
        Set3DEffectVolumeOffset = 63;
        soundMgrOffsets = [24, 45, 57];

        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    var soundMgr = pe.fetchHex(offset + soundMgrOffsets[0], 4);
    var SetBgmFuncAddr = pe.rawToVa(offset + SetStreamVolumeOffset + 4) + pe.fetchDWord(offset + SetStreamVolumeOffset);
    var SetEff2DFuncAddr = pe.rawToVa(offset + Set2DEffectVolumeOffset + 4) + pe.fetchDWord(offset + Set2DEffectVolumeOffset);
    var SetEff3DFuncAddr = pe.rawToVa(offset + Set3DEffectVolumeOffset + 4) + pe.fetchDWord(offset + Set3DEffectVolumeOffset);

    code =
        "85 C0 " +
        "75 1A " +
        "8B 0D ?? ?? ?? ?? " +
        "6A 00 " +
        "6A 00 " +
        "6A 00 " +
        "8B 01 " +
        "6A 00 " +
        "6A 23 " +
        "6A 00 " +
        "FF 90 ?? 00 00 00 ";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        code =
            "85 C0 " +
            "75 1A " +
            "8B 0D ?? ?? ?? ?? " +
            "6A 00 " +
            "8B 01 " +
            "6A 00 " +
            "6A 00 " +
            "6A 00 " +
            "6A 23 " +
            "6A 00 " +
            "FF 90 ?? 00 00 00 ";

        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in Step 2a";
    }

    code =
        "E8 ?? ?? ?? ?? " +
        "B9 ?? ?? ?? ?? " +
        "E8 ?? ?? ?? ?? " +
        "83 3D ?? ?? ?? ?? 00 " +
        "75 0D " +
        "83 3D ?? ?? ?? ?? 00 " +
        "0F 85 ";
    var jmpOffset = 5;

    offset = pe.find(code, offset, offset + 0x500);

    if (offset === -1)
    {
        return "Failed in Step 2b";
    }

    var jumpAddr = offset + jmpOffset;

    var varCode = pe.fetchHex(jumpAddr, 5);

    var GetActiveWindow = imports.ptrValidated("GetActiveWindow", "User32.dll");

    code =
        " FF D7" +
        " 3B 05" + GenVarHex(1) +
        " 0F 8C 9A 00 00 00" +
        " 05 F4 01 00 00" +
        " A3" + GenVarHex(1) +
        " 83 3D" + GenVarHex(2) + " 01" +
        " 74 1C" +
        " 8B 0D" + soundMgr +
        " 8B 81 EC 00 00 00" +
        " A3" + GenVarHex(3) +
        " 8B 81 F0 00 00 00" +
        " A3" + GenVarHex(4) +
        " FF 15" + GetActiveWindow.packToHex(4) +
        " 8B 0D" + soundMgr +
        " 85 C0" +
        " 74 33" +
        " 83 3D" + GenVarHex(2) + " 00" +
        " 74 52" +
        " 31 C0" +
        " A3" + GenVarHex(2) +
        " FF 35" + GenVarHex(4) +
        " E8" + GenVarHex(5) +
        " FF 35" + GenVarHex(4) +
        " E8" + GenVarHex(6) +
        " FF 35" + GenVarHex(3) +
        " E8" + GenVarHex(7) +
        " EB 28" +
        " 83 3D" + GenVarHex(2) + " 01" +
        " 74 1F" +
        " B8 01 00 00 00" +
        " A3" + GenVarHex(2) +
        " 6A 00" +
        " E8" + GenVarHex(5) +
        " 6A 00" +
        " E8" + GenVarHex(6) +
        " 6A 00" +
        " E8" + GenVarHex(7) +
        varCode +
        " C3";

    var buffer =
        " 00 00 00 00" +
        " 00 00 00 00" +
        " 64 00 00 00" +
        " 64 00 00 00";

    var size = buffer.hexlength() + code.hexlength() + 4;
    var free = alloc.find(size + 8);
    if (free === -1)
    {
        return "Failed in Step 4 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);
    var ins = buffer + code;
    var i;

    for (i = 0; i < 2; i++)
    {
        ins = ReplaceVarHex(ins, 1, freeRva);
    }

    for (i = 0; i < 5; i++)
    {
        ins = ReplaceVarHex(ins, 2, freeRva + 4);
    }

    for (i = 0; i < 2; i++)
    {
        ins = ReplaceVarHex(ins, 3, freeRva + 8);
    }

    for (i = 0; i < 3; i++)
    {
        ins = ReplaceVarHex(ins, 4, freeRva + 12);
    }

    var offsets = [100, 150];
    for (i = 0; i < 2; i++)
    {
        ins = ReplaceVarHex(ins, 5, SetEff2DFuncAddr - (freeRva + 16 + offsets[i] + 4));
    }

    offsets = [111, 157];
    for (i = 0; i < 2; i++)
    {
        ins = ReplaceVarHex(ins, 6, SetEff3DFuncAddr - (freeRva + 16 + offsets[i] + 4));
    }

    offsets = [122, 164];
    for (i = 0; i < 2; i++)
    {
        ins = ReplaceVarHex(ins, 7, SetBgmFuncAddr - (freeRva + 16 + offsets[i] + 4));
    }

    pe.insertHexAt(free, size, ins);

    code = " E8" + ((freeRva + 16) - pe.rawToVa(jumpAddr + 5)).packToHex(4);

    pe.replaceHex(jumpAddr, code);

    return true;
}
