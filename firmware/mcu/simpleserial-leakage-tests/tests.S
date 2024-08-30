.syntax unified
.thumb

.global pipeline_test
pipeline_test:
    push    {r4, r5, lr}
    eor     r2, r2, r0
    eor     r3, r3, r1
    pop     {r4, r5, pc}
