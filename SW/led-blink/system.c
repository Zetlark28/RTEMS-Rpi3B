#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_SIMPLE_CONSOLE_DRIVER
#define CONFIGURE_MICROSECONDS_PER_TICK   1000000

#define CONFIGURE_MAXIMUM_TASKS             2
#define CONFIGURE_RTEMS_INIT_TASKS_TABLE
#define UNLIMITED_OBJECTS
#define CONFIGURE_UNIFIED_WORK_AREAS

#define CONFIGURE_INIT
#include <rtems/confdefs.h>

