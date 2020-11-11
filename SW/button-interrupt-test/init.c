/*
 * init.c
 *
 *  Created on: 9 nov 2020
 *      Author: clark
 */


#include "init.h"
#include "task_helper.h"

rtems_gpio_irq_state button_handler(void *arg);
void printToConsole(char string [15]);
rtems_task Init(rtems_task_argument ignored){

uint32_t pin = 7;

rtems_gpio_initialize();
rtems_gpio_bsp_select_input(0,pin, &bsp_specific);
rtems_gpio_bsp_select_output(0,pin,&bsp_specific);
//rtems_gpio_bsp_set_resistor_mode(0, 4, PULL_DOWN);
bsp_interrupt_initialize();

printToConsole("interrupt initialized \n");

rtems_status_code status = rtems_gpio_bsp_enable_interrupt(0, pin, RISING_EDGE);
if(status != RTEMS_SUCCESSFUL){
	exit(status);
}else {
	printToConsole("interrupt enabled\n");
}

//status = rtems_gpio_debounce_switch(pin, rtems_clock_get_ticks_per_second()/10);
//if(status != RTEMS_SUCCESSFUL){
//	exit(status);
//}else{
//	printToConsole("debounce function assigned");
//}

//TODO verify exit error 22 = RTEMS_NOT_CONFIGURED The given pin has no interrupt configured
status = rtems_gpio_interrupt_handler_install(pin, button_handler, 0);
if(status != RTEMS_SUCCESSFUL){
	exit(status);
}else{
	printToConsole("interrupt handler installed");
}

printf("GPIO configured \n");
fflush(stdout);

//rtems_interval  seconds = 5 * rtems_clock_get_ticks_per_second();
while(1){
	//polling test button reponse
//	  if(rtems_gpio_bsp_get_value(0, 4)){
//		  printf("1");
//
//		  }else{
//			  printf("0");
//		  }
//	fflush(stdout);
//	rtems_task_wake_after(seconds);
}
printf("FINISH");
fflush(stdout);
exit(0);
}

rtems_gpio_irq_state button_handler(void *arg){
	printToConsole("in handler\n");
	return IRQ_HANDLED;
}

void printToConsole(char string [30]){
	printf("%s",string);
	fflush(stdout);
	return;
}
