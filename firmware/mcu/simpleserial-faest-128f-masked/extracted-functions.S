.syntax unified
.thumb

.global clean_call
clean_call:
    push    {r4, r5, r6, r7, r8, r9, r10, lr}
    mov     r0, #0
    mov     r1, #0
    mov     r2, #0
    mov     r3, #0
    mov     r4, #0
    mov     r5, #0
    mov     r6, #0
    mov     r7, #0
    mov     r8, #0
    mov     r9, #0
    mov     r10, #0

    sub     sp, #80
    str     r0, [sp, #0]
    str     r0, [sp, #4]
    str     r0, [sp, #8]
    str     r0, [sp, #12]
    str     r0, [sp, #16]
    str     r0, [sp, #20]
    str     r0, [sp, #24]
    str     r0, [sp, #28]
    str     r0, [sp, #32]
    str     r0, [sp, #36]
    str     r0, [sp, #40]
    str     r0, [sp, #44]
    str     r0, [sp, #48]
    str     r0, [sp, #52]
    str     r0, [sp, #56]
    str     r0, [sp, #60]
    str     r0, [sp, #64]
    str     r0, [sp, #68]
    str     r0, [sp, #72]
    str     r0, [sp, #76]
    add     sp, #80

    bl      sign

    mov    r0, #0
    pop    {r4, r5, r6, r7, r8, r9, r10, pc}
