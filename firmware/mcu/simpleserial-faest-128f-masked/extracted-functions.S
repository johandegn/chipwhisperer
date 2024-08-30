.syntax unified
.thumb

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
    stmdb   sp!, {r4, r5, r6, r7, r8, r9, lr}
    sub     sp, #28
    mov     r4, r0
    mov     r8, r1
    movs    r7, #0
    strh.w  r7, [sp, #16]
    strh.w  r7, [sp, #12]
    add     r6, sp, #20
    mov     r1, r6
    bl      bf8_square_masked
    mov     r0, r6
    bl      bf8_refresh
    add.w   r9, sp, #16
    mov     r2, r9
    mov     r1, r6
    mov     r0, r4
    bl      bf8_mul_masked
    add     r5, sp, #12
    mov     r1, r5
    mov     r0, r9
    bl      bf8_square_masked
    mov     r1, r5
    mov     r0, r5
    bl      bf8_square_masked
    mov     r0, r5
    bl      bf8_refresh
    strh.w  r7, [sp, #8]
    add     r4, sp, #8
    mov     r2, r4
    mov     r1, r9
    mov     r0, r5
    bl      bf8_mul_masked
    mov     r1, r4
    mov     r0, r4
    bl      bf8_square_masked
    mov     r1, r4
    mov     r0, r4
    bl      bf8_square_masked
    mov     r1, r4
    mov     r0, r4
    bl      bf8_square_masked
    mov     r1, r4
    mov     r0, r4
    bl      bf8_square_masked
    strh.w  r7, [sp, #4]
    add     r7, sp, #4
    mov     r2, r7
    mov     r1, r4
    mov     r0, r5
    bl      bf8_mul_masked
    mov     r2, r8
    mov     r1, r7
    mov     r0, r6
    bl      bf8_mul_masked
    add     sp, #28
    ldmia.w sp!, {r4, r5, r6, r7, r8, r9, pc}
