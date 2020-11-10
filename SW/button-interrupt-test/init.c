/*
 * init.c
 *
 *  Created on: 9 nov 2020
 *      Author: clark
 */


#include "init.h"
#include "task_helper.h"

rtems_gpio_irq_state button_handler(void *arg);

rtems_task Init(rtems_task_argument ignored){

rtems_interval  seconds = 5 * rtems_clock_get_ticks_per_second();

rtems_gpio_initialize();
rtems_gpio_bsp_select_input(0,4, &bsp_specific);
rtems_gpio_bsp_select_output(0,4,&bsp_specific);
rtems_gpio_bsp_set_resistor_mode(0, 4, PULL_DOWN);
//rtems_gpio_bsp_enable_interrupt(0, 4, RISING_EDGE);
//rtems_gpio_debounce_switch(4, rtems_clock_get_ticks_per_second()/10);
//rtems_gpio_interrupt_handler_install(4, button_handler, 0);

printf("GPIO configured");
fflush(stdout);

//polling
while(1){
	  if(rtems_gpio_bsp_get_value(0, 4)){
		  printf("1");

		  }else{
			  printf("0");
		  }
	fflush(stdout);
	rtems_task_wake_after(seconds);
}
printf("FINISH");
fflush(stdout);
exit(0);
}

rtems_gpio_irq_state button_handler(void *arg){
	printf("button pressed");
	fflush(stdout);
	return IRQ_HANDLED;
}
