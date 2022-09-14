//
// Copyright (C) 2018-2022  Andrei Karas (4144)
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

function hooks_initHook(offset, matchFunc, searchAddrFunc)
{
    consoleLog("hooks.initHook start");
    var storageKey = offset;
    var data = offset;
    if (typeof(searchAddrFunc) !== "undefined")
    {
        var arr = searchAddrFunc(offset);
        if (arr.length !== 1)
            throw "Found wrong number of objects in hooks.initHook for offset: 0x" + offset.toString(16) + ": " + arr.length;
        storageKey = arr[0][0];
        data = arr[0][1];
    }
    return hooks_initHookInternal(offset, matchFunc, storageKey, data);
}

function hooks_addFunctionsHooks(objs)
{
    function addHooks(objs, isPost, funcEntries, text, vars, weight)
    {
        if (objs.addMulti === false)
        {
            objs.forEach(function(obj)
            {
                if (obj.endHook !== true)
                    fatalError("Cant use non addMulti functions on non end hook");
                if (obj.isDuplicate === false)
                    obj.addEntry(text, vars, isPost, funcEntries(obj), weight);
            });
        }
        else
        {
            objs.forEach(function(obj)
            {
                obj.addEntry(text, vars, isPost, funcEntries(obj), weight);
            });
        }
    }

    function getPre(obj)
    {
        return obj.preEntries;
    }
    function getPost(obj)
    {
        return obj.postEntries;
    }

    objs.addPre = function(text, vars, weight)
    {
        addHooks(objs, false, getPre, text, vars, weight);
    }
    objs.addPost = function(text, vars, weight)
    {
        addHooks(objs, true, getPost, text, vars, weight);
    }
    objs.addFilePre = function(fileName, vars, weight)
    {
        var text = asm.load(fileName);
        addHooks(objs, false, getPre, text, vars, weight);
    }
    objs.addFilePost = function(fileName, vars, weight)
    {
        var text = asm.load(fileName);
        addHooks(objs, true, getPost, text, vars, weight);
    }
    objs.validate = function()
    {
        this.forEach(function(obj)
        {
            consoleLog("hooks objs.validate");
            hooks_applyFinal(obj, true);
        })
    }
}

function hooks_addFunctionsHooks2(objs)
{
}

function hooks_setHooksMultiFlag(i, obj, addMulti, srcObj)
{
    obj.addMulti = addMulti;
    if (i > 0 && addMulti === false)
    {
        obj.isDuplicate = true;
        obj.copyFrom = srcObj;
    }
    return true;
}

function hooks_setHooksMultiFlagByKey(i, objKey, addMulti, srcObjKey)
{
    var obj = storage.hooks[objKey];
    var srcObj = storage.hooks[srcObjKey];
    hooks_setHooksMultiFlag(i, obj, addMulti, srcObj);
}

function hooks_initHooks(offset, matchFunc, searchAddrFunc, addMulti)
{
    consoleLog("hooks.initHooks start");
    if (typeof(addMulti) === "undefined")
        addMulti = false;

    var objs = [];
    if (typeof(searchAddrFunc) !== "undefined")
    {
        var arr = searchAddrFunc(offset);
        for (var i = 0; i < arr.length; i ++)
        {
            var storageKey = arr[i][0];
            var data = arr[i][1];
            consoleLog("hooks.initHooks: Add new hook by search: " + storageKey);
            objs.push(hooks_initHookInternal(offset, matchFunc, storageKey, data));
            hooks_setHooksMultiFlag(i, objs[i], addMulti, objs[0]);
        }
    }
    else
    {
        var storageKey = offset;
        var data = offset;
        consoleLog("hooks.initHooks: Add new hook: " + storageKey);
        objs.push(hooks_initHookInternal(offset, matchFunc, storageKey, data));
        hooks_setHooksMultiFlag(0, objs[0], addMulti, objs[0]);
    }
    objs.addMulti = addMulti;

    hooks.addFunctionsHooks(objs);
    hooks.addFunctionsHooks2(objs);

    return objs;
}

function hooks_checkMatchedObject(funcName, storageKey)
{
    if (storageKey in storage.hooks)
    {
        var obj = storage.hooks[storageKey];
        if (obj.matchFunc.name !== funcName)
            fatalError("Other type of hook registered for address: 0x" + pe.rawToVa(storageAddr).toString(16));
        return true;
    }
    return false;
}

function hooks_getMatchedObject(matchFunc, storageKey, data)
{
    consoleLog("hooks.getMatchedObject");
    if (hooks.checkMatchedObject(matchFunc.name, storageKey) !== true)
    {
        consoleLog("hooks.getMatchedObject match new hook");
        var obj = matchFunc(storageKey, data);
        return [false, obj];
    }
    else
    {
        consoleLog("hooks.getMatchedObject found existing hook");
        var obj = storage.hooks[storageKey];
        return [true, obj];
    }
}

function hooks_validateMatchedObject(obj)
{
    if (typeof(obj.patchAddr) == "undefined" || obj.patchAddr === 0)
        fatalError("Not set patchAddr in hook");
    if (obj.endHook !== true)
        fatalError("Not supported endHook value: " + obj.endHook);
}

function hooks_createEntry(text, vars)
{
    var obj = new Object();
    obj.text = text;
    obj.vars = vars;
    obj.patch = patch.getName();
    return obj;
}

function hooks_addFunctions(obj)
{
    consoleLog("hooks_addFunctions");

    obj.addEntry = function(text, vars, isPost, entries, weight)
    {
        consoleLog("hooks: obj.addEntry: " + isPost);
        if (typeof(vars) === "undefined")
            vars = {};
        var asmObj = hooks.insertAsm(text, vars, 5);
        if (typeof(weight) === "undefined")
            asmObj.weight = 10000;
        else
            asmObj.weight = weight;
        entries.pushSorted(asmObj);
        storage.multiHooks[asmObj.patch] = true;
    }
    obj.addPre = function(text, vars, weight)
    {
        consoleLog("obj.addPre: " + this.preEntries.length);
        this.addEntry(text, vars, false, this.preEntries, weight);
    }
    obj.addPost = function(text, vars, weight)
    {
        this.addEntry(text, vars, true, this.postEntries, weight);
    }
    obj.addFilePre = function(fileName, vars, weight)
    {
        var text = asm.load(fileName);
        consoleLog("obj.addFilePre: " + this.preEntries.length);
        this.addEntry(text, vars, false, this.preEntries, weight);
    }
    obj.addFilePost = function(fileName, vars, weight)
    {
        var text = asm.load(fileName);
        this.addEntry(text, vars, true, this.postEntries, weight);
    }
    obj.addFinal = function(text, vars)
    {
        consoleLog("hook object AddFinal isFinal");
        if (typeof(vars) === "undefined")
            vars = {};
        obj.finalEntry = hooks.createEntry(text, vars);
        obj.finalEntry.isFinal = true;
    }
    obj.applyFinal = function()
    {
        hooks_applyFinal(this);
    }
    obj.validate = function()
    {
        hooks_applyFinal(this, true);
    }
}

function hooks_initMatchedObject(matchFunc, obj)
{
    obj.matchFunc = matchFunc.name;
    obj.preEntries = [];
    obj.postEntries = [];
    if (obj.stolenCode1 != "")
    {
        obj.stolenEntry = hooks.createEntry(asm.hexToAsm(obj.stolenCode1), {});
    }
    else
    {
        obj.stolenEntry = "";
    }
    if (obj.retCode != "")
    {
        consoleLog("Ret code convert to final: isFinal");
        obj.finalEntry = hooks.createEntry(asm.hexToAsm(obj.retCode), {});
        obj.finalEntry.isFinal = true;
    }
    else
    {
        obj.finalEntry = false;
    }
}

function hooks_saveMatchedObject(storageKey, obj)
{
    storage.hooks[storageKey] = obj;
    obj.storageKey = storageKey;
}

function hooks_initHookInternal(offset, matchFunc, storageKey, data)
{
    consoleLog("hooks.initHookInternal start");
    var matched = hooks.getMatchedObject(matchFunc, storageKey, data);
    var obj = matched[1];
    if (matched[0] === true)
        return obj;

    hooks.validateMatchedObject(obj);
    hooks.initMatchedObject(matchFunc, obj);
    hooks.addFunctions(obj);
    hooks.saveMatchedObject(storageKey, obj);

    return obj;
}

function hooks_applyFinal(obj, dryRun)
{
    if (obj.endHook !== true)
        fatalError("Not supported endHook value: " + obj.endHook);

    if (typeof(dryRun) === "undefined")
        dryRun = false;

    consoleLog("hooks.applyFinal start: " + dryRun);

    if (obj.isDuplicate === false)
        var srcObj = obj;
    else
        var srcObj = obj.copyFrom;

    consoleLog("hooks_applyFinal pre: " + srcObj.preEntries.length);
    var szPre = srcObj.preEntries.length;
    var szPost = srcObj.postEntries.length;
    if (obj.alwaysHook !== true && szPre + szPost === 0)
    {
        consoleLog("hooks_applyFinal nothing to hook");
        return true;
    }

    function entryToAsm(obj)
    {
        if (typeof(obj.code) === "undefined")
            return hooks.insertAsm(obj.text, obj.vars, 5, dryRun);
        else
            return obj;
    }

    function convertArray(entries)
    {
        var sz = entries.length;
        for (var i = 0; i < sz; i ++)
        {
            obj.allEntries.push(entryToAsm(entries[i]));
        }
    }

    obj.allEntries = [];

    if (obj.isDuplicate === false)
    {
        consoleLog("hooks.applyFinal add pre entries: " + obj.allEntries.length);
        convertArray(obj.preEntries);

        consoleLog("hooks.applyFinal add stolen entry: " + obj.allEntries.length);
        if (obj.stolenEntry != "")
            obj.allEntries.push(entryToAsm(obj.stolenEntry));

        consoleLog("hooks.applyFinal add post entries: " + obj.allEntries.length);
        convertArray(obj.postEntries);

        consoleLog("hooks.applyFinal add final entry: " + obj.allEntries.length);
        if (obj.finalEntry !== false)
        {
            var entry = entryToAsm(obj.finalEntry);
            entry.isFinal = obj.finalEntry.isFinal;
            obj.allEntries.push(entry);
        }
    }

    var sz = srcObj.allEntries.length;
    if (sz == 0)
        fatalError("No entried in hook object");

    consoleLog("hooks.applyFinal initial jmp: " + dryRun + ", " + srcObj.allEntries.length);

    if (dryRun !== true)
    {
        if (obj.isDuplicate === false)
        {
            switch (obj.firstJmpType)
            {
                case hooks.jmpTypes.JMP:
                    pe.setJmpRaw(obj.patchAddr, obj.allEntries[0].free);
                    break;
                case hooks.jmpTypes.IMPORT:
                    var freeVa = pe.rawToVa(obj.allEntries[0].free);
                    var importOffset = pe.insertDWord(freeVa);
                    obj.importOffsetPatchedVa = pe.rawToVa(importOffset);
                    pe.directReplaceDWord(obj.patchAddr, obj.importOffsetPatchedVa);
                    break;
                default:
                    fatalError("Unknown jmp type: " + obj.firstJmpType);
            };
        }
        else
        {
            switch (obj.firstJmpType)
            {
                case hooks.jmpTypes.JMP:
                    pe.setJmpRaw(obj.patchAddr, srcObj.allEntries[0].free);
                    break;
                case hooks.jmpTypes.IMPORT:
                    if (typeof(srcObj.importOffsetPatchedVa) === "undefined")
                    {
                        var freeVa = pe.rawToVa(srcObj.allEntries[0].free);
                        var importOffset = pe.insertDWord(freeVa);
                        srcObj.importOffsetPatchedVa = pe.rawToVa(importOffset);
                    }
                    pe.directReplaceDWord(obj.patchAddr, srcObj.importOffsetPatchedVa);
                    break;
                default:
                    fatalError("Unknown jmp type: " + obj.firstJmpType);
            };
        }
    }

    if (obj.isDuplicate)
        return true;

    consoleLog("hooks.applyFinal loop jumps: " + dryRun + ", " + sz);
    for (var i = 0; i < sz - 1; i ++)
    {
        consoleLog("hooks.applyFinal loop entry: " + dryRun + ", " + i);
        var entry = obj.allEntries[i];
        var nextEntry = obj.allEntries[i + 1];
        if (entry.isFinal === true)
            continue;
        if (dryRun !== true)
            pe.setJmpRaw(entry.free + entry.bytesLength, nextEntry.free);
    }
    var lastEntry = obj.allEntries[sz - 1];
    if (lastEntry.isFinal === false)
    {
        fatalError("Not supported non final last entry");
    }
    return true;
}

function hooks_applyAllFinal()
{
    storage.setZero(alloc.find(0x1000));
/*
    // alternative mapping
    storage.setZero(pe.sectionRaw(DIFF)[1] - 1024);
    if (storage.getZero() === -1)
        throw "No free space found";
*/

    for (var patchAddr in storage.hooks)
    {
        hooks_applyFinal(storage.hooks[patchAddr]);
    }
}

function hooks_removePatchHooks()
{
    consoleLog("hooks.removePatchHooks start");
    var name = patch.getName();

    if (!(name in storage.multiHooks))
        return;

    function filterArray(obj)
    {
        return obj.patch != name;
    }

    consoleLog("hooks.removePatchHooks filter patches");

    for (var patchAddr in storage.hooks)
    {
        var obj = storage.hooks[patchAddr];
        obj.preEntries = obj.preEntries.filter(filterArray);
        obj.postEntries = obj.postEntries.filter(filterArray);
    }
    consoleLog("hooks.removePatchHooks end");
}

function hooks_duplicateStackCode(offset, stackSize, stolenCode)
{
    checkArgs("hooks.duplicateStackCode", arguments, [["Number", "Number", "String"]]);
    var count = parseInt(stackSize / 4);
    if (count * 4 !== stackSize)
        fatalError("Wrong stack size: " + stackSize);
    var text = asm.load("stack_duplicate_pre");
    var push = asm.load("stack_duplicate_push");
    var pushes = "";
    for (var i = 0; i < count; i ++)
    {
        pushes = asm_combine(pushes, push);
    }
    var vars = {
        "func": offset,
        "pushes": pushes,
        "pushOffset": stackSize + 4,
        "retOffset": stackSize + 4,
        "stolenCode": stolenCode,
    }
    return asm_textToHexVa(0, text, vars);
}

function hooks_insertAsm(commands, vars, freeSpace, dryRun)
{
    var asmObj = pe.insertAsmTextObj(commands, vars, freeSpace, dryRun)
    delete asmObj.vars
    asmObj.patch = patch.getName();
    asmObj.bytesLength = asmObj.bytes.length;
    delete asmObj.bytes;
    asmObj.code = "";
    return asmObj;
}

function hooks_addEntryByKey(storageKey, asmObj, isPost)
{
    consoleLog("hooks.addEntryByKey: " + storageKey);
    if (!(storageKey in storage.hooks))
        fatalError("hooks.addEntryByKey: storage key not found");
    var obj = storage.hooks[storageKey];
    var entries;
    if (isPost === true)
    {
        consoleLog("hooks_addEntryByKey post: " + obj.preEntries.length);
        entries = obj.postEntries;
    }
    else
    {
        consoleLog("hooks_addEntryByKey pre: " + obj.preEntries.length);
        entries = obj.preEntries;
    }
    entries.pushSorted(asmObj);
    storage.multiHooks[asmObj.patch] = true;
    return true;
}

function hooks_addFinalEntryByKey(storageKey, text, vars)
{
    consoleLog("hooks.addFinalEntryByKey");
    var obj = storage.hooks[storageKey];
    obj.addFinal(text, vars);
}

function hooks_createHookObj()
{
    var obj = new Object();
    obj.patchAddr = 0;
    obj.free = 0;
    obj.text = "";
    obj.vars = {};
    obj.continueOffsetVa = 0;
    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";
    // obj.endHook = true;
    obj.firstJmpType = hooks.jmpTypes.JMP;
    obj.isDuplicate = false;
    return obj;
}

function registerHooks()
{
    hooks = new Object();
    hooks.jmpTypes = {
        JMP : 0,
        IMPORT : 1
    };

    hooks.matchFunctionStart = hooks_matchFunctionStart;
    hooks.matchFunctionTableStart = hooks_matchFunctionTableStart;
    hooks.matchFunctionEnd = hooks_matchFunctionEnd;
    hooks.matchImportUsage = hooks_matchImportUsage;
    hooks.matchImportCallUsage = hooks_matchImportCallUsage;
    hooks.matchImportJmpUsage = hooks_matchImportJmpUsage;
    hooks.matchImportMovUsage = hooks_matchImportMovUsage;
    hooks.matchFunctionReplace = hooks_matchFunctionReplace;
    hooks.searchImportUsage = hooks_searchImportUsage;
    hooks.searchImportCallUsage = hooks_searchImportCallUsage;
    hooks.searchImportJmpUsage = hooks_searchImportJmpUsage;
    hooks.searchImportMovUsage = hooks_searchImportMovUsage;
    hooks.createHookObj = hooks_createHookObj;
    hooks.initHook = hooks_initHook;
    hooks.initHooks = hooks_initHooks;
    hooks.initHookInternal = hooks_initHookInternal;
    hooks.initEndHook = hooks_initEndHook;
    hooks.initTableStartHook = hooks_initTableStartHook;
    hooks.initTableEndHook = hooks_initTableEndHook;
    hooks.initImportHooks = hooks_initImportHooks;
    hooks.initImportCallHooks = hooks_initImportCallHooks;
    hooks.initImportJmpHooks = hooks_initImportJmpHooks;
    hooks.initImportMovHooks = hooks_initImportMovHooks;
    hooks.initTableReplaceHook = hooks_initTableReplaceHook;
    hooks.applyFinal = hooks_applyFinal;
    hooks.applyAllFinal = hooks_applyAllFinal;
    hooks.removePatchHooks = hooks_removePatchHooks;
    hooks.duplicateStackCode = hooks_duplicateStackCode;
    hooks.insertAsm = hooks_insertAsm;
    hooks.getMatchedObject = hooks_getMatchedObject;
    hooks.validateMatchedObject = hooks_validateMatchedObject;
    hooks.createEntry = hooks_createEntry;
    hooks.addFunctions = hooks_addFunctions;
    hooks.initMatchedObject = hooks_initMatchedObject;
    hooks.checkMatchedObject = hooks_checkMatchedObject;
    hooks.saveMatchedObject = hooks_saveMatchedObject;
    hooks.setHooksMultiFlag = hooks_setHooksMultiFlag;
    hooks.setHooksMultiFlagByKey = hooks_setHooksMultiFlagByKey;
    hooks.addEntryByKey = hooks_addEntryByKey;
    hooks.addFinalEntryByKey = hooks_addFinalEntryByKey;
    hooks.addFunctionsHooks = hooks_addFunctionsHooks;
    hooks.addFunctionsHooks2 = hooks_addFunctionsHooks2;
}
