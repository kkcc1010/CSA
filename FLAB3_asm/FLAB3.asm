; nasm -f elf32 FLAB3.asm -o FLAB3.o
; ld -m elf_i386 FLAB3.o -o FLAB3
; ./FLAB3

%macro PRINT 1
    mov esi, %1
    call print_z
%endmacro

%macro PRINT_BUF 1
    mov esi, %1
    call print_z
%endmacro

%macro NL 0
    PRINT newline
%endmacro

%macro SEP 0
    PRINT separator
%endmacro

section .data
    title_border db "==========================", 10, 0
    title        db "COR / TUITION FEE CALCULATOR", 10, 0
    separator    db "==========================", 10, 0
    tuition_sep  db "==========================", 10, 0
    student_info db "STUDENT INFORMATION", 10, 0
    courses_title db "COURSE CODE", 9, "TITLE", 10, 0
    courses_list db "CCS9021    INFORMATION MANAGEMENT (LEC)", 10
                 db "CCS9021L   INFORMATION MANAGEMENT (LAB)", 10
                 db "CS9001     DISCRETE STRUCTURES 1", 10
                 db "CS9003     COMPUTER SYSTEMS & ARCHITECTURE", 10
                 db "CS9003L    COMPUTER SYSTEMS & ARCHITECTURE (LAB)", 10
                 db "CS0070     OBJECT ORIENTED PROGRAMMING", 10
                 db "CS0070L    OBJECT ORIENTED PROGRAMMING-LAB", 10
                 db "GED0021    SPECIALIZED ENGLISH PROGRAM 2", 10
                 db "GED0075    LINEAR ALGEBRA", 10
                 db "GED0081    COLLEGE PHYSICS 1 LECTURE", 10
                 db "GED0081L   COLLEGE PHYSICS 1 LABORATORY", 10, 0
    newline      db 10, 0

    p_student    db "Student number: ", 0
    p_name       db "Full name: ", 0
    p_year       db "Year level (1-4): ", 0
    p_phone      db "Phone number: ", 0
    p_zip        db "Zip code: ", 0
    p_college    db "College: ", 0
    p_program    db "Program: ", 0
    p_address    db "Address: ", 0
    p_units      db "Total units: ", 0
    p_labs       db "Number of lab courses: ", 0
    invalid_num  db "Invalid input. Please enter a valid whole number.", 10, 0
    invalid_year db "Invalid year level. Enter a number from 1 to 4.", 10, 0

    l_student    db "Student # : ", 0
    l_name       db "Name : ", 0
    l_phone      db "Phone : ", 0
    l_zip        db "Zip Code : ", 0
    l_year       db "Year Level : ", 0
    l_college    db "College : ", 0
    l_program    db "Program : ", 0
    l_address    db "Address : ", 0
    total_label  db "TOTAL TUITION FEE : ", 0
    php_label    db " PHP", 10, 0

section .bss
    student     resb 64
    full_name   resb 128
    year_text   resb 16
    phone       resb 32
    zip_code    resb 16
    college     resb 128
    program     resb 128
    address     resb 256
    units_text  resb 16
    labs_text   resb 16
    year_value  resd 1
    units_value resd 1
    labs_value  resd 1
    tuition     resd 1

section .text
    global _start

_start:
    PRINT title_border
    PRINT title
    PRINT title_border

    PRINT p_student
    mov edi, student
    mov esi, 64
    call read_line

    PRINT p_name
    mov edi, full_name
    mov esi, 128
    call read_line

year_input:
    PRINT p_year
    mov edi, year_text
    mov esi, 16
    call read_line
    mov esi, year_text
    call parse_uint
    jc bad_year
    cmp eax, 1
    jb bad_year
    cmp eax, 4
    ja bad_year
    mov [year_value], eax
    jmp year_done

bad_year:
    PRINT invalid_year
    jmp year_input

year_done:
    PRINT p_phone
    mov edi, phone
    mov esi, 32
    call read_line

    PRINT p_zip
    mov edi, zip_code
    mov esi, 16
    call read_line

    PRINT p_college
    mov edi, college
    mov esi, 128
    call read_line
    mov esi, college
    call uppercase

    PRINT p_program
    mov edi, program
    mov esi, 128
    call read_line
    mov esi, program
    call uppercase

    PRINT p_address
    mov edi, address
    mov esi, 256
    call read_line

    SEP
    PRINT student_info
    SEP
    PRINT l_student
    PRINT_BUF student
    NL
    PRINT l_name
    PRINT_BUF full_name
    NL
    PRINT l_phone
    PRINT_BUF phone
    NL
    PRINT l_zip
    PRINT_BUF zip_code
    NL
    PRINT l_year
    mov eax, [year_value]
    call print_uint
    NL
    PRINT l_college
    PRINT_BUF college
    NL
    PRINT l_program
    PRINT_BUF program
    NL
    PRINT l_address
    PRINT_BUF address
    NL
    SEP

    PRINT courses_title
    SEP
    PRINT courses_list
    SEP

units_input:
    PRINT p_units
    mov edi, units_text
    mov esi, 16
    call read_line
    mov esi, units_text
    call parse_uint
    jc bad_units
    mov [units_value], eax
    jmp units_done

bad_units:
    PRINT invalid_num
    jmp units_input

units_done:
labs_input:
    PRINT p_labs
    mov edi, labs_text
    mov esi, 16
    call read_line
    mov esi, labs_text
    call parse_uint
    jc bad_labs
    mov [labs_value], eax
    jmp labs_done

bad_labs:
    PRINT invalid_num
    jmp labs_input

labs_done:
    mov eax, [units_value]
    mov ebx, [labs_value]
    call calculate_tuition
    mov [tuition], eax

    PRINT tuition_sep
    PRINT total_label
    mov eax, [tuition]
    call print_uint
    PRINT php_label
    PRINT tuition_sep

    mov eax, 1
    xor ebx, ebx
    int 0x80

; Reads a line into EDI, using ESI as the maximum buffer size.
read_line:
    mov eax, 3
    xor ebx, ebx
    mov ecx, edi
    mov edx, esi
    dec edx
    int 0x80
    test eax, eax
    jle .empty
    mov ecx, eax
    xor edx, edx
.scan:
    cmp edx, ecx
    jae .terminate
    cmp byte [edi + edx], 10
    je .terminate
    inc edx
    jmp .scan
.terminate:
    mov byte [edi + edx], 0
    ret
.empty:
    mov byte [edi], 0
    ret

; Calculates tuition from EAX units and EBX lab courses.
; The unit rate is 1000 PHP and the laboratory rate is 600 PHP.
calculate_tuition:
    imul eax, 1000
    imul ebx, 600
    add eax, ebx
    ret

; Converts lowercase ASCII letters in the string at ESI to uppercase.
uppercase:
.next:
    mov al, [esi]
    test al, al
    jz .done
    cmp al, 'a'
    jb .skip
    cmp al, 'z'
    ja .skip
    sub byte [esi], 32
.skip:
    inc esi
    jmp .next
.done:
    ret

; Parses a non-empty unsigned decimal string at ESI.
; Returns the value in EAX and sets CF when an invalid character is found.
parse_uint:
    xor eax, eax
    xor ecx, ecx
    xor edi, edi
.digit:
    mov dl, [esi + ecx]
    test dl, dl
    jz .finish
    cmp dl, '0'
    jb .invalid
    cmp dl, '9'
    ja .invalid
    sub dl, '0'
    mov ebx, eax
    lea eax, [eax + eax * 4]
    add eax, eax
    movzx edx, dl
    add eax, edx
    inc ecx
    inc edi
    jmp .digit
.finish:
    test edi, edi
    jz .invalid
    clc
    ret
.invalid:
    stc
    ret

; Prints the null-terminated string whose address is in ESI.
print_z:
    mov edi, esi
    xor edx, edx
.count:
    cmp byte [edi + edx], 0
    je .write
    inc edx
    jmp .count
.write:
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    int 0x80
    ret

print_uint:
    mov edi, units_text + 15
    mov byte [edi], 0
    mov ebx, 10
.convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .convert
    mov esi, edi
    call print_z
    ret