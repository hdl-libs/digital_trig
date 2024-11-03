// ---------------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ---------------------------------------------------------------------------------------

/**
 * @file digital_trig.h
 * @brief
 * @author
 */

#ifndef _DIGITAL_TRIG_H_
#define _DIGITAL_TRIG_H_

/******************************************************************************/
/************************ Include Files ***************************************/
/******************************************************************************/

#include <stdbool.h>
#include <stdint.h>

/******************************************************************************/
/************************ Marco Definitions ***********************************/
/******************************************************************************/

/******************************************************************************/
/************************ Types Definitions ***********************************/
/******************************************************************************/

typedef enum digital_trig_polarity
{
    NONE = 0B00,
    RISING_EDGE = 0B01,
    FALLING_EDGE = 0B10,
    BOTH_EDGE = 0B11
} digital_trig_polarity;

typedef union digital_trig_ctrl_t
{
    struct
    {
        uint32_t cfg_trig_en : 1;   // bit 0
        uint32_t cfg_trig8_pol : 2; // bit 1:2
        uint32_t : 28;              // bit 3:30
        uint32_t reset : 1;         // bit 31
    };
    uint32_t all;
} digital_trig_ctrl_t;

typedef union digital_trig_status_t
{
    struct
    {
        uint32_t triged : 1;       // bit 0
        uint32_t : 15;             // bit 1:15
        uint32_t trig_detail : 16; // bit 16:31
    };
    uint32_t all;
} digital_trig_status_t;

typedef struct digital_trig_t
{
    uint32_t id;                 // 0x0000, RO
    uint32_t revision;           // 0x0004, RO
    uint32_t buildtime;          // 0x0008, RO
    uint32_t test;               // 0x000C, RW
    uint32_t symbol_width;       // 0x0010, RO
    uint32_t symbol_num;         // 0x0014, RO
    digital_trig_ctrl_t ctrl;    // 0x0018, RW
    digital_trig_status_t state; // 0x001C, RW
    uint32_t ut_uh;              // 0x0020, RW
    uint32_t ut_lh;              // 0x0024, RW
    uint32_t lt_uh;              // 0x0028, RW
    uint32_t lt_lh;              // 0x002C, RW
    uint32_t baseaddr;
} digital_trig_t;

/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/

extern int trig_init(digital_trig_t **dev_ptr, uint32_t base_addr);
extern int trig_deinit(digital_trig_t **dev_ptr);
extern int trig_enable(digital_trig_t *dev, uint32_t ut_uh, uint32_t ut_lh, uint32_t lt_uh, uint32_t lt_lh, digital_trig_polarity polarity);
extern int trig_disable(digital_trig_t *dev);

/******************************************************************************/
/************************ Variable Declarations *******************************/
/******************************************************************************/

#endif // _DIGITAL_TRIG_H_
