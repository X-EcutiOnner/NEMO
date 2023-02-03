//
// Copyright (C) 2018-2023 Andrei Karas (4144)
// Copyright (C) 2020 Asheraf
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

function ChangeAdventureAgencyLevelRange()
{
    var offset = pe.stringVa("%d");

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var strHex = offset.packToHex(4);

    var code =
        "8D 46 05" +
        "66 C7 45 ?? 00 00" +
        "50" +
        "68" + strHex +
        "6A FF";

    var rangeUOffset = [2, 1];
    var offsetsU = pe.findCodes(code);

    if (offsetsU.length === 0)
    {
        code =
            "8D 46 05" +
            "50" +
            "68" + strHex +
            "6A FF";

        rangeUOffset = [2, 1];
        offsetsU = pe.findCodes(code);
    }

    if (offsetsU.length === 0)
    {
        return "Failed in Step 1 - AgencyUpperLevelRange not found";
    }

    code =
        "8D 46 ??" +
        "0F 57 C0" +
        "3B C1" +
        "66 0F D6 45 ??" +
        "0F 4C C1" +
        "50" +
        "68" + strHex +
        "6A FF";

    var rangeLOffset = [2, 1];
    var offsetsL = pe.findCodes(code);

    if (offsetsL.length === 0)
    {
        code =
            "8D 46 ??" +
            "3B C1" +
            "0F 4C C1" +
            "50" +
            "68" + strHex +
            "6A FF";

        rangeLOffset = [2, 1];
        offsetsL = pe.findCodes(code);
    }

    if (offsetsL.length === 0)
    {
        code =
            "8D 46 ?? " +
            "66 C7 ?? ?? ?? 00 " +
            "B9 01 00 00 00 " +
            "0F 57 C0 " +
            "3B C1 " +
            "66 0F D6 45 ?? " +
            "0F 4F C8 " +
            "8D 45 ?? " +
            "51 " +
            "68" + strHex +
            "6A FF ";

        rangeLOffset = [2, 1];
        offsetsL = pe.findCodes(code);
    }

    if (offsetsL.length === 0)
    {
        return "Failed in Step 2 - AgencyLowerLevelRange not found";
    }

    var upprangeVal = exe.getUserInput("$upprangeVal", XTYPE_BYTE, _("upper level range (default +5)"), _("Enter new upper level range"), "+5", 1, 127);
    var lowrangeVal = exe.getUserInput("$lowrangeVal", XTYPE_BYTE, _("lower level range (default -5)"), _("Enter new lower level range"), "-5", -127, -1);
    var i;

    for (i = 0; i < offsetsU.length; i++)
    {
        pe.replaceByte(offsetsU[i] + rangeUOffset[0], upprangeVal);
    }

    for (i = 0; i < offsetsL.length; i++)
    {
        pe.replaceByte(offsetsL[i] + rangeLOffset[0], lowrangeVal);
    }

    return true;
}

function ChangeAdventureAgencyLevelRange_()
{
    return pe.stringRaw("btn_job_def_on") !== -1;
}
