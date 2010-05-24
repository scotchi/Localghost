/*
 *  LocalghostHelper.c
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

#ifndef BOOL
#define BOOL int
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#define PRINT_LINE \
    fprintf(hosts, "%s\n", line)

#define PRINT_USAGE \
    fprintf(stderr, "Must be called with --enable or --disable and a host name\n"); \
    return 1;

static void set_enabled(const char *host, int enabled)
{
    FILE *hosts = 0;
    char buffer[BUFFER_SIZE];
    char *content = 0;
    size_t content_size = 0;
    size_t bytes_read = 0;
    char *line = 0;
    BOOL found = FALSE;

    hosts = fopen(HOSTS_FILE, "r+");

    if(!hosts)
    {
        fprintf(stderr, "Could not open %s for writing.\n", HOSTS_FILE);
        return;
    }

    flock(fileno(hosts), LOCK_EX);

    while((bytes_read = fread(&buffer[0], sizeof(char), BUFFER_SIZE, hosts)) > 0)
    {
        content = realloc(content, content_size + bytes_read);
        memcpy(&content[content_size], buffer, bytes_read);
        content_size += bytes_read;
    }

    hosts = freopen(HOSTS_FILE, "w", hosts);

    while((line = strtok(line ? 0 : content, "\n")))
    {
        if(strlen(line) > 0 && line[0] == '#')
        {
            PRINT_LINE;
        }
        else if(strstr(line, host))
        {
            if(strstr(line, "127.0.0.1"))
            {
                if(enabled)
                {
                    found = TRUE;
                    PRINT_LINE;
                }
            }
            else
            {
                fprintf(hosts, "# %s\n", line);
            }
        }
        else
        {
            PRINT_LINE;
        }
    }

    if(enabled && !found)
    {
        fprintf(hosts, "127.0.0.1\t%s\n", host);
    }

    flock(fileno(hosts), LOCK_UN);
    fclose(hosts);
    free(content);
}

int main(int argc, char *argv[])
{
    const char *mode = 0;
    const char *host = 0;

    if(argc != 3)
    {
        PRINT_USAGE;
    }

    mode = argv[1];
    host = argv[2];

    if(strcmp(mode, "--enable") == 0)
    {
        set_enabled(host, TRUE);
    }
    else if(strcmp(mode, "--disable") == 0)
    {
        set_enabled(host, FALSE);
    }
    else
    {
        PRINT_USAGE;
    }

    return 0;
}
