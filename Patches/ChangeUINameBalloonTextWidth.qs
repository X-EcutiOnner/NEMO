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

function UINameBalloonTextWidth(addrId, name)
{
    var fieldId = table.UINameBalloonText_m_textWidth;
    var paramStr = "$" + name + "TextWidth";

    var value = exe.getUserInput(paramStr, XTYPE_DWORD, _("Number Input"), _("Enter default text width for @@").replace("@@", name), 0, 0, 1000);
    if (value === 0)
    {
        throw "New text width is same";
    }

    if (table.get(addrId) === 0)
    {
        throw name + "::" + name + " ret not set";
    }
    var addrRaw = table.getRaw(addrId);

    var field = table.get(fieldId);
    if (field === 0)
    {
        throw "UIBalloonText::m_textWidth not set";
    }

    var text = "mov dword ptr [eax + m_textWidth], textWidth";
    var vars = {
        "m_textWidth": field,
        "textWidth": value,
    };

    var hook = hooks.initEndHook(addrRaw);
    hook.addPost(text, vars);
    hook.validate();
}

function ChangeUINameBalloonTextWidth()
{
    UINameBalloonTextWidth(table.UINameBalloonTextConstructor_ret, "UINameBalloonText");
    return true;
}

function ChangeUIVerticalNameBalloonTextWidth()
{
    UINameBalloonTextWidth(table.UIVerticalNameBalloonTextConstructor_ret, "UIVerticalNameBalloonText");
    return true;
}

function ChangeNameBalloonFontBold()
{
    enablePatchAndCheck("DisableSetTextType");
    var value = exe.getUserInput(
        "$ChangeNameBalloonFontBold",
        XTYPE_BYTE,
        _("Use bold font"),
        _("Use bold(1) or normal(0) for names"),
        0,
        0, 1
    );

    var vars = {
        "bold": value,
    };

    var hook = hooks.initTableEndHook(table.InitClientInfo_ret);
    hook.addFilePost("", vars);
    hook.validate();

    return true;
}

function ChangeNameBalloonFontBold_apply()
{
    if (isPatchActive("DisableSetTextType") === false)
    {
        return "Need patch DisableSetTextType";
    }
    return true;
}
