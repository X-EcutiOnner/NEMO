; Copyright (C) 2017-2022 Andrei Karas (4144)
;
; Patch is licensed under a
; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
;
; You should have received a copy of the license along with this
; work. If not, see <http://creativecommons.org/licenses/by-nc-nd/4.0/>.
;

push dword ptr [clientinfo_port]
push dword ptr [clientinfo_addr]
push formatStr
push 0FFFFFFFFh
push 81h
push g_auth_host_port
call snprintf_s
add esp, 18h
jmp continue
