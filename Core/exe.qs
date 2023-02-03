//
// Copyright (C) 2020-2023 Andrei Karas (4144)
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

function exe_setJmpVa(patchAddr, jmpAddrVa, cmd, codeLen)
{
    reportLegacy("Please replace exe.setJmpVa to pe.setJmpVa");
}

function exe_setJmpRaw(patchAddr, jmpAddrRaw, cmd, codeLen)
{
    reportLegacy("Please replace exe.setJmpRaw to pe.setJmpRaw");
}

function exe_setNops(patchAddr, nopsCount)
{
    reportLegacy("Please replace exe.setNops to pe.setNops");
}

function exe_setNopsRange(patchStartAddr, patchEndAddr)
{
    reportLegacy("Please replace exe.setNopsRange to pe.setNopsRange");
}

function exe_insertAsmText(commands, vars, freeSpace)
{
    reportLegacy("Please replace exe.insertAsmText to pe.insertAsmText");
}

function exe_insertAsmTextObj(commands, vars, freeSpace, dryRun)
{
    reportLegacy("Please replace exe.insertAsmTextObj to pe.insertAsmTextObj");
}

function exe_insertAsmFile(fileName, vars, freeSpace, dryRun)
{
    reportLegacy("Please replace exe.insertAsmFile to pe.insertAsmFile");
}

function exe_insertDWord(value, dryRun)
{
    reportLegacy("Please replace exe.insertDWord to pe.insertDWord");
}

function exe_insertHex(value)
{
    reportLegacy("Please replace exe.insertHex to pe.insertHex");
}

function exe_replaceAsmText(patchAddr, commands, vars)
{
    reportLegacy("Please replace exe.replaceAsmText to pe.replaceAsmText");
}

function exe_replaceAsmFile(fileName, vars)
{
    reportLegacy("Please replace exe.replaceAsmFile to pe.replaceAsmFile");
}

function exe_match(code, useMask, addrRaw)
{
    reportLegacy("Please replace exe.match to pe.match");
}

function exe_fetchValue(offset, offset2)
{
    reportLegacy("Please replace exe.fetchValue to pe.fetchValue");
}

function exe_fetchValueSimple(offset)
{
    reportLegacy("Please replace exe.fetchValueSimple to pe.fetchValueSimple");
}

function exe_setValue(offset, offset2, value)
{
    reportLegacy("Please replace exe.setValue to pe.setValue");
}

function exe_setValueSimple(offset, value)
{
    reportLegacy("Please replace exe.setValueSimple to pe.setValueSimple");
}

function exe_setShortJmpVa(patchAddr, jmpAddrVa, cmd)
{
    reportLegacy("Please replace exe.setShortJmpVa to pe.setShortJmpVa");
}

function exe_setShortJmpRaw(patchAddr, jmpAddrRaw, cmd)
{
    reportLegacy("Please replace exe.setShortJmpRaw to pe.setShortJmpRaw");
}

function exe_fetchRelativeValue(offset, offset2)
{
    reportLegacy("Please replace exe.fetchRelativeValue to pe.fetchRelativeValue");
}

function exe_fetchHexBytes(offset, offset2)
{
    reportLegacy("Please replace exe.fetchHexBytes to pe.fetchHexBytes");
}

function registerExe()
{
    exe.setJmpVa = exe_setJmpVa;
    exe.setJmpRaw = exe_setJmpRaw;
    exe.setNops = exe_setNops;
    exe.setNopsRange = exe_setNopsRange;
    exe.insertAsmText = exe_insertAsmText;
    exe.insertAsmTextObj = exe_insertAsmTextObj;
    exe.insertAsmFile = exe_insertAsmFile;
    exe.insertDWord = exe_insertDWord;
    exe.insertHex = exe_insertHex;
    exe.replaceAsmText = exe_replaceAsmText;
    exe.replaceAsmFile = exe_replaceAsmFile;
    exe.match = exe_match;
    exe.fetchValue = exe_fetchValue;
    exe.fetchValueSimple = exe_fetchValueSimple;
    exe.fetchHexBytes = exe_fetchHexBytes;
    exe.setValue = exe_setValue;
    exe.setValueSimple = exe_setValueSimple;
    exe.setShortJmpRaw = exe_setShortJmpRaw;
    exe.setShortJmpVa = exe_setShortJmpVa;
    exe.fetchRelativeValue = exe_fetchRelativeValue;
    registerExeLegacy();
}
