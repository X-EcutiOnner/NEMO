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

function SetDrawingFontHeight_imp(name, description, def, min, max)
{
    var value = exe.getUserInput(
        name, XTYPE_DWORD,
        _("Number Input"),
        description,
        def, min, max
    );

    var vars = {
        "value": value,
    };

    var hook = hooks.initTableStartHook(table.DrawDC_SetFont);
    hook.addFilePre("", vars);
    hook.validate();

    return true;
}

function SetDrawingFontHeight()
{
    return SetDrawingFontHeight_imp(
        "$SetDrawingFontHeight",
        _("Enter fixed drawing font height"),
        12, 0, 1000
    );
}

function SetDrawingFontHeightMin()
{
    return SetDrawingFontHeight_imp(
        "$SetDrawingFontHeightMin",
        _("Enter minimal allowed drawing font height"),
        1, 0, 1000
    );
}

function SetDrawingFontHeightMax()
{
    return SetDrawingFontHeight_imp(
        "$SetDrawingFontHeightMax",
        _("Enter maximum allowed drawing font height"),
        1, 0, 1000
    );
}

function SetDrawingFontHeightAdjust()
{
    return SetDrawingFontHeight_imp(
        "$SetDrawingFontHeightAdjust",
        _("Enter number for adjust drawing font height"),
        1, -1000, 1000
    );
}
