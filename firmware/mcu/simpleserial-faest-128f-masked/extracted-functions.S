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
    pop    {r4, r5, r6, r7, r8, r9, r10, lr}

.global bf8_mul_masked
bf8_mul_masked:
    stmdb   sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    mov     r6, r1
    sub     sp, #12
    movs    r3, #0
    mov     r5, r0
    movs    r1, #1
    add.w   r0, sp, #7
    mov     r7, r2
    strb.w  r3, [sp, #7]
    bl      rand_mask
    ldrb.w  fp, [r6]
    ldrb    r0, [r5, #1]
    mov     r1, fp
    bl      bf8_mul
    ldrb.w  sl, [r5]
    ldrb    r1, [r6, #1]
    ldrb.w  r8, [sp, #7]
    mov     r4, r0
    mov     r0, sl
    bl      bf8_mul
    mov     r1, fp
    mov     r9, r0
    mov     r0, sl
    bl      bf8_mul
    eor.w   r4, r8, r4
    eor.w   r4, r4, r9
    eors    r0, r4
    strb    r0, [r7, #0]
    ldrb    r1, [r6, #1]
    ldrb    r0, [r5, #1]
    bl      bf8_mul
    eor.w   r8, r8, r0
    strb.w  r8, [r7, #1]
    add     sp, #12
    ldmia.w sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}

.global bf8_refresh
bf8_refresh:
    push    {r4, lr}
    mov     r4, r0
    sub     sp, #8
    movs    r3, #0
    movs    r1, #1
    add.w   r0, sp, #7
    strb.w  r3, [sp, #7]
    bl      rand_mask
    ldrb.w  r3, [sp, #7]
    ldrb    r2, [r4, #0]
    ldrb    r1, [r4, #1]
    eors    r2, r3
    eors    r0, r4, r4 // CLEAR pipeline (r2 leaked with r1)
    eors    r3, r1
    strb    r2, [r4, #0]
    strb    r3, [r4, #1]
    add     sp, #8
    pop     {r4, pc}

.global bf8_inv_masked
bf8_inv_masked:
    stmdb   sp!, {r4, r5, r6, r7, r8, lr}
    sub     sp, #8
    mov     r7, r0
    mov     r6, r1
    mov.w   r8, #0
    movs    r1, #1
    add.w   r0, sp, #6
    strb.w  r8, [sp, #6]
    bl      rand_mask
    ldrb.w  r5, [sp, #6]
    ldrb    r0, [r7, #0]
    orr.w   r5, r5, #1
    mov     r1, r5
    strb.w  r5, [sp, #6]
    bl      bf8_mul
    ldrb    r1, [r7, #1]
    mov     r4, r0
    mov     r0, r5
    bl      bf8_mul
    mov.w   r4, #0
    eors    r0, r4
    uxtb    r0, r0
    bl      bf8_inv
    movs    r1, #1
    mov     r4, r0
    add.w   r0, sp, #7
    strb.w  r8, [sp, #7]
    bl      rand_mask
    ldrb.w  r7, [sp, #7]
    ldrb.w  r5, [sp, #6]
    eor.w   r0, r7, r4
    mov     r1, r5
    uxtb    r0, r0
    bl      bf8_mul
    mov     r1, r7
    strb    r0, [r6, #0]
    mov     r0, r5
    bl      bf8_mul
    strb    r0, [r6, #1]
    add     sp, #8
    ldmia.w sp!, {r4, r5, r6, r7, r8, pc}
