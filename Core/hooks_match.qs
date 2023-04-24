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

function hooks_matchFunctionStart(storageKey, offset)
{
    checkArgs("hooks.matchFunctionStart", arguments, [["Number", "Number"]]);

    var offsetVa = pe.rawToVa(offset);

    var code =
        "55 " +
        "8B EC " +
        "53 " +
        "8B D9 ";
    var stolenCodeOffset = [0, 6];
    var continueOffset = 6;
    var found = pe.match(code, offset);

    if (found !== true)
    {
        code =
            "53 " +
            "56 " +
            "8B F1 " +
            "8B 4E ??";
        stolenCodeOffset = [0, 7];
        continueOffset = 7;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "55 " +
            "8B EC " +
            "53 " +
            "56";
        stolenCodeOffset = [0, 5];
        continueOffset = 5;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "55 " +
            "8B EC " +
            "6A FF ";
        stolenCodeOffset = [0, 5];
        continueOffset = 5;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "6A FF " +
            "68 ?? ?? ?? ??";
        stolenCodeOffset = [0, 7];
        continueOffset = 7;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "55 " +
            "8B EC " +
            "8B 55 ?? ";
        stolenCodeOffset = [0, 6];
        continueOffset = 6;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "55 " +
            "8B EC " +
            "8B 45 ?? ";
        stolenCodeOffset = [0, 6];
        continueOffset = 6;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "8B 44 24 ?? " +
            "56 ";
        stolenCodeOffset = [0, 5];
        continueOffset = 5;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "55 " +
            "8B EC " +
            "83 EC ?? ";
        stolenCodeOffset = [0, 6];
        continueOffset = 6;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "55 " +
            "8B EC " +
            "81 EC ?? ?? ?? 00 ";
        stolenCodeOffset = [0, 9];
        continueOffset = 9;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "83 EC ?? " +
            "53 " +
            "55 ";
        stolenCodeOffset = [0, 5];
        continueOffset = 5;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "83 EC ?? " +
            "55 " +
            "56 ";
        stolenCodeOffset = [0, 5];
        continueOffset = 5;
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        throw "Function start pattern not found: 0x" + offsetVa.toString(16);
    }
    var obj = hooks.createHookObj();
    obj.patchAddr = offset;
    obj.stolenCode = pe.fetchHexBytes(offset, stolenCodeOffset);
    obj.stolenCode1 = obj.stolenCode;
    obj.continueOffsetVa = offsetVa + continueOffset;
    obj.retCode = "";
    obj.endHook = false;
    return obj;
}

function hooks_matchFunctionTableStart(storageKey, offsets)
{
    var offset = offsets[0];
    var stackSize = offsets[1];
    var isCdecl = offsets[2];
    if (typeof isCdecl === "undefined")
    {
        isCdecl = false;
    }

    var obj = hooks_matchFunctionStart(storageKey, offset);
    obj.stolenCode = hooks.duplicateStackCode(obj.continueOffsetVa, stackSize, isCdecl, obj.stolenCode);
    obj.stolenCode1 = obj.stolenCode;
    var retSize;
    if (isCdecl)
    {
        retSize = 0;
    }
    else
    {
        retSize = stackSize;
    }
    obj.retCode = asm.retHex(retSize) + obj.retCode;
    obj.endHook = true;
    return obj;
}

function hooks_matchFunctionEnd(storageKey, offset)
{
    checkArgs("hooks.matchFunctionEnd", arguments, [["Number", "Number"]]);

    var code =
        "5B " +
        "5D " +
        "C2 ?? ??";
    var callOffset = 0;
    var stolenCodeOffset = [0, 5];
    var stolenCode1Offset = [0, 2];
    var retOffset = [2, 3];
    var found = pe.match(code, offset);

    if (found !== true)
    {
        code =
            "5E " +
            "5B " +
            "C2 ?? ??";
        callOffset = 0;
        stolenCodeOffset = [0, 5];
        stolenCode1Offset = [0, 2];
        retOffset = [2, 3];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "8B E5 " +
            "5D " +
            "C2 ?? ?? ";
        callOffset = 0;
        stolenCodeOffset = [0, 6];
        stolenCode1Offset = [0, 3];
        retOffset = [3, 3];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "83 C4 ?? " +
            "C2 ?? ??";
        callOffset = 0;
        stolenCodeOffset = [0, 6];
        stolenCode1Offset = [0, 3];
        retOffset = [3, 3];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "81 C4 ?? 00 00 00 " +
            "C2 ?? ?? ";
        callOffset = 0;
        stolenCodeOffset = [0, 9];
        stolenCode1Offset = [0, 6];
        retOffset = [6, 3];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "5E " +
            "8B E5 " +
            "5D " +
            "C3 ";
        callOffset = 0;
        stolenCodeOffset = [0, 5];
        stolenCode1Offset = [0, 4];
        retOffset = [4, 1];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "5E " +
            "83 C4 ?? " +
            "C3 ";
        callOffset = 0;
        stolenCodeOffset = [0, 5];
        stolenCode1Offset = [0, 4];
        retOffset = [4, 1];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "5B " +
            "83 C4 ?? " +
            "C3 ";
        callOffset = 0;
        stolenCodeOffset = [0, 5];
        stolenCode1Offset = [0, 4];
        retOffset = [4, 1];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "E8 ?? ?? ?? ?? " +
            "8B E5 " +
            "5D " +
            "C3 ";
        callOffset = [1, 4];
        stolenCodeOffset = [5, 4];
        stolenCode1Offset = [5, 3];
        retOffset = [8, 1];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "64 89 0D 00 00 00 00 " +
            "8B E5 " +
            "5D " +
            "C3 ";
        callOffset = 0;
        stolenCodeOffset = [0, 11];
        stolenCode1Offset = [0, 10];
        retOffset = [10, 1];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        code =
            "81 C4 ?? ?? ?? 00 " +
            "C3 ";
        callOffset = 0;
        stolenCodeOffset = [0, 7];
        stolenCode1Offset = [0, 6];
        retOffset = [6, 1];
        found = pe.match(code, offset);
    }

    if (found !== true)
    {
        throw "Pattern not found for address: 0x" + pe.rawToVa(offset).toString(16);
    }
    var callBytes = "";
    if (callOffset !== 0)
    {
        var text = asm.load("include/AbsCall");
        var vars = {
            "callOffset": pe.fetchRelativeValue(offset, callOffset),
        };
        callBytes = asm.textToHexVa(0, text, vars);
    }
    var obj = hooks.createHookObj();
    obj.patchAddr = offset;
    obj.stolenCode = callBytes + pe.fetchHexBytes(offset, stolenCodeOffset);
    obj.stolenCode1 = callBytes + pe.fetchHexBytes(offset, stolenCode1Offset);
    obj.retCode = pe.fetchHexBytes(offset, retOffset);
    obj.continueOffsetVa = 0;
    obj.endHook = true;
    return obj;
}

function hooks_matchImportUsage_code(codes, offset, importOffset)
{
    var hexImportOffset = importOffset.packToHex(4);

    for (var i = 0; i < codes.length; i ++)
    {
        var found = pe.match(codes[i] + hexImportOffset, offset);
        var addrOffset = 2;
        if (found === true)
        {
            break;
        }
    }

    if (found !== true)
    {
        throw "Import usage with address 0x" + importOffset.toString(16) + " not found.";
    }

    var obj = hooks.createHookObj();
    obj.patchAddr = offset + addrOffset;
    obj.retCode = "FF 25" + hexImportOffset;
    obj.endHook = true;
    obj.importOffset = importOffset;
    obj.firstJmpType = hooks.jmpTypes.IMPORT;
    return obj;
}

function hooks_matchImportCallUsage(offset, importOffset)
{
    return hooks_matchImportUsage_code(
        [
            "FF 15",
        ],
        offset, importOffset
    );
}

function hooks_matchImportJmpUsage(offset, importOffset)
{
    return hooks_matchImportUsage_code(
        [
            "FF 25",
        ],
        offset, importOffset
    );
}

function hooks_matchImportMovUsage(offset, importOffset)
{
    return hooks_matchImportUsage_code(
        [
            "8B 3D",
            "8B 35",
        ],
        offset, importOffset
    );
}

function hooks_matchImportUsage(offset, importOffset)
{
    return hooks_matchImportUsage_code(
        [
            "FF 15",
            "FF 25",
            "8B 3D",
            "8B 35",
        ],
        offset, importOffset
    );
}

function hooks_matchFunctionReplace(storageKey, offset)
{
    checkArgs("hooks.matchFunctionReplace", arguments, [["Number", "Number"]]);
    var obj = hooks.createHookObj();
    obj.patchAddr = offset;
    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";
    obj.continueOffsetVa = 0;
    obj.endHook = true;
    return obj;
}
