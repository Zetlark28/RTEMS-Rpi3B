/*
 *  COPYRIGHT (c) 1989-2009.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 */

#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>
#include <inttypes.h>
#include <bsp/raspberrypi.h>
#include "led.h"

volatile char led;

rtems_task blink(rtems_task_argument argument);

rtems_task Init(rtems_task_argument ignored){
  rtems_id          tid;
  rtems_status_code status;
  rtems_name        name;

  name = rtems_build_name( 'A', 'P', 'P', '1' );

  status = rtems_task_create(
     name, 1, RTEMS_MINIMUM_STACK_SIZE,
     RTEMS_NO_PREEMPT, RTEMS_FLOATING_POINT, &tid);
  if ( status != RTEMS_SUCCESSFUL ) {
    printf( "rtems_task_create failed with status of %d.\n", status );
    fflush(stdout);
    exit( 1 );
  }

  printf( "\n\n*** LED BLINKER (GPIO4) -- task wake after ***" );
  fflush(stdout);

  status = rtems_task_start( tid, blink, 0 );
  if ( status != RTEMS_SUCCESSFUL ) {
    printf( "rtems_task_start failed with status of %d.\n", status );
    fflush(stdout);
    exit( 1 );
  }

  status = rtems_task_delete( RTEMS_SELF );    /* should not return */
  printf( "rtems_task_delete returned with status of %d.\n", status );
  fflush(stdout);
  exit(1);
}


rtems_task blink(rtems_task_argument argument)
{
  /* application specific initialization goes here */
 printf( "\n blink task started: \n");
 fflush(stdout);
 rtems_interval    seconds;
 led = argument;
 LED_INIT(4);

 while ( 1 )  {
	 if (led){
	  LED_OFF(4); led = false;
	  putchar('0');
	 }
	 else{
	  LED_ON(4); led = true;
	  putchar('1');
	 }
 fflush(stdout);
 seconds = 2 * rtems_clock_get_ticks_per_second();
 rtems_task_wake_after(seconds );/* infinite loop */
  }
}
