; Copyright (C) 2021-2023 Andrei Karas (4144)
;
; Patch is licensed under a
; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
;
; You should have received a copy of the license along with this
; work. If not, see <http://creativecommons.org/licenses/by-nc-nd/4.0/>.
;

%tablevar ErrorMsg
%tablevar ErrorMsg_type

mov eax, dword ptr [serverType]
cmp eax, sakray
jz ret

%if ErrorMsg_type == 2
push 0
%endif
push error
call ErrorMsg
%if ErrorMsg_type == 1
add esp, 4
%endif
%if ErrorMsg_type == 2
add esp, 8
%endif

ret:
