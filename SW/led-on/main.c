#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>
#include <inttypes.h>
#include <bsp/raspberrypi.h>
#include "led.h"

rtems_task Init(rtems_task_argument argument){
  printf( "\n\n*** LED (GPIO4) ON ***" );
  fflush(stdout);
  LED_INIT(4);
  LED_ON(4);
  printf("\n\n *** FINISH TEST  *** ");
  fflush(stdout);
  exit(0);
}
