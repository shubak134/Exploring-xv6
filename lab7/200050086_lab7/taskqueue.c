#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

// Global variables
long sum = 0;
long odd = 0;
long even = 0;
long min = INT_MAX;
long max = INT_MIN;
bool done = false;
pthread_mutex_t m;
bool *threadPool;
pthread_t *ids;

typedef struct {
    long number;
    long idx;
} arg_t;

void processtask(void *arg);

void processtask(void *arg)
{
    arg_t nums = *(arg_t *) arg;
    
    long number = nums.number;
    long idx = nums.idx;

    // simulate burst time
    sleep(number);

    // update global variables
    
    pthread_mutex_lock(&m);
    sum += number;
    if (number % 2 == 1)
    {
        odd++;
    }
    else
    {
        even++;
    }
    pthread_mutex_unlock(&m);
    pthread_mutex_lock(&m);
    if (number < min)
    {
        min = number;
    }
    pthread_mutex_unlock(&m);
    pthread_mutex_lock(&m);
    if (number > max)
    {
        max = number;
    }
    pthread_mutex_unlock(&m);
    pthread_mutex_lock(&m);
    threadPool[idx] = true;
    pthread_mutex_unlock(&m);
    printf("Task completed\n");
}

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        printf("Usage: sum <infile> <threadNum>\n");
        exit(EXIT_FAILURE);
    }
    char *fn = argv[1];
    int threadNum = atoi(argv[2]);
    
    threadPool = (bool *) malloc(threadNum*sizeof(bool));
    for(int i = 0; i < threadNum; i++) threadPool[i] = true;
    
    ids = (pthread_t *) malloc(threadNum*sizeof(pthread_t));

    // Read from file
    FILE *fin = fopen(fn, "r");
    long t;
    fscanf(fin, "%ld\n", &t);
    printf("The number of tasks are : %ld \n", t);
    
    long tasks[t];
    long f = 0, b = 0;
    
    char type;
    long num;
    while (fscanf(fin, "%c %ld\n", &type, &num) == 2)
    {
        if (type == 'p')
        {   
            bool free = false;
            // spawn a thread to do the latest task here
            for(int i = 0; i < threadNum; i++) {
                pthread_mutex_lock(&m);
                if(threadPool[i]) {
                    if(f == b) {
                        arg_t arg = {num, i};
                        pthread_create(ids+i, NULL, (void *)processtask, (void *)&arg);
                    }
                    else if(f < b) {
                        arg_t arg = {tasks[f++], i};
                        pthread_create(ids+i, NULL, (void *)processtask, (void *)&arg);
                        tasks[b++] = num;
                    }

                    threadPool[i] = false;
                    free = true;
                    pthread_mutex_unlock(&m);
                    break;
                }
                pthread_mutex_unlock(&m);
            }

            if(!free)
                tasks[b++] = num;
        }
        else if (type == 'w')
        { // waiting period
            sleep(num);
            printf("Wait Over\n");
        }
        else
        {
            printf("ERROR: Type Unrecognizable: '%c'\n", type);
            exit(EXIT_FAILURE);
        }
    }

    while(b-f > 0) {
        for(int i = 0; i < threadNum; i++) {
            pthread_mutex_lock(&m);
            if(threadPool[i]) {
                arg_t arg = {tasks[f++], i};
                pthread_create(ids+i, NULL, (void *)processtask, (void *)&arg);

                threadPool[i] = false;
            }
            pthread_mutex_unlock(&m);
        }
    }

    for(int i = 0; i < threadNum; i++) {
        pthread_join(ids[i], NULL);
    }
    fclose(fin);
    // Print global variables
    printf("%ld %ld %ld %ld %ld\n", sum, odd, even, min, max);


    free((void *) threadPool);
    free((void *) ids);
    return (EXIT_SUCCESS);
}
