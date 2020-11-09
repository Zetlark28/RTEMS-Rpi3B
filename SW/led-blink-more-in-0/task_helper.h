/*
 * task_helper.h
 *
 *  Created on: 2 nov 2020
 *      Author: clark
 */

#ifndef TASK_HELPER_H_
#define TASK_HELPER_H_
#include <rtems.h>
#include <bsp/mmu.h>
#include <bsp/raspberrypi.h>
#include <bsp/gpio.h>
#include <bsp/rpi-gpio.h>
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>
rtems_task blink_1(rtems_task_argument argument);
rtems_task blink_2(rtems_task_argument argument);

rtems_id          tid_2;
rtems_status_code status_2;
rtems_name        name_2;
rtems_id          tid_1;
rtems_status_code status_1;
rtems_name        name_1;

#endif /* TASK_HELPER_H_ */
