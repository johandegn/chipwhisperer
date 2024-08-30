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

#include "hal.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "simpleserial.h"
#include "randombytes.h"

#define SECRET_SIZE 32
unsigned char secret[SECRET_SIZE] = {0};

static uint8_t get_secret(uint8_t* m, uint8_t inputLen) {
    simpleserial_put('a', SECRET_SIZE, secret);
    return 0;
}

static uint8_t set_secret(uint8_t* m, uint8_t inputLen) {
    memcpy(secret, m, inputLen);
    return 0;
}

static uint8_t gen_secret(uint8_t *m, uint8_t len) {
    randombytes(secret, SECRET_SIZE);
    return 0;
}


void pipeline_test1(uint8_t, uint8_t);
void pipeline_test2(uint8_t, uint8_t);
void pipeline_test3(uint8_t, uint8_t);
void pipeline_test4(uint8_t, uint8_t);

static void pipeline_test_fun(void) {
    uint8_t mask;
    randombytes(&mask, 1);
    uint8_t shares[2] = {mask, secret[0] ^ mask};
    trigger_high();
    pipeline_test1(shares[0], shares[1]);
    trigger_low();
}

void store_store_b_test(uint8_t, uint8_t, uint8_t *, uint8_t *);

static void store_store_b_test_fun(void) {
    uint8_t mask;
    randombytes(&mask, 1);
    uint8_t shares[2] = {mask, secret[0] ^ mask};
    uint8_t result[2] = {0, 0};
    trigger_high();
    store_store_b_test(shares[0], shares[1], result, result + 1);
    trigger_low();
}

void load_load_test(uint32_t, uint32_t, uint32_t *, uint32_t *);
static void load_load_test_fun(void) {
    uint32_t mask;
    randombytes(((uint8_t *)(&mask)) + 0, 1);
    randombytes(((uint8_t *)(&mask)) + 1, 1);
    randombytes(((uint8_t *)(&mask)) + 2, 1);
    randombytes(((uint8_t *)(&mask)) + 3, 1);
    uint32_t shares[2] = {mask, secret[0] ^ mask};
    trigger_high();
    load_load_test(0, 0, shares, shares + 1);
    trigger_low();
}

void load_load_b_test(uint8_t, uint8_t, uint8_t *, uint8_t *);
static void load_load_b_test_fun(void) {
    uint8_t mask;
    randombytes(&mask, 1);
    uint8_t shares[2] = {mask, secret[0] ^ mask};
    trigger_high();
    load_load_b_test(0, 0, shares, shares + 1);
    trigger_low();
}

void load_store_b_test(uint8_t, uint8_t, uint8_t *, uint8_t *);
static void load_store_b_test_fun(void) {
    uint8_t mask;
    randombytes(&mask, 1);
    uint8_t shares[2] = {mask, secret[0] ^ mask};
    trigger_high();
    load_store_b_test(0, shares[1], shares, shares + 1);
    trigger_low();
}

void store_load_b_test(uint8_t, uint8_t, uint8_t *, uint8_t *);
static void store_load_b_test_fun(void) {
    uint8_t mask;
    randombytes(&mask, 1);
    uint8_t shares[2] = {mask, secret[0] ^ mask};
    trigger_high();
    store_load_b_test(shares[0], 0, shares, shares + 1);
    trigger_low();
}

static uint8_t test(uint8_t *m, uint8_t len) {
    //pipeline_test_fun();
    //store_store_b_test_fun();
    load_load_test_fun();
    //load_load_b_test_fun();
    //load_store_b_test_fun();
    //store_load_b_test_fun();

    return 0;
}


int main(void) {
    platform_init();
    init_uart();
    trigger_setup();
        
    gen_secret(0, 0);

    simpleserial_init();

    simpleserial_addcmd('a', 0, get_secret);
    simpleserial_addcmd('b', 32, set_secret);
    simpleserial_addcmd('c', 0, gen_secret);

    simpleserial_addcmd('t', 0, test);

    while (1)
        simpleserial_get();
}
