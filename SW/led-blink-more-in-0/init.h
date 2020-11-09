/*
 * task.h
 *
 *  Created on: 2 nov 2020
 *      Author: clark
 */



#ifndef TASK_H

#define TASK_H

#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_SIMPLE_CONSOLE_DRIVER
#define CONFIGURE_MICROSECONDS_PER_TICK   1000000
#define CONFIGURE_INIT_TASK_NAME rtems_build_name( 'L','D','T','1' )

#define CONFIGURE_UNLIMITED_OBJECTS
#define CONFIGURE_UNIFIED_WORK_AREAS
#define CONFIGURE_MAXIMUM_TASKS             3

#define CONFIGURE_RTEMS_INIT_TASKS_TABLE

#define CONFIGURE_INIT

#include <rtems/confdefs.h>
#endif
