; tested with visual studio 2022
; make sure to link it with kernel32.lib and user32.lib
; also set entry point to "main"

extern RegisterClassExA : proc
extern CreateWindowExA : proc
extern HeapAlloc : proc
extern GetProcessHeap : proc
extern HeapFree : proc
extern GetModuleHandleA : proc
extern LoadCursorA : proc
extern LoadIconA : proc
extern DefWindowProcA : proc
extern CreateWindowExA : proc
extern ShowWindow : proc
extern UpdateWindow : proc
extern TranslateMessage : proc
extern DispatchMessageA : proc
extern GetMessageA : proc

class_name DB "TestAsmWindowClass", 0
window_name DB "Hello from MASM!", 0

.code

allocate PROC
  SUB  RSP, 28h
	PUSH RCX
	CALL GetProcessHeap
	MOV  RCX, RAX
	MOV  R8, QWORD PTR [RSP]
	XOR  EDX, EDX
	CALL HeapAlloc
	POP  RCX
	ADD  RSP, 28h
	RET
allocate ENDP

free_memory PROC
  SUB  RSP, 28h
	PUSH RCX
	CALL GetProcessHeap
	MOV  RCX, RAX
	MOV  R8, QWORD PTR [RSP]
	XOR  EDX, EDX
	CALL HeapFree
	POP  RCX
	ADD  RSP, 28h
	RET
free_memory ENDP

get_app_hinstance PROC
  SUB  RSP, 20h
  XOR  RCX, RCX
  CALL GetModuleHandleA
  ADD  RSP, 20h
  RET
get_app_hinstance ENDP

get_def_icon PROC
  SUB  RSP, 20h
	XOR  RCX, RCX
	MOV  RDX, 7F00h
	CALL LoadIconA
	ADD  RSP, 20h
	RET
get_def_icon ENDP

get_def_cursor PROC
  SUB  RSP, 20h
	XOR  RCX, RCX
	MOV  RDX, 7F00h
	CALL LoadCursorA
	ADD  RSP, 20h
	RET
get_def_cursor ENDP

wndproc PROC
	SUB  RSP, 20h
	PUSH RDI
	CALL DefWindowProcA
	ADD  RSP, 20h
	POP  RDI
	RET
wndproc ENDP

reg_class_2 PROC
  SUB  RSP, 20h
	CALL RegisterClassExA
	ADD  RSP, 20h
	RET
reg_class_2 ENDP

reg_class PROC
	SUB  RSP, 28h
	MOV  RCX, 50h
	CALL allocate
	MOV  R11, RAX
	PUSH R11
	MOV  DWORD PTR [R11], 50h
	MOV  DWORD PTR [R11 + 4h], 3h
	MOV  R10, OFFSET [wndproc]
	MOV  QWORD PTR [R11 + 8h], R10
	MOV  DWORD PTR [R11 + 10h], 0h
	MOV  DWORD PTR [R11 + 14h], 8h
	CALL get_app_hinstance
	MOV  QWORD PTR [R11 + 18h], RAX
	CALL get_def_icon
	MOV  R11, QWORD PTR [RSP]
	MOV  QWORD PTR [R11 + 20h], RAX
	CALL get_def_cursor
	MOV  R11, QWORD PTR [RSP]
	MOV  QWORD PTR [R11 + 28h], RAX
	MOV  QWORD PTR [R11 + 30h], 6h
	MOV  QWORD PTR [R11 + 38h], 0h
	MOV  R10, OFFSET [class_name]
	MOV  QWORD PTR [R11 + 40h], R10
	MOV  QWORD PTR [R11 + 48h], 0h
	MOV  RCX, R11
	CALL reg_class_2
	MOV  RCX, QWORD PTR [RSP]
	CALL free_memory
	POP  R11
	ADD  RSP, 28h
	RET
reg_class ENDP

create_wnd PROC
	SUB  RSP,  78h
	XOR  RCX,  RCX
	MOV  RDX,  OFFSET [class_name]
	MOV  R8,   OFFSET [window_name]
	MOV  R9D,  00CF0000h
	MOV  R10D, 80000000h
	MOV  DWORD PTR [RSP + 20h], R10D
	MOV  DWORD PTR [RSP + 28h], R10D
	MOV  DWORD PTR [RSP + 30h], 280h
	MOV  DWORD PTR [RSP + 38h], 118h
	MOV  QWORD PTR [RSP + 40h], 0h
	MOV  QWORD PTR [RSP + 48h], 0h
	CALL get_app_hinstance
	MOV  QWORD PTR [RSP + 50h], RAX
	MOV  QWORD PTR [RSP + 58h], 0h
	CALL CreateWindowExA
	ADD  RSP,  78h
	RET
create_wnd ENDP

mainloop PROC
	SUB  RSP, 58h
	PUSH RCX
	MOV  EDX, 1h
	CALL ShowWindow
	TEST EAX, EAX
	MOV  RCX, QWORD PTR [RSP]
	CALL UpdateWindow
	TEST EAX, EAX
	JZ   fail
	loop1:
		LEA  RCX, QWORD PTR [RSP + 20h]
		XOR  EDX, EDX
		XOR  R8D, R8D
		XOR  R9D, R9D
		CALL GetMessageA
		TEST EAX, EAX
		JZ   fail
		LEA  RCX, QWORD PTR [RSP + 20h]
		CALL TranslateMessage
		LEA  RCX, QWORD PTR [RSP + 20h]
		CALL DispatchMessageA
		JMP  loop1
	fail:
		POP  RCX
		ADD  RSP, 58h
		RET
mainloop ENDP

main PROC
	SUB  RSP, 20h
	PUSH RBX
	CALL reg_class
	CALL create_wnd
	MOV  RCX, RAX
	CALL mainloop
	POP  RBX
	ADD  RSP, 20h
	RET
main ENDP

end
