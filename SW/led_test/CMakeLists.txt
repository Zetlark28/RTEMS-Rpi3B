cmake_minimum_required(VERSION 3.16)
project(led_test C)

set(CMAKE_C_STANDARD 99)

add_executable(led_test system.h main.c led.h)