/*
    This file is part of the ChipWhisperer Example Targets
    Copyright (C) 2012-2017 NewAE Technology Inc.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "api.h"
#include "parameters.h"
#include "faest_128f.h"
#include "fields.h"
#include "hal.h"
#include "randomness.h"
#include "simpleserial.h"

unsigned char pk[CRYPTO_PUBLICKEYBYTES] = {0};
unsigned char sk[CRYPTO_SECRETKEYBYTES] = {0};
unsigned char sig[FAEST_128F_SIGNATURE_SIZE] = {0};
#define msg_size 16
unsigned char msg[msg_size] = {0};

static uint8_t get_pk(uint8_t* m, uint8_t inputLen) {
    simpleserial_put('p', CRYPTO_PUBLICKEYBYTES, pk);
    return 0;
}

static uint8_t get_sk(uint8_t* m, uint8_t inputLen) {
    simpleserial_put('k', CRYPTO_SECRETKEYBYTES, sk);
    return 0;
}

static uint8_t set_sk(uint8_t* m, uint8_t inputLen) {
    memcpy(sk, m, inputLen);
    return 0;
}

static uint8_t get_msg(uint8_t* m, uint8_t len) {
    simpleserial_put('m', msg_size, msg);
    return 0;
}

static uint8_t key_gen(uint8_t* m, uint8_t len) {
    int res = faest_128f_keygen(pk, sk);
    return res;
    //rand_bytes(&sk[0], CRYPTO_SECRETKEYBYTES);
    /*
    for (unsigned int i = 0; i < CRYPTO_SECRETKEYBYTES; i++) {
        do {
            rand_bytes(sk + i, 1);
        } while (sk[i] == 0);
    }
    return 0;
    */
}

static uint8_t msg_gen(uint8_t* m, uint8_t len) {
    rand_bytes(msg, msg_size);
    return 0;
}

extern uint8_t clean_call(uint8_t* m, uint8_t len);

uint8_t clean_call_wrapper(uint8_t* m, uint8_t len) {
    clean_call(m, len);
    return 0;
}


uint8_t sign() {
    /* inv_masked
    bf8_t in_share[2] = {msg[0], 0};
    in_share[1] = in_share[0] ^ sk[16+12 + 0];
    bf8_t out_share[2] = {0, 0};
    // arm assembly to set r2 and r3 to 0
    trigger_high();
    bf8_inv_masked(in_share, out_share);
    trigger_low();
    */

    /* sbox_masked
    bf8_t in_share[2] = {msg[0], 0};
    in_share[1] = in_share[0] ^ sk[16+12 + 0];
    bf8_t out_share[2] = {0, 0};
    trigger_high();
    compute_sbox_masked(in_share, out_share);
    trigger_low();
    */

    /* sub_words_masked
    bf8_t words[8] = {msg[0], msg[1], msg[2], msg[3], msg[0] ^ sk[16+12 + 0], msg[1] ^ sk[16+12 + 1], msg[2] ^ sk[16+12 + 2], msg[3] ^ sk[16+12 + 3]};
    trigger_high();
    sub_words_masked(words);
    trigger_low();
    */
   
    /* sub_bytes_masked
#define AES_BLOCK_WORDS 4
    aes_block_t state_share[2] = {0};
    //load_state(state_share[0], msg, AES_BLOCK_WORDS);
    //memcpy(state_share[0], msg, 16);
    for (unsigned int c = 0; c < AES_BLOCK_WORDS; c++) {
        for (unsigned int r = 0; r < AES_NR; r++) {
            state_share[0][c][r] = msg[c * AES_NR + r];
            state_share[1][c][r] = state_share[0][c][r] ^ (sk[c * AES_NR + r]);
        }
    }
    trigger_high();
    sub_bytes_masked(state_share, AES_BLOCK_WORDS);
    trigger_low();
    */


    /* sign with randomness
    size_t sig_size = FAEST_128F_SIGNATURE_SIZE;
    //trigger_high();
    int res = faest_128f_sign(sk, msg, msg_size, sig, &sig_size);
    //trigger_low();
    return res;
    */

    size_t sig_size = FAEST_128F_SIGNATURE_SIZE;
    uint8_t rho[FAEST_128F_LAMBDA / 8];
    memset(rho, 0, sizeof(rho));
    int res = faest_128f_sign_with_randomness(sk, msg, msg_size, rho, sizeof(rho), sig, &sig_size);
    return res;

    return 0;
}

int main(void) {
    platform_init();
    init_uart();
    trigger_setup();

    key_gen(0, 0);

    simpleserial_init();

    simpleserial_addcmd('p', 0, get_pk);
    simpleserial_addcmd('k', 0, get_sk);
    simpleserial_addcmd('q', 32, set_sk);
    simpleserial_addcmd('m', 0, get_msg);

    simpleserial_addcmd('g', 0, key_gen);
    simpleserial_addcmd('r', 0, msg_gen);
    simpleserial_addcmd('s', 0, clean_call_wrapper);
    /*
    //Reserved simpleserial commands: 'v', 'y', 'w'
    simpleserial_addcmd('e', 0, encrypt);
    simpleserial_addcmd('d', 0, decrypt);

    simpleserial_addcmd('r', 0, reset_counter);

    simpleserial_addcmd('c', 0, get_ct);
    simpleserial_addcmd('i', 0, get_plaintext_input);
    simpleserial_addcmd('o', 0, get_plaintext_output);
    */

    while (1)
        simpleserial_get();
}
