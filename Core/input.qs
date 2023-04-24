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

function input_getString(varName, title, label, def, max)
{
    checkArgs("input.getString", arguments, [
        ["String", "String", "String", "String"],
        ["String", "String", "String", "String", "Number"],
    ]);

    var dialog = input.createDialog();
    dialog.setTitle(title);
    dialog.addLabelText(varName, label, def, max);
    dialog.addOkCancel();
    dialog.setMinimumSize(200, 100);
    if (dialog.show() === 0)
    {
        throw _("Cancel button pressed");
    }

    return input.getVarValue(varName);
}

function input_getIntHex(varName, title, label, def, max)
{
    checkArgs("input.getIntHex", arguments, [
        ["String", "String", "String", "Number"],
    ]);

    var dialog = input.createDialog();
    dialog.setTitle(title);
    if (typeof max === "undefined")
    {
        max = 8;
    }
    dialog.addLabelText(varName, label, def.toBE(), max, "hhhhhhhh");
    dialog.addOkCancel();
    dialog.setMinimumSize(200, 100);
    if (dialog.show() === 0)
    {
        throw _("Cancel button pressed");
    }

    return parseInt(input.getVarValue(varName), 16);
}

function input_getInt(varName, title, label, def, min, max, step)
{
    checkArgs("input.getInt", arguments, [
        ["String", "String", "String", "Number", "Number", "Number", "Number"],
    ]);

    var dialog = input.createDialog();
    dialog.setTitle(title);
    if (typeof max === "undefined")
    {
        max = 8;
    }
    dialog.addLabelInt(varName, label, def, min, max, step);
    dialog.addOkCancel();
    dialog.setMinimumSize(200, 100);
    if (dialog.show() === 0)
    {
        throw _("Cancel button pressed");
    }

    return parseInt(input.getVarValue(varName), 10);
}

function input_getEncryptionKeys(count, defs)
{
    checkArgs("input.getEncryptionKeys", arguments, [
        ["Number", "Object"],
    ]);

    var title = _("Enter packet id encryption keys");
    var max = 8;
    var labels = [
        _("First key"),
        _("Second key"),
        _("Third key"),
    ];
    var varNames = [
        "$firstkey",
        "$secondkey",
        "$thirdkey",
    ];

    var dialog = input.createDialog();
    dialog.setTitle(title);
    dialog.addLabel(title);
    var i;
    for (i = 0; i < count; i++)
    {
        dialog.addLabelText(
            varNames[i],
            labels[i],
            defs[i].toBE(),
            max,
            "hhhhhhhh"
        );
    }

    dialog.addOkCancel();
    dialog.setMinimumSize(200, 100);
    if (dialog.show() === 0)
    {
        throw _("Cancel button pressed");
    }

    var rets = [];
    for (i = 0; i < count; i++)
    {
        rets.push(parseInt(input.getVarValue(varNames[i]), 16));
    }

    return rets;
}

function input_getWidthHeight(varPrefix, title, defWidth, defHeight, min, max)
{
    checkArgs("input.getWidthHeight", arguments, [
        ["String", "String", "Number", "Number", "Number", "Number"],
    ]);

    var dialog = input.createDialog();
    dialog.setTitle(title);
    dialog.addLabel(title);

    dialog.addLabelInt(
        varPrefix + "Width",
        _("Width"),
        defWidth,
        min,
        max,
        1
    );
    dialog.addLabelInt(
        varPrefix + "Height",
        _("height"),
        defHeight,
        min,
        max,
        1
    );

    dialog.addOkCancel();
    dialog.setMinimumSize(200, 100);
    if (dialog.show() === 0)
    {
        throw _("Cancel button pressed");
    }

    var rets = {};
    rets.width = parseInt(input.getVarValue(varPrefix + "Width"));
    rets.height = parseInt(input.getVarValue(varPrefix + "Height"));
    return rets;
}

function registerInput()
{
    input.getString = input_getString;
    input.getInt = input_getInt;
    input.getIntHex = input_getIntHex;
    input.getEncryptionKeys = input_getEncryptionKeys;
    input.getWidthHeight = input_getWidthHeight;
}
