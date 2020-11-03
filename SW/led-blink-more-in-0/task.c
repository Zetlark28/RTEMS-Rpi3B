#include <rtems.h>
#include <bsp/mmu.h>
#include <bsp/raspberrypi.h>
#include <bsp/gpio.h>
#include <bsp/rpi-gpio.h>
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>

rtems_id          tid_2;
rtems_status_code status_2;
rtems_name        name_2;
rtems_id          tid_1;
rtems_status_code status_1;
rtems_name        name_1;

rtems_task blink_1(rtems_task_argument argument);
rtems_task blink_2(rtems_task_argument argument);

rtems_task Init(rtems_task_argument ignored){

  name_1 = rtems_build_name( 'A', 'P', 'P', '1' );

  name_2 = rtems_build_name( 'A', 'P', 'P', '2' );

  void *bsp_spec;

  rtems_gpio_initialize();
  rtems_gpio_bsp_select_input(0, 4, &bsp_spec);
  rtems_gpio_bsp_select_output(0, 4, &bsp_spec);
  rtems_gpio_bsp_select_input(0, 5, &bsp_spec);
  rtems_gpio_bsp_select_output(0, 5, &bsp_spec);

  status_1 = rtems_task_create(
     name_1, 1, RTEMS_MINIMUM_STACK_SIZE,
     RTEMS_NO_PREEMPT, RTEMS_FLOATING_POINT, &tid_1);
  if ( status_1 != RTEMS_SUCCESSFUL ) {
    printf( "rtems_task_create failed with status of %d.\n", status_1 );
    fflush(stdout);
    exit( 1 );
  }
  status_2 = rtems_task_create(
     name_2, 1, RTEMS_MINIMUM_STACK_SIZE,
     RTEMS_NO_PREEMPT, RTEMS_FLOATING_POINT, &tid_2);
  if ( status_1 != RTEMS_SUCCESSFUL ) {
    printf( "rtems_task_create failed with status of %d.\n", status_2);
    fflush(stdout);
    exit( 1 );
  }

  printf( "\n\n*** LED BLINKER (GPIO4) -- task wake after ***" );
  fflush(stdout);

  status_1 = rtems_task_start( tid_1, blink_1, 0 );
  if ( status_1 != RTEMS_SUCCESSFUL ) {
    printf( "rtems_task_start failed with status of %d.\n", status_1 );
    fflush(stdout);
    exit( 1 );
  }

  status_1 = rtems_task_delete( RTEMS_SELF );    /* should not return */
  printf( "rtems_task_delete returned with status of %d.\n", status_1 );
  fflush(stdout);
  exit(1);
}


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

