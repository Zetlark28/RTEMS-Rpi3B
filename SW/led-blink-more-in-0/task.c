/*
 * task.c
 *
 *  Created on: 2 nov 2020
 *      Author: clark
 */
#include <rtems.h>
#include <bsp/mmu.h>
#include <bsp/raspberrypi.h>
#include <bsp/gpio.h>
#include <bsp/rpi-gpio.h>
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>
#include "task.h"

void *bsp_spec;

rtems_id          tid_1;
rtems_id          tid_2;
rtems_status_code status_1;
rtems_status_code status_2;

rtems_task Blink_GPIO_1(rtems_task_argument argument);
rtems_task Blink_GPIO_2(rtems_task_argument argument);
void initialize_GPIO();

rtems_task Init(rtems_task_argument argument){

  rtems_name        name_1;
  rtems_name        name_2;

  name_1 = rtems_build_name( 'L', 'D', '0', '1' );
  name_2 = rtems_build_name( 'L', 'D', '0', '2' );

  status_1= rtems_task_create(
       name_1, 2, RTEMS_MINIMUM_STACK_SIZE,
       RTEMS_NO_PREEMPT, RTEMS_FLOATING_POINT, &tid_1);
    if ( status_1!= RTEMS_SUCCESSFUL ) {
      printf( "rtems_task_create failed with status of %d.\n", status_1);
      fflush(stdout);
      exit( 1 );
    }

   status_2= rtems_task_create(
        name_2, 1, RTEMS_MINIMUM_STACK_SIZE,
        RTEMS_NO_PREEMPT, RTEMS_FLOATING_POINT, &tid_2);
    if ( status_1!= RTEMS_SUCCESSFUL ) {
      printf( "rtems_task_create failed with status of %d.\n", status_2);
      fflush(stdout);
      exit( 1 );
    }

  printf("***START TEST*** \n");
  fflush(stdout);

  status_1 = rtems_task_start( tid_1, Blink_GPIO_1, 0 );
    if ( status_1 != RTEMS_SUCCESSFUL ) {
      printf( "rtems_task_start failed with status of %d.\n", status_1 );
      fflush(stdout);
      exit( 1 );
    }

  //should never reach here
  printf("***FINISH TEST***\n");
  fflush(stdout);
  exit(0);
}

rtems_task Blink_GPIO_1(rtems_task_argument argument){
	rtems_interval seconds = 5 * rtems_clock_get_ticks_per_second();
	  while(1){
		  if(rtems_gpio_bsp_get_value(0, 4)){
			  rtems_gpio_bsp_clear(0,4);
		  }else{
			  status_2 = rtems_task_start( tid_2, Blink_GPIO_2, 0 );
			    if ( status_2 != RTEMS_SUCCESSFUL ) {
			      printf( "rtems_task_start failed with status of %d.\n", status_2 );
			      fflush(stdout);
			      exit( 1 );
			    }
			  rtems_gpio_bsp_set(0,4);
		  }
		  rtems_task_wake_after(seconds);
	  }

		printf("something wrong in blink_gpio_1");
		fflush(stdout);
		exit(1);
}

rtems_task Blink_GPIO_2(rtems_task_argument argument){
	rtems_interval seconds = 1 * rtems_clock_get_ticks_per_second();
	int count = 0;
		  while(1 && count<3){
			  if(rtems_gpio_bsp_get_value(0, 5)){
				  rtems_gpio_bsp_clear(0,5);
			  }else{

				  rtems_gpio_bsp_set(0,5);
			  }
			  count++;
			  rtems_task_wake_after(seconds);
		  }
	status_2 = rtems_task_start( tid_2, Blink_GPIO_2, 0 );
	if ( status_2 != RTEMS_SUCCESSFUL ) {
		printf( "rtems_task_start failed with status of %d.\n", status_2 );
		fflush(stdout);
		exit( 1 );
	}
	printf("something wrong in blink_gpio_2");
	fflush(stdout);
	exit(1);
}

void initialize_GPIO(){
  rtems_gpio_initialize();
  rtems_gpio_bsp_select_input(0, 4, &bsp_spec);
  rtems_gpio_bsp_select_output(0, 4, &bsp_spec);
  rtems_gpio_bsp_select_input(0, 5, &bsp_spec);
  rtems_gpio_bsp_select_output(0, 5, &bsp_spec);
}
