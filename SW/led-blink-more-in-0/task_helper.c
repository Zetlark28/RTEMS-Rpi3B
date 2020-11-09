/*
 * task_helper.c
 *
 *  Created on: 2 nov 2020
 *      Author: clark
 */

#include "task_helper.h"

rtems_task blink_1(rtems_task_argument argument)
{
  /* application specific initialization goes here */

 rtems_interval  seconds = 3 * rtems_clock_get_ticks_per_second();

 printf( "\n blink task started: \n");

 while(1){
	 printf("1");
	 fflush(stdout);
	  if(rtems_gpio_bsp_get_value(0, 4)){
		  rtems_gpio_bsp_clear(0,4);
	  }else{
		  rtems_gpio_bsp_set(0,4);
		  status_2 = rtems_task_restart( tid_2, 0 );
		   if ( status_2 == RTEMS_INCORRECT_STATE ) {
		     rtems_task_start(tid_2,blink_2,0);
		   }
		   rtems_task_suspend(tid_1);
	  }
	  rtems_task_wake_after(seconds);
 }
}

rtems_task blink_2(rtems_task_argument argument)
{
  /* application specific initialization goes here */
//	rtems_task_suspend(tid_1);
if(rtems_task_is_suspended(tid_1)){
	printf("blink1 suspended \n");
	fflush(stdout);
}
rtems_interval  seconds = 1 * rtems_clock_get_ticks_per_second();

 printf( "\n blink 2 task started: \n");
fflush(stdout);
 int count = 0;
 while(1 && count<3){
	 printf("2");
	 fflush(stdout);
	  if(rtems_gpio_bsp_get_value(0, 5)){
		  rtems_gpio_bsp_clear(0,5);
	  }else{
		  rtems_gpio_bsp_set(0,5);
		  count++;
	  }
	  if(count>=3){
		 printf( "\n Finish blink 2 task \n");
		 fflush(stdout);
		 rtems_task_restart(tid_1,1);
		 rtems_task_suspend(tid_2);
	  }
	  rtems_task_wake_after(seconds);
 }
}

