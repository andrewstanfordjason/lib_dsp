// Copyright (c) 2015-2017, XMOS Ltd, All rights reserved
// XMOS DSP Library - DCT Functions test program

#include <stdio.h>
#include <stdlib.h>
#include <xs1.h>
#include <xclib.h>
#include <dsp_bfp.h>

#define MAXN 64

dsp_complex_t inp[MAXN], outp[MAXN];

int br(int i, int N) {
    return bitrev(i << (clz(N)+1));
}


unsigned max(unsigned a, unsigned b) {
    return a > b ? a : b;
}

#define TRCHANS 3

void tx_ramp(chanend x, int advance) {
    int32_t [[aligned(8)]] data[16*TRCHANS];
    int cnt = 0;
    for(int i = 0; i < 4; i++) {
        for(int j = 0; j < advance; j++) {
            cnt ++;
            data[j] = cnt << i;
            data[j+advance] = (-cnt) << i;
            data[j+2*advance] = (cnt*cnt) << i;
        }
        dsp_bfp_tx_xc(x, data, TRCHANS, advance, i);
    }
}

void rx_ramp(chanend x, int advance) {
    int errors = 0;
    int32_t [[aligned(8)]] data[32*TRCHANS];
    uint64_t state[DSP_BFP_RX_STATE_UINT64_SIZE(TRCHANS, 32, 12)];
    dsp_bfp_rx_state_init_xc(state, DSP_BFP_RX_STATE_UINT64_SIZE(TRCHANS, 32, 12));
    int start = advance - 32 + 1;// -19;
    for(int i = 0; i < 4; i++) {
        int shr = dsp_bfp_rx_xc(x, state, data, TRCHANS, 32, advance, 1);
        for(int j = 0; j < 32; j++) {
            int rxed = data[j] >> shr;
            int expected = start + j;
            if (expected < 0) expected = 0;
            if (expected != rxed) {
                printf("Error: %2d not %2d (%d/%d) 0\n", rxed, expected, i, j);
                errors++;
            }
            rxed = data[j+32] >> shr;
            if (-expected != rxed) {
                printf("Error: %2d not %2d (%d/%d) 1\n", rxed, -expected, i, j);
                errors++;
            }
            rxed = data[j+64] >> shr;
            if (expected*expected != rxed) {
                printf("Error: %2d not %2d (%d/%d) 2\n", rxed, expected*expected, i, j);
                errors++;
            }
        }
        start += advance;
    }
    if (errors == 0) {
        printf("dsp_bfp_rx/tx(%d) passed\n", advance);
    } else {
        printf("dsp_bfp_rx/tx(%d) FAIL with %d errors\n", advance, errors);
    }
    
}

void test_tx_rx() {
    chan x;
    par {
        tx_ramp(x, 12);
        rx_ramp(x, 12);
    }
    par {
        tx_ramp(x, 16);
        rx_ramp(x, 16);
    }
}

int main(void) {
    int errors = 0;
    for(int N = 2; N <= 32; N++) {
        int maxv = 0;
        for(int i = 0; i < N; i++) {
            inp[i].re = (1 << i) - ((i >> 3) & 1);
            inp[i].im = -(1 << i) + 3 - ((i >> 3) & 1);
            if (i == 32) {
                inp[i].re = 0x80000000;
            }
            outp[i] = inp[i];
            unsigned ar = abs(inp[i].re);
            unsigned ai = abs(inp[i].im);
            maxv = max(max(ar, maxv), ai);
        }
        if (dsp_bfp_cls(inp, N) != clz(maxv)) {
            errors++;
            printf("Error: cls is %d not %d\n", dsp_bfp_cls(inp, N), clz(maxv));
        }
    }
    if (errors == 0) {
        printf("dsp_bfp_clz() passed\n");
    } else {
        printf("dsp_bfp_clz() FAIL with %d errors\n", errors);
    }
    
    for(int N = 2; N <= MAXN; N*=2) {
        errors = 0;
        for(int i = 0; i < N; i++) {
            inp[i].re = 1000 * i - 10000;
            inp[i].im = 1500 * i - 10000;
            outp[i] = inp[i];
        }

        dsp_bfp_bit_reverse_shl(outp, N, 5);
        for(int i = 0; i < N; i++) {
            if ((inp[br(i,N)].re << 5) != outp[i].re) {
                printf("Error dsp_bfp_bit_reverse_shl: re[%d] %d not %d\n", i, outp[i].re, inp[br(i,N)].re << 5);
                errors++;
            }
            if ((inp[br(i,N)].im << 5) != outp[i].im) {
                printf("Error dsp_bfp_bit_reverse_shl: im[%d] %d not %d\n", i, outp[i].im, inp[br(i,N)].im << 5);
                errors++;
            }
        }
        dsp_bfp_bit_reverse_shl(outp, N, -3);
        for(int i = 0; i < N; i++) {
            if ((inp[i].re << 2) != outp[i].re) {
                printf("Error dsp_bfp_bit_reverse_shl: re[%d] %d not %d\n", i, outp[i].re, inp[i].re << 2);
                errors++;
            }
            if ((inp[i].im << 2) != outp[i].im) {
                printf("Error dsp_bfp_bit_reverse_shl: im[%d] %d not %d\n", i, outp[i].im, inp[i].im << 2);
                errors++;
            }
        }
        dsp_bfp_shl(outp, N, -3);
        for(int i = 0; i < N; i++) {
            if ((inp[i].re >> 1) != outp[i].re) {
                printf("Error dsp_bfp_shl: re[%d] %d not %d\n", i, outp[i].re, inp[i].re << 2);
                errors++;
            }
            if ((inp[i].im >> 1) != outp[i].im) {
                printf("Error dsp_bfp_shl: im[%d] %d not %d\n", i, outp[i].im, inp[i].im << 2);
                errors++;
            }
        }
        dsp_bfp_shl(outp, N, 1);
        for(int i = 0; i < N; i++) {
            if ((inp[i].re << 0) != outp[i].re) {
                printf("Error dsp_bfp_shl: re[%d] %d not %d\n", i, outp[i].re, inp[i].re << 0);
                errors++;
            }
            if ((inp[i].im << 0) != outp[i].im) {
                printf("Error dsp_bfp_shl: im[%d] %d not %d\n", i, outp[i].im, inp[i].im << 0);
                errors++;
            }
        }
        dsp_bfp_shl2(outp, N, 3, 2);
        for(int i = 0; i < N; i++) {
            if ((inp[i].re << 3) != outp[i].re) {
                printf("Error dsp_bfp_shl: re[%d] %d not %d\n", i, outp[i].re, inp[i].re << 2);
                errors++;
            }
            if ((inp[i].im << 2) != outp[i].im) {
                printf("Error dsp_bfp_shl: im[%d] %d not %d\n", i, outp[i].im, inp[i].im << 2);
                errors++;
            }
        }
        dsp_bfp_shl2(outp, N, -1, 1);
        for(int i = 0; i < N; i++) {
            if ((inp[i].re << 2) != outp[i].re) {
                printf("Error dsp_bfp_shl: re[%d] %d not %d\n", i, outp[i].re, inp[i].re << 2);
                errors++;
            }
            if ((inp[i].im << 3) != outp[i].im) {
                printf("Error dsp_bfp_shl: im[%d] %d not %d\n", i, outp[i].im, inp[i].im << 2);
                errors++;
            }
        }
        dsp_bfp_shl2(outp, N, 1, -1);
        for(int i = 0; i < N; i++) {
            if ((inp[i].re << 3) != outp[i].re) {
                printf("Error dsp_bfp_shl: re[%d] %d not %d\n", i, outp[i].re, inp[i].re << 2);
                errors++;
            }
            if ((inp[i].im << 2) != outp[i].im) {
                printf("Error dsp_bfp_shl: im[%d] %d not %d\n", i, outp[i].im, inp[i].im << 2);
                errors++;
            }
        }
        dsp_bfp_shl2(outp, N, -3, -2);
        for(int i = 0; i < N; i++) {
            if ((inp[i].re << 0) != outp[i].re) {
                printf("Error dsp_bfp_shl: re[%d] %d not %d\n", i, outp[i].re, inp[i].re << 2);
                errors++;
            }
            if ((inp[i].im << 0) != outp[i].im) {
                printf("Error dsp_bfp_shl: im[%d] %d not %d\n", i, outp[i].im, inp[i].im << 2);
                errors++;
            }
        }
        if (errors == 0) {
            printf("dsp_bfp_...(..., %d, ...) passed\n", N);
        } else {
            printf("dsp_bfp_...(..., %d, ...) FAIL with %d errors\n", N, errors);
        }
    }
    test_tx_rx();
    return 0;
}

