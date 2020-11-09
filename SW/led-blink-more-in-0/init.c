
#include "init.h"
#include "task_helper.h"

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



