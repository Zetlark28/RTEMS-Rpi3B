#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>
#include <inttypes.h>
#include <bsp/raspberrypi.h>
#include "led.h"
#include "tmacros.h"

rtems_id   Task_id[3];         /* array of task ids */
rtems_name Task_name[3];       /* array of task names */

rtems_task Led_on(rtems_task_argument task_index){
	rtems_interval ticks;

	ticks = rtems_clock_get_ticks_per_second();
	for(;;){
		put_name(Task_name[task_index], FALSE);
		LED_ON(4);
		(void) rtems_task_wake_after( ticks );
	}
}

rtems_task Led_off(rtems_task_argument task_index){
	rtems_interval ticks;

	ticks = rtems_clock_get_ticks_per_second();
	for(;;){
		put_name(Task_name[task_index], FALSE);
		LED_OFF(4);
		(void) rtems_task_wake_after( ticks );
	}
}
rtems_task Init(rtems_task_argument argument){

  Task_name[1] = rtems_build_name('L','D','O','F');
  Task_name[2] = rtems_build_name('L','D','O','N');
  LED_INIT(4);

  (void) rtems_task_create(
      Task_name[ 1 ], 1, RTEMS_MINIMUM_STACK_SIZE * 2, RTEMS_DEFAULT_MODES,
      RTEMS_DEFAULT_ATTRIBUTES, &Task_id[ 1 ]
    );
  (void) rtems_task_create(
     Task_name[ 2 ], 1, RTEMS_MINIMUM_STACK_SIZE * 2, RTEMS_DEFAULT_MODES,
     RTEMS_DEFAULT_ATTRIBUTES, &Task_id[ 2 ]
   );
  while(1){
  (void) rtems_task_start( Task_id[ 1 ], Led_off, 1 );
  (void) rtems_task_start( Task_id[ 2 ], Led_on, 2 );
  }
}
