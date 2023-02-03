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

String.prototype.toHex1 = function toHex1()
{
    var result = "";
    for (var i = 0; i < this.length; i++)
    {
        var h = this.charCodeAt(i).toString(16);
        if (h.length === 1)
        {
            h = "0" + h;
        }
        result += h;
    }
    return result;
};

function getClientName()
{
    var name = CLIENT_FILE.split("/").pop();
    var idx = name.lastIndexOf(".");
    if (idx >= 0)
    {
        return name.substring(0, idx);
    }
    return name;
}

function GlobalPostInit()
{
}

function fatalError(text)
{
    if (typeof console2 !== "undefined")
    {
        console2.fatalError(text);
    }
    throw text;
}

function logArgsError(text)
{
    if (typeof console2 === "undefined")
    {
        throw text;
    }
    console2.logArgsError(text);
}
