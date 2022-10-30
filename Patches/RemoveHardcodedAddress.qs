//
// Copyright (C) 2017-2022  Andrei Karas (4144)
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
// ###########################################################################
// # Purpose: Remove hardcoded otp / login addreses and ports                #
// ###########################################################################

function RemoveHardcodedAddressOld(offset, overrideAddressOffset)
{
    var overrideAddr = offset + overrideAddressOffset + 4 + pe.fetchDWord(offset + overrideAddressOffset);

    offset = pe.find("31 32 37 2E 30 2E 30 2E 31 00");
    if (offset === -1)
    {
        return "Failed in search 127.0.0.1 (old)";
    }
    offset = pe.rawToVa(offset);

    var code = " " +
        offset.packToHex(4) +
        " 26 1B 00 00";
    var otpAddr = pe.find(code);
    if (otpAddr === -1)
    {
        return "Failed in step 2b (old)";
    }
    otpAddr = pe.rawToVa(otpAddr);
    var otpPort = otpAddr + 4;
    var clientinfo_addr = table.getValidated(table.g_accountAddr);
    var clientinfo_port = table.getValidated(table.g_accountPort);

    code =
        " FF 35" + otpAddr.packToHex(4) +
        " 8B ?? ?? ?? ?? 00" +
        " 68 ?? ?? ?? 00" +
        " 6A FF" +
        " 8D ?? ?? ?? FF FF" +
        " 6A 10";
    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in step 3a (old)";
    }

    pe.replaceHex(offset + 2, clientinfo_addr.packToHex(4));

    var atoi = imports.ptrHexValidated("atoi");

    var newCode =
        "FF 35 " + clientinfo_port.packToHex(4) +
        "FF 15 " + atoi +
        "A3" + otpPort.packToHex(4) +
        "83 C4 04" +
        "C3";
    pe.replaceHex(overrideAddr, newCode);

    return true;
}

function RemoveHardcodedAddress20207(overrideAddr, retAddr, clientinfo_addr, clientinfo_port)
{
    var offset = pe.stringVa("kro-agency.ragnarok.co.kr");
    if (offset === -1)
    {
        return "kro-agency.ragnarok.co.kr not found";
    }
    var hostHex = offset.packToHex(4);

    offset = pe.stringVa("%s:%d");
    if (offset === -1)
    {
        return "string '%s:%d' not found";
    }
    var sdHex = offset.packToHex(4);

    var code =
        "52 " +
        "68 " + hostHex +
        "68 " + sdHex +
        "6A FF " +
        "68 81 00 00 00 " +
        "68 ?? ?? ?? ?? " +
        "E8 ?? ?? ?? ?? " +
        "83 C4 18 ";
    var authHostOffset = 19;
    var snprintfOffset = [24, 4];
    offset = pe.find(code, overrideAddr, overrideAddr + 0x300);

    if (offset === -1)
    {
        return "Failed in search snprintf_s call";
    }

    var authHostVa = pe.fetchDWord(offset + authHostOffset);

    var formatStr = pe.rawToVa(pe.insertString("%s:%s"));

    var vars = {
        "clientinfo_addr": clientinfo_addr,
        "clientinfo_port": clientinfo_port,
        "formatStr": formatStr,
        "g_auth_host_port": authHostVa,
        "snprintf_s": pe.fetchRelativeValue(offset, snprintfOffset),
        "continue": pe.rawToVa(retAddr),
    };

    pe.replaceAsmFile(overrideAddr, "RemoveHardcodedAddress2020", vars);

    return true;
}

function RemoveHardcodedAddressNew(overrideAddr, retAddr)
{
    var offset = pe.find("31 32 37 2E 30 2E 30 2E 31 00");
    if (offset === -1)
    {
        return "Failed in search 127.0.0.1 (old)";
    }
    offset = pe.rawToVa(offset);

    var code = " " +
        offset.packToHex(4) +
        " 26 1B 00 00";
    var otpAddr = pe.find(code);
    if (otpAddr === -1)
    {
        return "Failed in step 2b (new)";
    }
    otpAddr = pe.rawToVa(otpAddr);
    var otpPort = otpAddr + 4;
    var clientinfo_addr = table.getValidated(table.g_accountAddr);
    var clientinfo_port = table.getValidated(table.g_accountPort);

    if (pe.getDate() >= 20200630)
    {
        return RemoveHardcodedAddress20207(overrideAddr, retAddr, clientinfo_addr, clientinfo_port);
    }
    code =
        "FF 35" + otpAddr.packToHex(4) +
        "8D ?? ?? ?? ?? FF " +
        "68 ?? ?? ?? 00 " +
        "6A FF " +
        "6A 10 " +
        "50 ";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in step 3a (new)";
    }

    pe.replaceHex(offset + 2, clientinfo_addr.packToHex(4));

    var atoi = imports.ptrHexValidated("atoi");

    var jmpOffset = 21;
    var continueAddr = retAddr - overrideAddr - jmpOffset - 4;

    var newCode =
        "FF 35 " + clientinfo_port.packToHex(4) +
        "FF 15 " + atoi +
        " A3" + otpPort.packToHex(4) +
        " 83 C4 04" +
        " E9" + continueAddr.packToHex(4);

    pe.replaceHex(overrideAddr, newCode);

    return true;
}

function RemoveHardcodedAddress()
{
    var code =
        " 80 3D ?? ?? ?? ?? 00" +
        " 75 ??" +
        " E8 ?? ?? 00 00" +
        " E9 ?? ?? 00 00";
    var overrideAddressOffset = 10;

    var offset = pe.findCode(code);

    if (offset !== -1)
    {
        return RemoveHardcodedAddressOld(offset, overrideAddressOffset);
    }

    var g_serverType = GetServerType();

    offset = pe.find("36 39 30 30 00");
    if (offset === -1)
    {
        return "Failed in search '6900' (new)";
    }
    var portStrHex = pe.rawToVa(offset).packToHex(4);

    code =
        "80 3D ?? ?? ?? ?? 00 " +
        "0F 85 ?? ?? ?? 00 " +
        "8B 15 " + g_serverType.packToHex(4) +
        "A1 ?? ?? ?? ?? " +
        "8B 0D ?? ?? ?? ?? " +
        "C7 05 ?? ?? ?? ?? " + portStrHex;
    overrideAddressOffset = 13;
    var retAddrOffset = 9;
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "80 3D ?? ?? ?? ?? 00 " +
            "0F 85 ?? ?? ?? 00 " +
            "EB 07 " +
            "C6 05 ?? ?? ?? ?? 00 " +
            "8B 15 " + g_serverType.packToHex(4) +
            "A1 ?? ?? ?? ?? " +
            "8B 0D ?? ?? ?? ?? " +
            "C7 05 ?? ?? ?? ?? " + portStrHex;
        overrideAddressOffset = 22;
        retAddrOffset = 9;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in step 1 (new)";
    }

    var retAddr = offset + retAddrOffset + 4 + pe.fetchDWord(offset + retAddrOffset);

    return RemoveHardcodedAddressNew(offset + overrideAddressOffset, retAddr);
}

function RemoveHardcodedAddress_()
{
    return pe.stringRaw(".?AVUILoginOTPWnd@@") !== -1;
}
