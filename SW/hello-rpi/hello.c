/*
 * Hello world example
 */
#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>

rtems_task Init(rtems_task_argument ignored) {
	printf("\n\n*** HELLO WORLD TEST ***\n");
	printf("Hello World\n");
	printf("*** END OF HELLO WORLD TEST ***\n");
	exit(0);
}
