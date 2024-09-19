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

    mov     r1, #5000
    mov     r3, sp
clean_call_loop:
    str     r0, [r3, #-4]!
    subs    r1, r1, #1
    bne     clean_call_loop

    mov     r1, #0
    mov     r3, #0

    bl      sign

    mov    r0, #0
    pop    {r4, r5, r6, r7, r8, r9, r10, pc}


.global compute_sbox_masked
compute_sbox_masked:
    push    {r3, r4, r5, lr}
    sub     sp, #4
    mov     r6, #0
    str     r6, [sp]

    mov     r5, r2
    mov     r4, r3
    bl      bf8_inv_masked
    
    strh    r6, [sp]    //CLEAR
    mov     r3, #0      //CLEAR
    mov     r0, r6      //CLEAR
    ldrb    r1, [sp]    //CLEAR

    ldrb    r0, [r5]
    bl      affine
    strb    r0, [r5]
    
    strh    r6, [sp]    //CLEAR
    mov     r3, #0      //CLEAR
    mov     r0, r6      //CLEAR
    ldrb    r1, [sp]    //CLEAR

    ldrb    r0, [r4]
    bl      affine_incomplete
    strb    r0, [r4]

    strh    r6, [sp]    //CLEAR
    mov     r3, #0      //CLEAR
    mov     r0, r6      //CLEAR
    ldrb    r1, [sp]    //CLEAR

    add     sp, #4
    pop     {r3, r4, r5, pc}


.global aes_extend_witness_masked_output
aes_extend_witness_masked_output:
    adds    r2, #7
    lsrs    r2, r2, #3
    beq.n   aes_extend_witness_masked_output_early_return
    push    {r4, r5, lr}
    adds    r5, r0, r2
    add.w   ip, r0, #4294967295     @ 0xffffffff
    add.w   lr, r0, r2, lsl #1
    mov     r3, r5
aes_extend_witness_masked_output_loop: 
    ldr     r4, [r1, #0]
    subs    r2, r3, r5
    ldrb    r4, [r4, r2]
    strb.w  r4, [ip, #1]!
    ldr     r4, [r1, #4]
    ldrb    r2, [r4, r2]
    strb.w  r2, [r3], #1
    cmp     r3, lr
    bne.n   aes_extend_witness_masked_output_loop
    pop     {r4, r5, pc}
aes_extend_witness_masked_output_early_return:
    bx      lr
