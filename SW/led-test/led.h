//
// Created by Ezpeleta on 24/10/2020.
//

#ifndef LED_TEST_LED_H
#define LED_TEST_LED_H


#define INP_GPIO(g) *(gpio+((g)/10)) &= ~(7<<(((g)%10)*3))
#define OUT_GPIO(g) *(gpio+((g)/10)) |=  (1<<(((g)%10)*3))

#define GPIO_SET_EXT *(gpio+8)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR_EXT *(gpio+11) // clears bits which are 1 ignores bits which are 0

//47 = GPIO PIN 15
#define LED_INIT(g)  do { unsigned int *gpio = (unsigned int *)BCM2835_GPIO_REGS_BASE; OUT_GPIO(g);} while(0)
#define LED_ON(g)  do { unsigned int *gpio = (unsigned int *)BCM2835_GPIO_REGS_BASE; GPIO_CLR_EXT = 1 << (g % 32);} while(0)
#define LED_OFF(g)  do { unsigned int *gpio = (unsigned int *)BCM2835_GPIO_REGS_BASE; GPIO_SET_EXT = 1 << (g % 32);} while(0)


#ifndef LED_INIT
#define LED_INIT()
#endif

#endif //LED_TEST_LED_H
