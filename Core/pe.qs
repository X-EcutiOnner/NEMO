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

function pe_find(code, startRaw, endRaw)
{
    checkArgs("pe.find", arguments, [["String"], ["String", "Number"], ["String", "Number", "Number"]]);

    if (typeof startRaw === "undefined")
    {
        startRaw = 0;
        endRaw = 0x7fffffff;
    }
    else if (typeof endRaw === "undefined")
    {
        endRaw = 0x7fffffff;
    }
    return pe.findMaskInternal(code, startRaw, endRaw);
}

function pe_findAll(code, startRaw, endRaw)
{
    checkArgs("pe.findAll", arguments, [["String"], ["String", "Number"], ["String", "Number", "Number"]]);

    if (typeof startRaw === "undefined")
    {
        startRaw = 0;
        endRaw = 0x7fffffff;
    }
    else if (typeof endRaw === "undefined")
    {
        endRaw = 0x7fffffff;
    }
    var offsets = [];
    var offset = pe.findMaskInternal(code, startRaw, endRaw);
    var sz = code.hexlength();
    while (offset !== -1)
    {
        offsets.push(offset);
        startRaw = offset + sz;
        offset = pe.findMaskInternal(code, startRaw, endRaw);
    }
    return offsets;
}

function pe_findCode(code)
{
    checkArgs("pe.findCode", arguments, [["String"]]);

    var sect = pe.sectionRaw(CODE);
    var startRaw = sect[0];

    var endRaw = pe.dataBaseRaw();
    return pe.findMaskInternal(code, startRaw, endRaw);
}

function pe_findCodes(code)
{
    checkArgs("pe.findCodes", arguments, [["String"]]);

    var sect = pe.sectionRaw(CODE);
    var startRaw = sect[0];

    var endRaw = pe.dataBaseRaw();
    var offsets = [];
    var offset = pe.findMaskInternal(code, startRaw, endRaw);
    var sz = code.hexlength();
    while (offset !== -1)
    {
        offsets.push(offset);
        startRaw = offset + sz;
        offset = pe.findMaskInternal(code, startRaw, endRaw);
    }
    return offsets;
}

function pe_findAnyCode(codeObj)
{
    var foundObj;
    var found = -1;
    var foundOffset = -1;
    for (var i = 0; i < codeObj.length; i ++)
    {
        var obj = codeObj[i];
        var offset = pe.findCode(obj[0]);
        if (offset !== -1)
        {
            if (found !== -1)
            {
                fatalError("Found more than one patterns at indexes: " + found + " and " + i);
            }
            found = i;
            foundObj = obj;
            foundOffset = offset;
        }
    }
    if (found !== -1)
    {
        var vars = foundObj[1];
        var ret = Object();
        for (var v in vars)
        {
            ret[v] = vars[v];
        }
        ret.offset = foundOffset;
        ret.codeIndex = found;
        ret.code = foundObj[0];
        return ret;
    }
    return -1;
}

function pe_findAny(codeObj, start, finish)
{
    var foundObj;
    var found = -1;
    var foundOffset = -1;
    for (var i = 0; i < codeObj.length; i ++)
    {
        var obj = codeObj[i];
        var offset = pe.find(obj[0], start, finish);
        if (offset !== -1)
        {
            if (found !== -1)
            {
                fatalError("Found more than one patterns at indexes: " + found + " and " + i);
            }
            found = i;
            foundObj = obj;
            foundOffset = offset;
        }
    }
    if (found !== -1)
    {
        var vars = foundObj[1];
        var ret = Object();
        for (var v in vars)
        {
            ret[v] = vars[v];
        }
        ret.offset = foundOffset;
        ret.codeIndex = found;
        ret.code = foundObj[0];
        return ret;
    }
    return -1;
}

function pe_match(code, addrRaw)
{
    checkArgs("pe.match", arguments, [["String", "Number"]]);

    var offset = pe.findMaskInternal(code, addrRaw, addrRaw + 1);
    if (offset !== addrRaw)
    {
        return false;
    }
    return true;
}

function pe_matchAny(matchObj, addrRaw)
{
    var foundObj;
    var found = -1;
    for (var i = 0; i < matchObj.length; i ++)
    {
        var obj = matchObj[i];
        var res = pe.match(obj[0], addrRaw);
        if (res !== false)
        {
            if (found !== -1)
            {
                fatalError("Found more than one patterns at indexes: " + found + " and " + i);
            }
            found = i;
            foundObj = obj;
        }
    }
    if (found !== -1)
    {
        var vars = foundObj[1];
        var ret = Object();
        for (var v in vars)
        {
            ret[v] = vars[v];
        }
        ret.offset = addrRaw;
        ret.codeIndex = found;
        ret.code = foundObj[0];
        return ret;
    }
    return false;
}

function pe_matchVarAny(matchObj, varId)
{
    var addrRaw = table.getRawValidated(varId);
    return pe_matchAny(matchObj, addrRaw);
}

function pe_stringRaw(str)
{
    checkArgs("pe.stringRaw", arguments, [["String"]]);

    var code = ("\x00" + str + "\x00").toHex();
    var startRaw = pe.dataBaseRaw();
    var endRaw = 0x7fffffff;
    var res = pe.findMaskInternal(code, startRaw, endRaw);
    if (res === -1)
    {
        return -1;
    }
    return res + 1;
}

function pe_halfStringRaw(str)
{
    checkArgs("pe.halfStringRaw", arguments, [["String"]]);

    var code = (str + "\x00").toHex();
    var startRaw = pe.dataBaseRaw();
    var endRaw = 0x7fffffff;
    var res = pe.findMaskInternal(code, startRaw, endRaw);
    if (res === -1)
    {
        return -1;
    }
    return res;
}

function pe_stringVa(str)
{
    checkArgs("pe.stringVa", arguments, [["String"]]);

    var res = pe_stringRaw(str);
    if (res === -1)
    {
        return -1;
    }
    return pe.rawToVa(res);
}

function pe_halfStringVa(str)
{
    checkArgs("pe.halfStringVa", arguments, [["String"]]);

    var res = pe_halfStringRaw(str);
    if (res === -1)
    {
        return -1;
    }
    return pe.rawToVa(res);
}

function pe_stringAnyVa(strings)
{
    var args = Array.prototype.slice.call(arguments);
    for (var i = 0; i < args.length; i ++)
    {
        var res = pe_stringRaw(args[i]);
        if (res !== -1)
        {
            return pe.rawToVa(res);
        }
    }
    return -1;
}

function pe_stringAnyRaw(strings)
{
    var args = Array.prototype.slice.call(arguments);
    for (var i = 0; i < args.length; i ++)
    {
        var res = pe_stringRaw(args[i]);
        if (res !== -1)
        {
            return res;
        }
    }
    return -1;
}

function pe_stringInfoVa(strings)
{
    var args = Array.prototype.slice.call(arguments);
    for (var i = 0; i < args.length; i ++)
    {
        var res = pe_stringRaw(args[i]);
        if (res !== -1)
        {
            return [args[i], pe.rawToVa(res)];
        }
    }
    return -1;
}

function pe_stringInfoRaw(strings)
{
    var args = Array.prototype.slice.call(arguments);
    for (var i = 0; i < args.length; i ++)
    {
        var res = pe_stringRaw(args[i]);
        if (res !== -1)
        {
            return [args[i], res];
        }
    }
    return -1;
}

function pe_stringHex4(str)
{
    checkArgs("pe.stringHex4", arguments, [["String"]]);

    var addr = pe_stringVa(str);
    if (addr === -1)
    {
        throw "String " + str + " not found";
    }
    return addr.packToHex(4);
}

function pe_directReplace(addrRaw, code)
{
    return pe.directReplaceBytes(addrRaw, code.toAscii());
}

function pe_fetchUQWord(addrRaw)
{
    var value = pe.fetchQWord(addrRaw);
    if (value === false)
    {
        return false;
    }
    return value >>> 0;
}

function pe_fetchUDWord(addrRaw)
{
    var value = pe.fetchDWord(addrRaw);
    if (value === false)
    {
        return false;
    }
    return value >>> 0;
}

function pe_fetchUWord(addrRaw)
{
    var value = pe.fetchWord(addrRaw);
    if (value === false)
    {
        return false;
    }
    return value & 0xffff;
}

function pe_fetchUByte(addrRaw)
{
    var value = pe.fetchByte(addrRaw);
    if (value === false)
    {
        return false;
    }
    return value & 0xff;
}

function pe_fetchString(addrRaw)
{
    var endOffset = pe.find("00", addrRaw);
    if (endOffset == -1)
    {
        throw "String end not found";
    }
    return pe.fetch(addrRaw, endOffset - addrRaw);
}

function pe_getImportTable()
{
    if (typeof pe.importTable !== "undefined")
    {
        return pe.importTable;
    }

    var data = pe.getSubSection(1);
    pe.importTable = data;
    if (data === false)
    {
        throw "Cant get import table address";
    }
    return data;
}

function pe_getSubSection(index)
{
    var opt = pe.getOptHeader();
    if (opt.size <= 92)
    {
        throw "Pe opt header too small for sub sections";
    }

    var count = pe.fetchUDWord(opt.offset + 92);
    if (count <= index)
    {
        return false;
    }

    var offset = opt.offset + 96 + 8 * index;
    return {
        "offset": pe.rvaToRaw(pe.fetchUDWord(offset)),
        "size": pe.fetchUDWord(offset + 4),
    };
}

function pe_getImageBase()
{
    if (typeof pe.imageBase !== "undefined")
    {
        return pe.imageBase;
    }

    var opt = pe.getOptHeader();
    if (opt.size <= 28)
    {
        throw "Pe opt header too small for image base";
    }
    pe.imageBase = pe.fetchUDWord(opt.offset + 28);
    return pe.imageBase;
}

function pe_getPeHeader()
{
    if (typeof pe.peHeader !== "undefined")
    {
        return pe.peHeader;
    }

    var offset = pe.fetchUDWord(0x3c);
    if (pe.fetchUDWord(offset) !== 0x4550)
    {
        throw "Wrong PE header found";
    }
    pe.peHeader = offset;
    return offset;
}

function pe_getOptHeader()
{
    if (typeof pe.optHeader !== "undefined")
    {
        return pe.optHeader;
    }

    var offset = pe.getPeHeader() + 4 + 0x14;
    var size = pe.fetchUWord(offset - 4);
    pe.optHeader = {
        "offset": offset,
        "size": size,
    };
    return pe.optHeader;
}

function pe_rvaToVa(offsetRva)
{
    return offsetRva + pe.getImageBase();
}

function pe_rvaToRaw(offsetRva)
{
    return pe.vaToRaw(offsetRva + pe.getImageBase());
}

function pe_fetchValue(offset, offset2)
{
    var size = offset2[1];
    var addr = offset + offset2[0];
    if (size == 1)
    {
        return pe.fetchByte(addr);
    }
    else if (size == 2)
    {
        return pe.fetchWord(addr);
    }
    else if (size == 4)
    {
        return pe.fetchDWord(addr);
    }
    else if (size == 8)
    {
        return pe.fetchQWord(addr);
    }

    fatalError("Unknown size in pe.fetchValue: " + size);
    return false;
}

function pe_fetchValueSimple(offset)
{
    return pe_fetchValue(0, offset);
}

function pe_fetchRelativeValue(offset, offset2)
{
    var value = pe_fetchValue(offset, offset2);
    var addr = pe.rawToVa(offset + offset2[0]) + offset2[1] + value;
    return addr;
}

function pe_fetchHexBytes(offset, offset2)
{
    var size = offset2[1];
    var addr = offset + offset2[0];
    return pe.fetchHex(addr, size);
}

function pe_replace(addrRaw, data)
{
    checkArgs("pe.replace", arguments, [["Number", "String"]]);
    return pe.replaceHex(addrRaw, data.toHex());
}

function pe_resizeHexCode(code, codeLen)
{
    if (typeof codeLen !== "undefined")
    {
        var sz = code.hexlength();
        if (sz > codeLen)
        {
            fatalError("Existing code bigger than requested");
        }
        for (var i = 0; i < codeLen - sz; i ++)
        {
            code += " 90";
        }
    }
    return code;
}

function pe_replaceAsmText(patchAddr, commands, vars, codeLen)
{
    var code = asm.textToHexRaw(patchAddr, commands, vars);
    code = pe.resizeHexCode(code, codeLen);
    pe.replaceHex(patchAddr, code);
    return code;
}

function pe_replaceAsmFile(patchAddr, fileName, vars, codeLen)
{
    if (typeof vars === "undefined")
    {
        vars = {};
    }
    var commands = asm.load(fileName);
    return pe_replaceAsmText(patchAddr, commands, vars, codeLen);
}

function pe_setValue(offset, offset2, value)
{
    var size = offset2[1];
    var addr = offset + offset2[0];
    pe.replaceHex(addr, value.packToHex(size));
}

function pe_setValueSimple(offset, value)
{
    pe_setValue(0, offset, value);
}

function pe_setJmpVa(patchAddr, jmpAddrVa, cmd, codeLen)
{
    if (typeof cmd === "undefined")
    {
        cmd = "jmp";
    }
    var vars = {
        "offset": jmpAddrVa,
    };
    var code = asm.textToHexRaw(patchAddr, cmd + " offset", vars);
    code = pe.resizeHexCode(code, codeLen);
    if (patch.getState() === 2)
    {
        pe.directReplace(patchAddr, code);
    }
    else
    {
        pe.replaceHex(patchAddr, code);
    }
}

function pe_setJmpRaw(patchAddr, jmpAddrRaw, cmd, codeLen)
{
    pe_setJmpVa(patchAddr, pe.rawToVa(jmpAddrRaw), cmd, codeLen);
}

function pe_setNops(patchAddr, nopsCount)
{
    var code = "";
    for (var i = 0; i < nopsCount; i ++)
    {
        code += "90 ";
    }
    pe.replaceHex(patchAddr, code);
}

function pe_setNopsRange(patchStartAddr, patchEndAddr)
{
    pe_setNops(patchStartAddr, patchEndAddr - patchStartAddr);
}

function pe_setNopsValueRange(offset, nopsValue)
{
    pe_setNops(offset + nopsValue[0], nopsValue[1]);
}

function pe_setShortJmpVa(patchAddr, jmpAddrVa, cmd)
{
    if (typeof cmd === "undefined")
    {
        cmd = "jmp";
    }
    var vars = {
        "offset": jmpAddrVa,
    };
    var code = asm.textToHexRaw(patchAddr, cmd + " offset", vars);
    if (code.hexlength() !== 2)
    {
        fatalError(cmd + " is not short");
    }

    pe.replaceHex(patchAddr, code);
}

function pe_setShortJmpRaw(patchAddr, jmpAddrRaw, cmd)
{
    pe_setShortJmpVa(patchAddr, pe.rawToVa(jmpAddrRaw), cmd);
}

function pe_insertHexAt(insertAddr, size, code)
{
    checkArgs("pe.insertHexAt", arguments, [["Number", "Number", "String"]]);
    var res = pe.replaceHex(insertAddr, code);
    if (res === false)
    {
        return false;
    }
    if (size < code.hexlength())
    {
        fatalError("pe.insertHexAt: size smaller than code real size");
    }
    return alloc.reserve(insertAddr, size);
}

function pe_insertAt(insertAddr, size, code)
{
    checkArgs("pe.insertAt", arguments, [["Number", "Number", "String"]]);
    var res = pe.replace(insertAddr, code);
    if (res === false)
    {
        return false;
    }
    if (size < code.length)
    {
        fatalError("pe.insertAt: size smaller than code real size");
    }
    return alloc.reserve(insertAddr, size);
}

function pe_insertAsmText(commands, vars, freeSpace)
{
    if (typeof freeSpace === "undefined")
    {
        freeSpace = 0;
    }
    var size = asm.textToHexLength(commands, vars) + freeSpace;
    var free = alloc.find(size);
    if (free === -1)
    {
        fatalError("Failed in pe.insertAsmText - Not enough free space");
    }

    var obj = asm.textToObjRaw(free, commands, vars);
    pe.insertHexAt(free, size, obj.code);

    return [free, obj.code, obj.vars];
}

function pe_insertAsmTextObj(commands, vars, freeSpace, dryRun)
{
    if (typeof freeSpace === "undefined")
    {
        freeSpace = 0;
    }
    if (typeof dryRun === "undefined")
    {
        dryRun = false;
    }
    var size = asm.textToHexLength(commands, vars) + freeSpace;
    var free;
    if (patch.getState() === 2)
    {
        if (storage.getZero() == 0)
        {
            fatalError("Failed in pe.insertAsmTextObj - Not enough free space");
        }
        free = storage.getZero();
    }
    else
    {
        free = alloc.find(size);
        if (free === -1)
        {
            fatalError("Failed in pe.insertAsmTextObj - Not enough free space");
        }
    }

    var obj = asm.textToObjRaw(free, commands, vars);

    if (dryRun !== true)
    {
        if (patch.getState() === 2)
        {
            pe.directReplace(free, obj.code);
            storage.adjustZero(size);
        }
        else
        {
            pe.insertHexAt(free, size, obj.code);
        }
    }
    obj.free = free;
    obj.isFinal = false;
    return obj;
}

function pe_insertAsmFile(fileName, vars, freeSpace, dryRun)
{
    var commands = asm.load(fileName);
    return pe_insertAsmTextObj(commands, vars, freeSpace, dryRun);
}

function pe_insertDWord(value, dryRun)
{
    if (typeof dryRun === "undefined")
    {
        dryRun = false;
    }

    var size = 4;
    var free;
    if (patch.getState() === 2)
    {
        if (storage.getZero() == 0)
        {
            fatalError("Failed in pe.insertDWord - Not enough free space");
        }
        free = storage.getZero();
    }
    else
    {
        free = alloc.find(size);
        if (free === -1)
        {
            fatalError("Failed in pe.insertDWord - Not enough free space");
        }
    }
    var obj = asm.textToObjRaw(free, "long " + value, {});
    if (dryRun !== true)
    {
        if (patch.getState() === 2)
        {
            pe.directReplace(free, obj.code);
            storage.adjustZero(size);
        }
        else
        {
            alloc.reserve(free, size);
            pe.replaceHex(free, obj.code);
        }
    }
    return free;
}

function pe_insertHex(value)
{
    var size = value.hexlength();
    var free = alloc.find(size);
    if (free === -1)
    {
        fatalError("Failed in pe.insertHex - cant find");
    }

    var res = alloc.reserve(free, size);
    if (res === false)
    {
        fatalError("Failed in pe.insertHex - cant reserve");
    }
    res = pe.replaceHex(free, value);
    if (res === false)
    {
        fatalError("Failed in pe.insertHex - cant replace");
    }

    return free;
}

function pe_insert(value)
{
    return pe.insertHex(value.toHex());
}

function pe_insertString(value)
{
    return pe.insertHex((value + "\x00").toHex());
}

function registerPe()
{
    pe.importTable = undefined;
    pe.imageBase = undefined;
    pe.peHeader = undefined;
    pe.optHeader = undefined;

    pe.find = pe_find;
    pe.findAll = pe_findAll;
    pe.findCode = pe_findCode;
    pe.findCodes = pe_findCodes;
    pe.findAnyCode = pe_findAnyCode;
    pe.findAny = pe_findAny;
    pe.match = pe_match;
    pe.matchAny = pe_matchAny;
    pe.matchVarAny = pe_matchVarAny;
    pe.stringVa = pe_stringVa;
    pe.stringRaw = pe_stringRaw;
    pe.halfStringVa = pe_halfStringVa;
    pe.halfStringRaw = pe_halfStringRaw;
    pe.stringHex4 = pe_stringHex4;
    pe.stringAnyVa = pe_stringAnyVa;
    pe.stringAnyRaw = pe_stringAnyRaw;
    pe.stringInfoVa = pe_stringInfoVa;
    pe.stringInfoRaw = pe_stringInfoRaw;
    pe.directReplace = pe_directReplace;
    pe.fetchUQWord = pe_fetchUQWord;
    pe.fetchUDWord = pe_fetchUDWord;
    pe.fetchUWord = pe_fetchUWord;
    pe.fetchUByte = pe_fetchUByte;
    pe.fetchString = pe_fetchString;
    pe.getPeHeader = pe_getPeHeader;
    pe.getOptHeader = pe_getOptHeader;
    pe.getSubSection = pe_getSubSection;
    pe.getImageBase = pe_getImageBase;
    pe.getImportTable = pe_getImportTable;
    pe.rvaToVa = pe_rvaToVa;
    pe.rvaToRaw = pe_rvaToRaw;
    pe.fetchValue = pe_fetchValue;
    pe.fetchValueSimple = pe_fetchValueSimple;
    pe.fetchRelativeValue = pe_fetchRelativeValue;
    pe.fetchHexBytes = pe_fetchHexBytes;
    pe.replace = pe_replace;
    pe.replaceAsmText = pe_replaceAsmText;
    pe.replaceAsmFile = pe_replaceAsmFile;
    pe.setValue = pe_setValue;
    pe.setValueSimple = pe_setValueSimple;
    pe.setJmpVa = pe_setJmpVa;
    pe.setJmpRaw = pe_setJmpRaw;
    pe.setNops = pe_setNops;
    pe.setNopsRange = pe_setNopsRange;
    pe.setNopsValueRange = pe_setNopsValueRange;
    pe.setShortJmpVa = pe_setShortJmpVa;
    pe.setShortJmpRaw = pe_setShortJmpRaw;
    pe.insertAt = pe_insertAt;
    pe.insertHexAt = pe_insertHexAt;
    pe.insertAsmText = pe_insertAsmText;
    pe.insertAsmTextObj = pe_insertAsmTextObj;
    pe.insertAsmFile = pe_insertAsmFile;
    pe.insertDWord = pe_insertDWord;
    pe.insertHex = pe_insertHex;
    pe.insert = pe_insert;
    pe.insertString = pe_insertString;
    pe.resizeHexCode = pe_resizeHexCode;
}
