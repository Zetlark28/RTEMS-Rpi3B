#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>
#include <inttypes.h>
#include <bsp/raspberrypi.h>
#include "led.h"

rtems_task Init(rtems_task_argument argument){
  printf( "\n\n*** LED (GPIO15) ON ***" );
  fflush(stdout);
  LED_INIT();
  LED_ON();
  exit(0);
}
