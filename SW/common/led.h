//
// Created by Ezpeleta on 24/10/2020.
//

#ifndef LED_TEST_LED_H
#define LED_TEST_LED_H


#define INP_GPIO(g) *(gpio+((g)/10)) &= ~(7<<(((g)%10)*3))
#define OUT_GPIO(g) *(gpio+((g)/10)) |=  (1<<(((g)%10)*3))
#define GET_GPIO(g) (*(gpio+13)&(1<<g)) // 0 if LOW, (1<<g) if HIGH

#define LED_INIT(g)  do { unsigned int *gpio = (unsigned int *)BCM2835_GPIO_REGS_BASE; INP_GPIO(g);OUT_GPIO(g);} while(0)
#define LED_ON(g)  do { unsigned int *gpio = (unsigned int *)BCM2835_GPIO_GPSET0; *gpio = 1 << (g % 32);} while(0)
#define LED_OFF(g)  do { unsigned int *gpio = (unsigned int *)BCM2835_GPIO_GPCLR0; *gpio = 1 << (g % 32);} while(0)

#endif //LED_TEST_LED_H
