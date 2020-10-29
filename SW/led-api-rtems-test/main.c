#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>
#include <inttypes.h>
#include <bsp/raspberrypi.h>
#include <bsp/gpio.h>
#include <bsp/rpi-gpio.h>
#include "led.h"

rtems_task Init(rtems_task_argument argument){

  printf("***START TEST*** \n");
  fflush(stdout);
  bsp_start();
  rtems_interval  seconds = 1 * rtems_clock_get_ticks_per_second();
  rtems_gpio_initialize();
  rtems_task_wake_after(seconds);
  rtems_gpio_bsp_clear(0,4);
  rtems_task_wake_after(seconds);
  rtems_gpio_bsp_set(0,4);
  rtems_task_wake_after(seconds);
  rtems_gpio_bsp_clear(0,4);
  printf("***FINISH TEST***\n");
  fflush(stdout);
  rtems_task_wake_after(seconds);
  exit(0);
}
