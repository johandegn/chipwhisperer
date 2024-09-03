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

.global bf8_inv_asm
bf8_inv_asm:
movs    r1, #0
stmdb   sp!, {r4, r5, r6, r7, r8, lr}
mov     r4, r0
mov     r5, r1
mul1:
asr.w   r2, r0, r5
sbfx    r3, r4, #7, #1
sxtb    r6, r4
sbfx    r2, r2, #0, #1
and.w   r3, r3, #27
adds    r5, #1
ands    r2, r4
eor.w   r3, r3, r6, lsl #1
cmp     r5, #7
eor.w   r1, r1, r2
uxtb    r4, r3
bne.n   mul1
sbfx    r3, r0, #7, #1
ands    r3, r4
eors    r1, r3
movs    r2, #0
uxtb    r1, r1
mov     r5, r2
 mul2:
asr.w   r4, r1, r5
sbfx    r3, r0, #7, #1
sxtb    r6, r0
sbfx    r4, r4, #0, #1
and.w   r3, r3, #27
adds    r5, #1
ands    r0, r4
eor.w   r3, r3, r6, lsl #1
cmp     r5, #7
eor.w   r2, r2, r0
uxtb    r0, r3
bne.n   mul2
sbfx    ip, r1, #7, #1
and.w   r0, r0, ip
eors    r2, r0
movs    r3, #0
uxtb    r2, r2
mov     r5, r3
 mul3:
asr.w   r4, r1, r5
sbfx    r0, r2, #7, #1
sxtb    r6, r2
sbfx    r4, r4, #0, #1
and.w   r0, r0, #27
adds    r5, #1
ands    r4, r2
cmp     r5, #7
eor.w   r2, r0, r6, lsl #1
eor.w   r3, r3, r4
uxtb    r2, r2
bne.n   mul3
and.w   r2, r2, ip
eors    r3, r2
mov.w   lr, #0
uxtb    r3, r3
mov     r4, lr
 mul4:
asr.w   r0, r1, r4
sbfx    r2, r3, #7, #1
sxtb    r5, r3
sbfx    r0, r0, #0, #1
and.w   r2, r2, #27
adds    r4, #1
ands    r0, r3
cmp     r4, #7
eor.w   r3, r2, r5, lsl #1
eor.w   lr, lr, r0
uxtb    r3, r3
bne.n   mul4
and.w   r3, r3, ip
eor.w   lr, lr, r3
uxtb.w  lr, lr
movs    r5, #0
mov     r0, lr
mov     r4, r5
 mul5:
asr.w   r2, lr, r4
sbfx    r3, r0, #7, #1
sxtb    r6, r0
sbfx    r2, r2, #0, #1
and.w   r3, r3, #27
adds    r4, #1
ands    r2, r0
eor.w   r3, r3, r6, lsl #1
cmp     r4, #7
eor.w   r5, r5, r2
uxtb    r0, r3
bne.n   mul5
sbfx    r4, lr, #7, #1
ands    r0, r4
eors    r5, r0
uxtb    r6, r5
movs    r0, #0
mov     r5, r6
mov     r7, r0
 mul6:
asr.w   r2, r6, r7
sbfx    r3, r5, #7, #1
sxtb.w  r8, r5
sbfx    r2, r2, #0, #1
and.w   r3, r3, #27
adds    r7, #1
ands    r2, r5
eor.w   r3, r3, r8, lsl #1
cmp     r7, #7
eor.w   r0, r0, r2
uxtb    r5, r3
bne.n   mul6
sbfx    r6, r6, #7, #1
ands    r6, r5
eors    r0, r6
uxtb    r5, r0
movs    r3, #0
mov     r6, r5
mov     r7, r3
 mul7:
asr.w   r0, r5, r7
sbfx    r2, r6, #7, #1
sxtb.w  r8, r6
sbfx    r0, r0, #0, #1
and.w   r2, r2, #27
adds    r7, #1
ands    r0, r6
eor.w   r2, r2, r8, lsl #1
cmp     r7, #7
eor.w   r3, r3, r0
uxtb    r6, r2
bne.n   mul7
sbfx    r5, r5, #7, #1
ands    r5, r6
eors    r3, r5
movs    r5, #0
uxtb    r3, r3
mov     r6, r5
 mul8:
asr.w   r0, lr, r6
sbfx    r2, r3, #7, #1
sxtb    r7, r3
sbfx    r0, r0, #0, #1
and.w   r2, r2, #27
adds    r6, #1
ands    r0, r3
cmp     r6, #7
eor.w   r3, r2, r7, lsl #1
eor.w   r5, r5, r0
uxtb    r3, r3
bne.n   mul8
ands    r3, r4
eors    r5, r3
uxtb    r5, r5
movs    r0, #0
mov     r4, r5
mov     r6, r0
 mul9:
asr.w   r2, r5, r6
sbfx    r3, r4, #7, #1
sxtb    r7, r4
sbfx    r2, r2, #0, #1
and.w   r3, r3, #27
adds    r6, #1
ands    r2, r4
eor.w   r3, r3, r7, lsl #1
cmp     r6, #7
eor.w   r0, r0, r2
uxtb    r4, r3
bne.n   mul9
sbfx    r5, r5, #7, #1
ands    r5, r4
eors    r0, r5
uxtb    r4, r0
movs    r3, #0
mov     r5, r4
mov     r6, r3
 mul10:
asr.w   r0, r4, r6
sbfx    r2, r5, #7, #1
sxtb    r7, r5
sbfx    r0, r0, #0, #1
and.w   r2, r2, #27
adds    r6, #1
ands    r0, r5
eor.w   r2, r2, r7, lsl #1
cmp     r6, #7
eor.w   r3, r3, r0
uxtb    r5, r2
bne.n   mul10
sbfx    r4, r4, #7, #1
ands    r4, r5
eors    r3, r4
movs    r0, #0
uxtb    r3, r3
mov     r4, r0
 mul11:
asr.w   lr, r1, r4
sbfx    r2, r3, #7, #1
sxtb    r5, r3
sbfx    lr, lr, #0, #1
and.w   r2, r2, #27
adds    r4, #1
and.w   lr, lr, r3
cmp     r4, #7
eor.w   r3, r2, r5, lsl #1
eor.w   r0, r0, lr
uxtb    r3, r3
bne.n   mul11
and.w   r3, r3, ip
eors    r0, r3
uxtb    r0, r0
ldmia.w sp!, {r4, r5, r6, r7, r8, pc}
nop