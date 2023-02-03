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

function ChangeNewCharName_match()
{
    var addr1 = table.getRawValidated(table.UINewMakeCharWnd_OnCreate);
    var addr2 = table.getRawValidated(table.UINewMakeCharWnd_OnCreate_ret);

    var code = [
        [
            "C7 45 ?? FF FF FF FF" +
            "6A 0D" +
            "68 82 00 00 00" +
            "8B C8" +
            "89 83 ?? ?? 00 00" +
            "E8 ?? ?? ?? ??" +
            "8B 8B ?? ?? 00 00",
            {
                "heightOffset": [8, 1],
            },
        ],
        [
            "C7 45 ?? FF FF FF FF" +
            "8B C8" +
            "6A 0D" +
            "68 82 00 00 00" +
            "89 83 ?? ?? 00 00" +
            "E8 ?? ?? ?? ??" +
            "8B 8B ?? ?? 00 00",
            {
                "heightOffset": [10, 1],
            },
        ],
        [
            "C7 45 ?? FF FF FF FF " +
            "8B C8 " +
            "6A 14 " +
            "68 82 00 00 00 " +
            "89 83 ?? ?? 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "8B 8B ?? ?? 00 00",
            {
                "heightOffset": [10, 1],
            },
        ],
        [
            "C7 45 ?? FF FF FF FF " +
            "6A 10 " +
            "6A 6E " +
            "8B C8 " +
            "89 86 ?? ?? 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "8B 8E ?? ?? 00 00",
            {
                "heightOffset": [8, 1],
            },
        ],
        [
            "C7 45 ?? FF FF FF FF " +
            "6A 14 " +
            "68 82 00 00 00 " +
            "8B C8 " +
            "89 83 ?? ?? 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "8B 8B ?? ?? 00 00",
            {
                "heightOffset": [8, 1],
            },
        ],
    ];

    var offsetObj = pe.findAny(code, addr1, addr2);

    if (offsetObj === -1)
    {
        throw "Failed in step 1 - pattern not found";
    }

    var offset = offsetObj.offset;

    var obj = hooks.createHookObj();

    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";
    obj.endHook = false;

    obj.offset = offset;
    obj.heightOffset = offsetObj.heightOffset;
    return obj;
}

function ChangeNewCharNameHeight()
{
    var obj = ChangeNewCharName_match();

    var height = exe.getUserInput(
        "$newCharNameHeight",
        XTYPE_BYTE,
        _("Number Input"),
        _("Enter new char name height (0-255, default is 13):"),
        13,
        0, 255
    );
    if (height === 13)
    {
        return "Patch Cancelled - New value is same as old";
    }

    pe.setValue(obj.offset, obj.heightOffset, height);

    return true;
}

function ChangeNewCharNameHeight_()
{
    return pe.stringRaw(".?AVUINewMakeCharWnd@@") !== -1;
}
