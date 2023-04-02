/*
 *  main.cs
 *
 *  Entry point for Seraterm, Serial Terminal App for Foenix machines
 * 
 *  Author: Rob Trangmar (robtrang@yahoo.com)
 *  Date:   3/15/23
 */

#include <stdio.h>
#include <stdlib.h>
#include <seraterm.h>

void
main(int arg, char **argv)
{
    printf("SeraTerm Version: %f\n", SERATERM_VERSION);
    exit(0);
}