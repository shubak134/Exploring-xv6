#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <time.h>

int account_balance = 0;
pthread_mutex_t lock;

void* increment(void *amt) {
    int mil = *(int *) amt;
    pthread_mutex_lock(&lock);
    for (int i = 0; i < mil*1000000; i++) {
        account_balance++;
    }
    pthread_mutex_unlock(&lock);
}

int main(int argc, char* argv[]) {
    clock_t start, end;
    double cpu_time_used;

    start = clock();

    int threadNum = atoi(argv[1]);
    printf("%d",threadNum);
    pthread_t th[threadNum];
    int i;
    int each = 2048/threadNum;
    int left = 2048%threadNum;

    for (i = 0; i < threadNum; i++) {
        int arg = each;
        if(i == 0) arg += left;

        if (pthread_create(th + i, NULL, &increment, (void *)&arg) != 0) {
            perror("Failed to create thread");
            return 1;
        }
        printf("Transaction %d has started\n", i);
    }
    for (i = 0; i < threadNum; i++) {
        if (pthread_join(th[i], NULL) != 0) {
            return 2;
        }
        printf("Transaction %d has finished\n", i);
    }
    printf("Account Balance is : %d\n", account_balance);

    end = clock();

    cpu_time_used = 1000*((double) (end-start)) / CLOCKS_PER_SEC;

    printf("Time spent: %f ms\n", cpu_time_used);
    return 0;
}