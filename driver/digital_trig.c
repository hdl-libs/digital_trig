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

#include "digital_trig.h"
#include <stdlib.h>
#include "xil_io.h"

/**
 * @name trig_init
 * @brief create a new instance
 * @param dev_ptr the device instance pointer
 * @param base_addr base address of the instance
 * @return 0:success, others:fail
 */
int trig_init(digital_trig_t **dev_ptr, uint32_t base_addr)
{
    if (dev_ptr == NULL)
        return -1;

    digital_trig_t *dev = (digital_trig_t *)calloc(1, sizeof(digital_trig_t));

    if (NULL == dev)
        return -2;

    dev->baseaddr = base_addr;

    // soft reset
    dev->ctrl.reset = 1;
    Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, ctrl), dev->ctrl.all);

    // read write test
    {
        Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, test), 0x55555555);
        dev->test = Xil_In32(dev->baseaddr + offsetof(digital_trig_t, test));

        if (dev->test != 0x55555555)
            return -4;

        Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, test), 0xAAAAAAAA);
        dev->test = Xil_In32(dev->baseaddr + offsetof(digital_trig_t, test));

        if (dev->test != 0xAAAAAAAA)
            return -4;
    }

    // read instance info
    {
        dev->id = Xil_In32(dev->baseaddr + offsetof(digital_trig_t, id));

        if (dev->id != 0xF7DEC7A5)
            return -3;

        dev->revision = Xil_In32(dev->baseaddr + offsetof(digital_trig_t, revision));
        dev->buildtime = Xil_In32(dev->baseaddr + offsetof(digital_trig_t, buildtime));
    }

    *dev_ptr = dev;

    return 0;
}

/**
 * @name trig_deinit
 * @brief free resources malloced by the instance
 * @param dev_ptr the device instance pointer
 * @return 0:success, others:fail
 */
int trig_deinit(digital_trig_t **dev_ptr)
{
    if (dev_ptr == NULL)
        return -1;

    free(*dev_ptr);
    *dev_ptr = NULL;

    return 0;
}

/**
 * @name trig_enable
 * @brief set trig parameters and enable trig
 * @param dev the device instance
 * @param ut_uh  upper hystersis of upper threshold
 * @param ut_lh  lower hystersis of upper threshold
 * @param lt_uh  upper hystersis of lower threshold
 * @param lt_lh  lower hystersis of lower threshold
 * @note ut_uh >= ut_lh >= lt_uh >= lt_lh
 * @param polarity see digital_trig_polarity
 * @return 0:success, others:fail
 */
int trig_enable(digital_trig_t *dev, uint32_t ut_uh, uint32_t ut_lh, uint32_t lt_uh, uint32_t lt_lh, digital_trig_polarity polarity)
{
    if (dev == NULL)
        return -1;

    dev->ut_uh = ut_uh;
    dev->ut_lh = ut_lh;
    dev->lt_uh = lt_uh;
    dev->lt_lh = lt_lh;

    dev->ctrl.all = Xil_In32(dev->baseaddr + offsetof(digital_trig_t, ctrl));
    dev->ctrl.cfg_trig_en = 0;
    dev->ctrl.cfg_trig8_pol = polarity;
    Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, ctrl), dev->ctrl.all);

    Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, ut_uh), dev->ut_uh);
    Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, ut_lh), dev->ut_lh);
    Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, lt_uh), dev->lt_uh);
    Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, lt_lh), dev->lt_lh);

    dev->ctrl.cfg_trig_en = 1;
    Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, ctrl), dev->ctrl.all);

    return 0;
}

/**
 * @name trig_disable
 * @brief disable trig
 * @param dev the device instance
 * @return 0:success, others:fail
 */
int trig_disable(digital_trig_t *dev)
{
    if (dev == NULL)
        return -1;

    dev->ctrl.all = Xil_In32(dev->baseaddr + offsetof(digital_trig_t, ctrl));
    dev->ctrl.cfg_trig_en = 0;
    Xil_Out32(dev->baseaddr + offsetof(digital_trig_t, ctrl), dev->ctrl.all);

    return 0;
}
