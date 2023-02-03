//
// Copyright (C) 2021-2023 Andrei Karas (4144)
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

function UINewMakeCharWndCreation_match()
{
    var renderHex = table.getHex4(table.g_renderer);
    var widthHex = table.getHex1(table.g_renderer_m_width);
    var heightHex = table.getHex1(table.g_renderer_m_height);

    var code = [
        [
            "E8 ?? ?? ?? ?? " +
            "68 A6 01 00 00 " +
            "68 1A 03 00 00 " +
            "8B ?? " +
            "E8 ?? ?? ?? ?? " +
            "8B 0D " + renderHex +
            "?? ?? " +
            "8B 41 " + heightHex +
            "2D A6 01 00 00 " +
            "99 " +
            "2B C2 " +
            "D1 F8 " +
            "83 E8 ?? " +
            "50 " +
            "8B 41 " + widthHex +
            "2D 1A 03 00 00 " +
            "99 " +
            "2B C2 " +
            "D1 F8 " +
            "E9 ",
            {
                "windowYOffset": [45, 1],
                "widthOffsets": [[11, 4], [51, 4]],
                "heightOffsets": [[6, 4], [34, 4]],
            },
        ],
        [
            "E8 ?? ?? ?? ?? " +
            "68 A6 01 00 00 " +
            "68 1A 03 00 00 " +
            "8B ?? " +
            "E8 ?? ?? ?? ?? " +
            "8B 0D " + renderHex +
            "?? ?? " +
            "8B 41 " + heightHex +
            "2D A6 01 00 00 " +
            "99 " +
            "2B C2 " +
            "D1 F8 " +
            "83 E8 ?? " +
            "50 " +
            "8B 41 " + widthHex +
            "2D 1A 03 00 00 " +
            "99 " +
            "2B C2 " +
            "D1 F8 " +
            "50 " +
            "8B ?? ?? " +
            "E9 ",
            {
                "windowYOffset": [45, 1],
                "widthOffsets": [[11, 4], [51, 4]],
                "heightOffsets": [[6, 4], [34, 4]],
            },
        ],
        [
            "E8 ?? ?? ?? ?? " +
            "68 A6 01 00 00 " +
            "68 1A 03 00 00 " +
            "8B ?? " +
            "E8 ?? ?? ?? ?? " +
            "8B 0D " + renderHex +
            "?? ?? " +
            "8B 41 " + heightHex +
            "2D A6 01 00 00 " +
            "99 " +
            "2B C2 " +
            "D1 F8 " +
            "83 E8 ?? " +
            "50 " +
            "8B 41 " + widthHex +
            "8B CB " +
            "2D 1A 03 00 00 " +
            "99 " +
            "2B C2 " +
            "D1 F8 " +
            "50 " +
            "8B ?? ?? " +
            "FF D0 " +
            "E9 ",
            {
                "windowYOffset": [45, 1],
                "widthOffsets": [[11, 4], [53, 4]],
                "heightOffsets": [[6, 4], [34, 4]],
            },
        ],
    ];

    var offsetObj = pe.findAnyCode(code);

    if (offsetObj === -1)
    {
        throw "Pattern not found";
    }

    var obj = hooks.createHookObj();

    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";
    obj.endHook = false;

    obj.offset = offsetObj.offset;
    obj.windowYOffset = offsetObj.windowYOffset;
    obj.widthOffsets = offsetObj.widthOffsets;
    obj.heightOffsets = offsetObj.heightOffsets;

    return obj;
}

function FixNewCharCreationPos()
{
    var obj = UINewMakeCharWndCreation_match();

    var yOffset = exe.getUserInput(
        "$UINewMakeCharWndYOffset", XTYPE_BYTE,
        _("Y offset for new char creation window"),
        _("Enter y offset for new char creation window (wrong default: 70)"),
        0, -127, 127
    );

    pe.setValue(obj.offset, obj.windowYOffset, yOffset);
    return true;
}

function FixNewCharCreationPos_()
{
    return pe.stringRaw(".?AVUIRPImageWnd@@") !== -1;
}
