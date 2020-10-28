#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>
#include <inttypes.h>
#include <bsp/raspberrypi.h>
#include "led.h"

rtems_task Init(rtems_task_argument argument){
  printf("***START TEST*** \n");
  fflush(stdout);
  rtems_interval  seconds = 1 * rtems_clock_get_ticks_per_second();
  LED_INIT(4);
  LED_ON(4);
  rtems_task_wake_after(seconds);
  LED_OFF(4);
  rtems_task_wake_after(seconds);
  LED_ON(4);
  rtems_task_wake_after(seconds);
  LED_OFF(4);
  printf("***FINISH TEST***\n");
  fflush(stdout);
  rtems_task_wake_after(seconds);
  exit(0);
}
