/*
 *  localghost-helper.c
 *  Localghost
 *
 *  Created by Scott Wheeler on 5/23/10.
 *  Copyright 2010 Directed Edge. All rights reserved.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>

#define HOSTS_FILE "/etc/hosts"
#define BUFFER_SIZE 1024

static void enable(const char *host)
{
    FILE *hosts = fopen(HOSTS_FILE, "rw");
    char buffer[BUFFER_SIZE];
    char *content = 0;
    size_t content_size = 0;
    size_t bytes_read = 0;

    flock(fileno(hosts), LOCK_EX);

    while((bytes_read = fread(&buffer[0], sizeof(char), BUFFER_SIZE, hosts)) > 0)
    {
        content = realloc(content, content_size + bytes_read);
        memcpy(&content[content_size], buffer, bytes_read);
        content_size += bytes_read;
    }

    free(content);
}

int main(int argc, char *argv[])
{
    if(argc != 3)
    {
        fprintf(stderr, "Must be called with --enable or --disable and a host name\n");
    }

    enable(0);

    return 0;
}
