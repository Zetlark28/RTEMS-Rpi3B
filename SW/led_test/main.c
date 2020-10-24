#include <rtems.h>
#include <stdlib.h>
#include <stdio.h>
#include <bsp/mmu.h>
#include <inttypes.h>
#include <raspberrypi.h>
#include "system.h"
#include "led.h"

rtems_task Test_task(
        rtems_task_argument unused
)
{
    rtems_event_set events;

    for ( ; ; ) {
        events = 0;
        (void) rtems_event_receive(
                (RTEMS_EVENT_1 | RTEMS_EVENT_2),
                RTEMS_EVENT_ANY,
                RTEMS_NO_TIMEOUT,
                &events
        );

        if ( events == RTEMS_EVENT_1 ) {
            LED_OFF();
        } else if ( events == RTEMS_EVENT_2 ) {
            LED_ON();
        } else {
            fprintf( stderr, "Incorrect event set 0x%08" PRIx32 "\n", events );
        }
    }
}

rtems_task Init(
        rtems_task_argument argument
)
{
    uint32_t          count = 0;
    rtems_event_set   events;
    rtems_status_code status;
    rtems_id          task_id;
    rtems_name        task_name;

    puts( "\n\n*** LED BLINKER -- event receive server ***" );

    LED_INIT();

    task_name = rtems_build_name( 'T', 'A', '1', ' ' );

    (void) rtems_task_create(
            task_name, 1, RTEMS_MINIMUM_STACK_SIZE * 2, RTEMS_DEFAULT_MODES,
            RTEMS_DEFAULT_ATTRIBUTES, &task_id
    );

    (void) rtems_task_start( task_id, Test_task, 1 );

    for (count=0; ; count++) {

        events = ( (count % 2) == 0 ) ?  RTEMS_EVENT_1 : RTEMS_EVENT_2;
        status = rtems_event_send( task_id, events );
        if ( status != RTEMS_SUCCESSFUL )
            fputs( "send did not work\n", stderr );

        (void) rtems_task_wake_after( rtems_clock_get_ticks_per_second() );
    }

    (void) rtems_task_delete( RTEMS_SELF );
}