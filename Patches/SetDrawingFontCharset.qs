//
// Copyright (C) 2022-2023 Andrei Karas (4144)
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

function SetDrawingFontCharset()
{
    var value = exe.getUserInput(
        "$SetDrawingFontCharset", XTYPE_DWORD,
        _("Number Input"),
        _("Enter new drawing font charset (0-en, 1-default, 129-kr, 204-ru, etc)"),
        0, 0, 255
    );

    var vars = {
        "value": value,
        "m_charset": 0x14,
    };

    var hook = hooks.initTableStartHook(table.DrawDC_SetFont);
    hook.addFilePost("", vars);
    hook.validate();

    return true;
}
