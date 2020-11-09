/*
 * init.c
 *
 *  Created on: 9 nov 2020
 *      Author: clark
 */


#include "init.h"
#include "task_helper.h"

rtems_task generic_handler_task(rtems_task_argument arg);

rtems_task Init(rtems_task_argument ignored){
rtems_gpio_initialize();
rtems_gpio_bsp_select_input(0,4, &bsp_specific);
rtems_gpio_bsp_set_resistor_mode(0, 4, PULL_DOWN);
rtems_gpio_bsp_enable_interrupt(0, 4, RISING_EDGE);
rtems_gpio_interrupt_handler_install(4, generic_handler_task, 0);


}

rtems_task generic_handler_task(rtems_task_argument arg){



}
