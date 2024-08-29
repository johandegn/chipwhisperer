.syntax unified
.thumb

.global pipeline_test
pipeline_test:
    push    {r4, r5, lr}
    bl      trigger_high
    eor     r4, r4, r4      // Clear (also pipeline)
    eor     r5, r5, r5      // Clear (also pipeline)
    and     r4, r2, r0      // here we suspect that the pipeline is leaking
    orr     r5, r3, r1      // r1 will overwrite r0 in the pipeline leading to HD leakage
    bl      trigger_low
    pop     {r4, r5, pc}
