#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>
#include <inttypes.h>
#include <bsp/raspberrypi.h>
#include "led.h"

rtems_task Init(
  rtems_task_argument argument
)
{
  rtems_status_code status;

  printf( "\n\n*** LED BLINKER (GPIO4) -- task wake after ***" );

  LED_INIT();

  while (1) {

    (void) rtems_task_wake_after( 1 * rtems_clock_get_ticks_per_second() );
    LED_OFF(4);
    (void) rtems_task_wake_after( 1 * rtems_clock_get_ticks_per_second() );
    LED_ON(4);

  }

  status = rtems_task_delete( RTEMS_SELF );
}
