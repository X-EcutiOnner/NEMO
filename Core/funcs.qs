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

function floatToHex(value)
{
    return floatToDWord(value).packToHex(4);
}

function enablePatchAndCheck(name)
{
    if (isPatchActive(name) !== true)
    {
        enablePatch(name);
        if (isPatchActive(name) !== true)
        {
            throw "Patch '" + name + "' must be enabled";
        }
    }
}

function isOneOfPatchesActive()
{
    var args = Array.prototype.slice.call(arguments);

    for (var idx = 0; idx < args.length; idx ++)
    {
        if (isPatchActive(args[idx]) === true)
        {
            return true;
        }
    }
    return false;
}

function enableOneOfPatchAndCheck()
{
    if (isOneOfPatchesActive(arguments) === true)
    {
        return;
    }
    var args = Array.prototype.slice.call(arguments);
    var str = "";
    for (var idx = 0; idx < args.length; idx ++)
    {
        var name = args[idx];
        enablePatch(name);
        if (isPatchActive(name) === true)
        {
            return;
        }
        str = str + " " + name;
    }
    throw "One of patches '" + str + "' must be enabled";
}

function partialCheckRetNeg(func, num)
{
    if (typeof num === "undefined")
    {
        num = 0;
    }
    var proxyFunc = function proxyFunc()
    {
        var args = Array.prototype.slice.call(arguments);
        var res = func.apply(func, args);
        if (res < 0)
        {
            throw "Error: " + args[num] + " not found";
        }
        return res;
    };
    return proxyFunc;
}
