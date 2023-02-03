; Copyright (C) 2022-2023 Andrei Karas (4144)
;
; Patch is licensed under a
; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
;
; You should have received a copy of the license along with this
; work. If not, see <http://creativecommons.org/licenses/by-nc-nd/4.0/>.
;

%tablevar g_windowMgr
%tablevar UIWindowMgr_SendMsg

cmp eax, 0xFFFFFFFF
jnz _ret
mov ecx, dword ptr [esp + 0xc - 4]
mov ecx, dword ptr [ecx]
cmp ecx, 3
jnz _ret

_non_handled_command:
push esi
push edi
mov esi, dword ptr [esp + 0x8 - 4 + 8]
mov edi, command
call simple_strcmp
pop edi
pop esi
cmp eax, 0
jnz _wrong_cmd

_correct_cmd:
mov eax, dword ptr [delay1]
cmp eax, 0
mov ecx, g_windowMgr
push 0
push 0
push textColor
jz _restore_delay

_show_zero_delay:
push zeroMessage
push 1
call UIWindowMgr_SendMsg
xor eax, eax
mov dword ptr [delay1], eax
%ifdef delay2
mov dword ptr [delay2], eax
%endif
jmp _good_cmd

zeroMessage:
asciz "Walk delay disabled."
restoreMessage:
asciz "Walk delay enabled."

%include simple_strcmp

_restore_delay:
mov eax, value1
mov dword ptr [delay1], eax
%ifdef delay2
mov eax, value2
mov dword ptr [delay2], eax
%endif

_show_restore_delay:
push restoreMessage
push 1
call UIWindowMgr_SendMsg

_good_cmd:
mov eax, 30000
mov ecx, dword ptr [esp + 0xc - 4]
mov dword ptr [ecx], eax

_wrong_cmd:
mov eax, 0xFFFFFFFF

_ret:
