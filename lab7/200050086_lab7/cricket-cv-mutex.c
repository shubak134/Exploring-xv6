#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

int max_score = 0;
int max_team_score = 0;
int max_cap = 0;
int max_titan = 0;
int tit_wins = 0;
pthread_mutex_t ms;
pthread_mutex_t hs;
pthread_mutex_t mts;

typedef struct {
    int* highscore;
    int* total_score;
} team_arg;

void player(void *arg) {
    int *num = (int *)arg;
    *num = rand()%101;

    pthread_mutex_lock(&ms);
    if(*num > max_score) {
        max_score = *num;
    }
    pthread_mutex_unlock(&ms);
}

void team(void *arg) {
    int scores[11];
    pthread_t ids[11];

    for(int i = 0; i < 11; i++) {
        pthread_create(ids+i, NULL, (void *)&player, (void *)&scores[i]);
    }

    for(int i = 0; i < 11; i++) {
        pthread_join(*(ids+i), NULL);
    }

    team_arg* num = (team_arg *)arg;

    int teamHigh = scores[0];
    for(int i = 0; i < 11; i++) {
        if(scores[i] > teamHigh) teamHigh = scores[i];

        *(num->total_score) += scores[i];
    }

    pthread_mutex_lock(&mts);
    if(*(num->total_score) > max_team_score) {
        max_team_score = *(num->total_score);
    }
    pthread_mutex_unlock(&mts);

    pthread_mutex_lock(&hs);
    if(teamHigh > *(num->highscore)) {
        *(num->highscore) = teamHigh;
    }
    pthread_mutex_unlock(&hs);
}

void game() {
    int highscore = 0;
    int cap = 0, titan = 0;

    pthread_t cap_id, tit_id;
    team_arg cap_arg = {&highscore, &cap};
    pthread_create(&cap_id, NULL, (void *)&team, (void *)&cap_arg);
    
    team_arg tit_arg = {&highscore, &titan};
    pthread_create(&tit_id, NULL, (void *)&team, (void *)&tit_arg);

    pthread_join(cap_id, NULL);
    pthread_join(tit_id, NULL);

    if(cap > max_cap) max_cap = cap;
    if(titan > max_titan) max_titan = titan;

    printf("SCORE: Capitals : %d :: Titans : %d\n", cap, titan);
    printf("Highest Individual Score : %d\n", highscore);
    if(cap > titan) {
        printf("Capitals won by %d runs\n", (cap-titan));
    }
    else {
        printf("Titans won by %d runs\n", (titan-cap));
        tit_wins++;
    }
}

int main(int argc, char** argv) {
    if(argc < 2) {
        printf("Usage: ./a.out <number_of_players>\n");
        exit(EXIT_FAILURE);
    }
    int numPlayers = atoi(argv[1]);
    int numMatches = numPlayers/22;

    for(int i = 0; i < numMatches; i++) {
        printf("--------------------MATCH : (%d) Summary--------------------\n", (i+1));
        game();
    }

    printf("--------------------SUMMARY OF THE DAY--------------------------\n");
    printf("Matches Played : %d\n", numMatches);
    printf("Titans   :: Won : %d || Lost : %d || Tied : 0\n", tit_wins, numMatches-tit_wins);
    printf("Capitals :: Won : %d || Lost : %d || Tied : 0\n", numMatches-tit_wins, tit_wins);
    printf("Highest Team Score           : %d\n", max_team_score);
    printf("Highest Individual Score     : %d\n", max_score);
    printf("----------------------------------------------------------------\n");
    return EXIT_SUCCESS;
}