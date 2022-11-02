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

function DisableWindows()
{
    var makeWnd = table.getRaw(table.UIWindowMgr_MakeWindow);

    var code =
        " 0F B6 ?? ?? ?? ?? 00" +
        " FF 24 85 ?? ?? ?? 00";

    var offset = pe.find(code, makeWnd, makeWnd + 0x200);
    if (offset === -1)
    {
        return "Failed in Step 1 - Can't find indirect table for switch statement";
    }

    var ITSS = pe.fetchDWord(offset + 3);

    var dfCase = pe.fetchHex(pe.vaToRaw(ITSS + 54), 1);
    if (dfCase !== pe.fetchHex(pe.vaToRaw(ITSS + 67), 1))
    {
        return "Failed in Step 2";
    }

    var fp = new TextFile();
    var inpFile = GetInputFile(fp, "$DisableWindows", _("File Input - Disable Windows"), _("Enter the Disable Windows file"), APP_PATH + "/Input/DisableWindows.txt");
    if (!inpFile)
    {
        return "Patch Cancelled";
    }

    var WndID = [];
    while (!fp.eof())
    {
        var line = fp.readline().trim();
        if (line === "") continue;

        if (line.match(/^([\d]{1,3})$/))
        {
            var value = parseInt(line.substr(0));
            if (!isNaN(value))
            {
                WndID.push(value);
            }
        }
    }
    fp.close();

    if (WndID.length === 0)
    {
        return "Patch Cancelled";
    }

    for (var i = 0; i < WndID.length; i++)
    {
        pe.replaceHex(pe.vaToRaw(ITSS + WndID[i]), dfCase);
    }

    return true;
}
