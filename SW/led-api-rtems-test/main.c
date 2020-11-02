#include <rtems.h>
#include <bsp/mmu.h>
#include <bsp/raspberrypi.h>
#include <bsp/gpio.h>
#include <bsp/rpi-gpio.h>
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>

rtems_task Init(rtems_task_argument argument){

  void *bsp_spec;
  rtems_interval  seconds = 1 * rtems_clock_get_ticks_per_second();
  rtems_gpio_initialize();
  rtems_gpio_bsp_select_input(0, 4, &bsp_spec);
  rtems_gpio_bsp_select_output(0, 4, &bsp_spec);

  printf("***START TEST*** \n");
  fflush(stdout);

  while(1){

	  if(rtems_gpio_bsp_get_value(0, 4)){
		  rtems_gpio_bsp_clear(0,4);
	  }else{
		  rtems_gpio_bsp_set(0,4);
	  }
	  rtems_task_wake_after(seconds);
  }

  //should never reach here
  printf("***FINISH TEST***\n");
  fflush(stdout);
  exit(0);
}
