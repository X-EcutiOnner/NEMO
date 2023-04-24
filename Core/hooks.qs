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

function hooks_initHookInternal(offset, matchFunc, storageKey, data)
{
    var matched = hooks.getMatchedObject(matchFunc, storageKey, data);
    var obj = matched[1];
    if (matched[0] === true)
    {
        return obj;
    }

    hooks.validateMatchedObject(obj);
    hooks.initMatchedObject(matchFunc, obj);
    hooks.addFunctions(obj);
    hooks.saveMatchedObject(storageKey, obj);

    return obj;
}

function hooks_initHook(offset, matchFunc, searchAddrFunc, searchAddrArgs)
{
    var storageKey = offset;
    var data = offset;
    if (typeof searchAddrFunc !== "undefined")
    {
        var arr = searchAddrFunc(offset, searchAddrArgs);
        if (arr.length !== 1)
        {
            throw "Found wrong number of objects in hooks.initHook for offset: 0x" + offset.toString(16) + ": " + arr.length;
        }
        storageKey = arr[0][0];
        data = arr[0][1];
    }
    return hooks_initHookInternal(offset, matchFunc, storageKey, data);
}

function hooks_applyFinal(obj, dryRun)
{
    if (obj.endHook !== true)
    {
        fatalError("Not supported endHook value: " + obj.endHook);
    }

    if (typeof dryRun === "undefined")
    {
        dryRun = false;
    }

    var srcObj;
    if (obj.isDuplicate === false)
    {
        srcObj = obj;
    }
    else
    {
        srcObj = obj.copyFrom;
    }

    var szPre = srcObj.preEntries.length;
    var szPost = srcObj.postEntries.length;
    if (obj.alwaysHook !== true && szPre + szPost === 0)
    {
        return true;
    }

    function entryToAsm(objAsm)
    {
        if (typeof objAsm.code === "undefined")
        {
            return hooks.insertAsm(objAsm.text, objAsm.vars, 5, dryRun);
        }

        return objAsm;
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
    var entry;

    if (obj.isDuplicate === false)
    {
        convertArray(obj.preEntries);

        if (obj.stolenEntry != "")
        {
            obj.allEntries.push(entryToAsm(obj.stolenEntry));
        }

        convertArray(obj.postEntries);

        if (obj.finalEntry !== false)
        {
            entry = entryToAsm(obj.finalEntry);
            entry.isFinal = obj.finalEntry.isFinal;
            obj.allEntries.push(entry);
        }
    }

    var sz = srcObj.allEntries.length;
    if (sz == 0)
    {
        fatalError("No entried in hook object");
    }

    if (dryRun !== true)
    {
        var freeVa;
        var importOffset;
        if (obj.isDuplicate === false)
        {
            switch (obj.firstJmpType)
            {
                case hooks.jmpTypes.JMP:
                    pe.setJmpRaw(obj.patchAddr, obj.allEntries[0].free);
                    break;
                case hooks.jmpTypes.CALL:
                    pe.setJmpRaw(obj.patchAddr, obj.allEntries[0].free, "call", 5);
                    break;
                case hooks.jmpTypes.IMPORT:
                    freeVa = pe.rawToVa(obj.allEntries[0].free);
                    importOffset = pe.insertDWord(freeVa);
                    obj.importOffsetPatchedVa = pe.rawToVa(importOffset);
                    pe.directReplaceDWord(obj.patchAddr, obj.importOffsetPatchedVa);
                    break;
                default:
                    fatalError("Unknown jmp type: " + obj.firstJmpType);
            }
        }
        else
        {
            switch (obj.firstJmpType)
            {
                case hooks.jmpTypes.JMP:
                    pe.setJmpRaw(obj.patchAddr, srcObj.allEntries[0].free);
                    break;
                case hooks.jmpTypes.CALL:
                    pe.setJmpRaw(obj.patchAddr, srcObj.allEntries[0].free, "call", 5);
                    break;
                case hooks.jmpTypes.IMPORT:
                    if (typeof srcObj.importOffsetPatchedVa === "undefined")
                    {
                        freeVa = pe.rawToVa(srcObj.allEntries[0].free);
                        importOffset = pe.insertDWord(freeVa);
                        srcObj.importOffsetPatchedVa = pe.rawToVa(importOffset);
                    }
                    pe.directReplaceDWord(obj.patchAddr, srcObj.importOffsetPatchedVa);
                    break;
                default:
                    fatalError("Unknown jmp type: " + obj.firstJmpType);
            }
        }
    }

    if (obj.isDuplicate)
    {
        return true;
    }

    for (var i = 0; i < sz - 1; i ++)
    {
        entry = obj.allEntries[i];
        var nextEntry = obj.allEntries[i + 1];
        if (entry.isFinal === true)
        {
            continue;
        }
        if (dryRun !== true)
        {
            pe.setJmpRaw(entry.free + entry.bytesLength, nextEntry.free);
        }
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

    for (var patchAddr in storage.hooks)
    {
        hooks_applyFinal(storage.hooks[patchAddr]);
    }
}

function hooks_addFunctionsHooks(objs)
{
    function addHooks(objs2, isPost, funcEntries, text, vars, weight)
    {
        if (objs2.addMulti === false)
        {
            objs2.forEach(function func(obj)
            {
                if (obj.endHook !== true)
                {
                    fatalError("Cant use non addMulti functions on non end hook");
                }
                if (obj.isDuplicate === false)
                {
                    obj.addEntry(text, vars, isPost, funcEntries(obj), weight);
                }
            });
        }
        else
        {
            objs2.forEach(function func(obj)
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

    objs.addPre = function addPre(text, vars, weight)
    {
        addHooks(objs, false, getPre, text, vars, weight);
    };
    objs.addPost = function addPost(text, vars, weight)
    {
        addHooks(objs, true, getPost, text, vars, weight);
    };
    objs.addFilePre = function addFilePre(fileName, vars, weight)
    {
        var text = asm.load(fileName);
        addHooks(objs, false, getPre, text, vars, weight);
    };
    objs.addFilePost = function addFilePost(fileName, vars, weight)
    {
        var text = asm.load(fileName);
        addHooks(objs, true, getPost, text, vars, weight);
    };
    objs.validate = function validate()
    {
        this.forEach(function func(obj)
        {
            hooks_applyFinal(obj, true);
        });
    };
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
    if (typeof addMulti === "undefined")
    {
        addMulti = false;
    }

    var objs = [];
    var storageKey;
    var data;
    if (typeof searchAddrFunc === "undefined")
    {
        storageKey = offset;
        data = offset;
        objs.push(hooks_initHookInternal(offset, matchFunc, storageKey, data));
        hooks_setHooksMultiFlag(0, objs[0], addMulti, objs[0]);
    }
    else
    {
        var arr = searchAddrFunc(offset);
        for (var i = 0; i < arr.length; i ++)
        {
            storageKey = arr[i][0];
            data = arr[i][1];
            objs.push(hooks_initHookInternal(offset, matchFunc, storageKey, data));
            hooks_setHooksMultiFlag(i, objs[i], addMulti, objs[0]);
        }
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
        if (obj.matchFunc !== funcName)
        {
            fatalError("Other type of hook registered for address: 0x" + pe.rawToVa(storageKey).toString(16));
        }
        return true;
    }
    return false;
}

function hooks_getMatchedObject(matchFunc, storageKey, data)
{
    if (hooks.checkMatchedObject(matchFunc.name, storageKey) === true)
    {
        return [true, storage.hooks[storageKey]];
    }

    return [false, matchFunc(storageKey, data)];
}

function hooks_validateMatchedObject(obj)
{
    if (typeof obj.patchAddr == "undefined" || obj.patchAddr === 0)
    {
        fatalError("Not set patchAddr in hook");
    }
    if (obj.endHook !== true)
    {
        fatalError("Not supported endHook value: " + obj.endHook);
    }
}

function hooks_createEntry(text, vars)
{
    var obj = {};
    obj.text = text;
    obj.vars = vars;
    obj.patch = patch.getName();
    return obj;
}

function hooks_createEntry2(text, vars)
{
    if (text.length > 2 && text[0] === ";")
    {
        return hooks.createEntry(text, vars);
    }
    return hooks.createEntry(asm.hexToAsm(text), vars);
}

function hooks_addFunctions(obj)
{
    obj.addEntry = function addEntry(text, vars, isPost, entries, weight)
    {
        if (typeof vars === "undefined")
        {
            vars = {};
        }
        var asmObj = hooks.insertAsm(text, vars, 5);
        if (typeof weight === "undefined")
        {
            asmObj.weight = 10000;
        }
        else
        {
            asmObj.weight = weight;
        }
        entries.pushSorted(asmObj);
        storage.multiHooks[asmObj.patch] = true;
    };
    obj.addPre = function addPre(text, vars, weight)
    {
        this.addEntry(text, vars, false, this.preEntries, weight);
    };
    obj.addPost = function addPost(text, vars, weight)
    {
        this.addEntry(text, vars, true, this.postEntries, weight);
    };
    obj.addFilePre = function addFilePre(fileName, vars, weight)
    {
        var text = asm.load(fileName);
        this.addEntry(text, vars, false, this.preEntries, weight);
    };
    obj.addFilePost = function addFilePost(fileName, vars, weight)
    {
        var text = asm.load(fileName);
        this.addEntry(text, vars, true, this.postEntries, weight);
    };
    obj.addFinal = function addFinal(text, vars)
    {
        if (typeof vars === "undefined")
        {
            vars = {};
        }
        obj.finalEntry = hooks.createEntry(text, vars);
        obj.finalEntry.isFinal = true;
    };
    obj.applyFinal = function applyFinal()
    {
        hooks_applyFinal(this);
    };
    obj.validate = function validate()
    {
        hooks_applyFinal(this, true);
    };
}

function hooks_initMatchedObject(matchFunc, obj)
{
    obj.matchFunc = matchFunc.name;
    obj.preEntries = [];
    obj.postEntries = [];
    if (obj.stolenCode1 != "")
    {
        obj.stolenEntry = hooks.createEntry2(obj.stolenCode1, {});
    }
    else
    {
        obj.stolenEntry = "";
    }
    if (obj.retCode != "")
    {
        obj.finalEntry = hooks.createEntry2(obj.retCode, {});
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

function hooks_removePatchHooks()
{
    var name = patch.getName();

    if (!(name in storage.multiHooks))
    {
        return;
    }

    function filterArray(obj)
    {
        return obj.patch != name;
    }

    for (var patchAddr in storage.hooks)
    {
        var obj = storage.hooks[patchAddr];
        obj.preEntries = obj.preEntries.filter(filterArray);
        obj.postEntries = obj.postEntries.filter(filterArray);
    }
}

function hooks_duplicateStackCode(offset, stackSize, isCdecl, stolenCode)
{
    checkArgs("hooks.duplicateStackCode", arguments, [["Number", "Number", "Boolean", "String"]]);
    var count = parseInt(stackSize / 4);
    if (count * 4 !== stackSize)
    {
        fatalError("Wrong stack size: " + stackSize);
    }
    var text = asm.load("stack_duplicate_pre");
    var push = asm.load("stack_duplicate_push");
    var pushes = "";
    for (var i = 0; i < count; i ++)
    {
        pushes = asm_combine(pushes, push);
    }
    var vars;
    var addesp = "";
    if (isCdecl === true)
    {
        addesp = asm.load("stack_duplicate_addesp");
    }
    vars = {
        "func": offset,
        "pushes": pushes,
        "pushOffset": stackSize + 4,
        "retOffset": stackSize + 4,
        "stolenCode": stolenCode,
        "addSize": stackSize,
        "addesp": addesp,
    };
    return asm_textToHexVa(0, text, vars);
}

function hooks_insertAsm(commands, vars, freeSpace, dryRun)
{
    var asmObj = pe.insertAsmTextObj(commands, vars, freeSpace, dryRun);
    delete asmObj.vars;
    asmObj.patch = patch.getName();
    asmObj.bytesLength = asmObj.bytes.length;
    delete asmObj.bytes;
    asmObj.code = "";
    return asmObj;
}

function hooks_addEntryByKey(storageKey, asmObj, isPost)
{
    if (!(storageKey in storage.hooks))
    {
        fatalError("hooks.addEntryByKey: storage key not found");
    }
    var obj = storage.hooks[storageKey];
    var entries;
    if (isPost === true)
    {
        entries = obj.postEntries;
    }
    else
    {
        entries = obj.preEntries;
    }
    entries.pushSorted(asmObj);
    storage.multiHooks[asmObj.patch] = true;
    return true;
}

function hooks_addFinalEntryByKey(storageKey, text, vars)
{
    var obj = storage.hooks[storageKey];
    obj.addFinal(text, vars);
}

function hooks_createHookObj()
{
    var obj = {};
    obj.patchAddr = 0;
    obj.free = 0;
    obj.text = "";
    obj.vars = {};
    obj.continueOffsetVa = 0;
    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";

    obj.firstJmpType = hooks.jmpTypes.JMP;
    obj.isDuplicate = false;
    return obj;
}

function registerHooks()
{
    hooks = {};
    hooks.jmpTypes = {
        "JMP": 0,
        "IMPORT": 1,
        "CALL": 2,
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
    hooks.initTableStartHookSize = hooks_initTableStartHookSize;
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
    hooks.createEntry2 = hooks_createEntry2;
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
