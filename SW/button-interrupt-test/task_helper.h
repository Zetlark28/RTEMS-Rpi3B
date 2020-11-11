/*
 * task_helper.h
 *
 *  Created on: 9 nov 2020
 *      Author: clark
 */

#ifndef TASK_HELPER_H_
#define TASK_HELPER_H_
#include <bsp.h>
#include <bsp/raspberrypi.h>
#include <bsp/irq.h>
#include <bsp/irq-generic.h>
#include <bsp/gpio.h>
#include <bsp/rpi-gpio.h>
#include <bsp/linker-symbols.h>
#include <bsp/mmu.h>
#include <rtems.h>
#include <rtems/score/armv4.h>
#include <rtems/bspIo.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>


void *bsp_specific;

#endif /* TASK_HELPER_H_ */
