
// Note: This code is derivative of the Pony runtime; see README.md for more details

#include "platform.h"

#include <stdlib.h>

#include "ponyrt.h"

#include "messageq.h"
#include "scheduler.h"
#include "actor.h"
#include "cpu.h"
#include "memory.h"

extern int ponyint_remote_nodes_count();
extern int ponyint_remote_core_count();
extern int ponyint_remote_core_count_by_socket(int socketfd);

static bool pony_is_inited = false;

bool pony_startup() {
    if (pony_is_inited) { return true; }
    
    //fprintf(stderr, "pony_startup()\n");
    
    ponyint_cpu_init();
    
    ponyint_sched_init();
    
    pony_is_inited = ponyint_sched_start();
    
    return pony_is_inited;
}

void pony_shutdown(bool waitForRemotes) {
    if (!pony_is_inited) { return; }
    
    ponyint_sched_wait(waitForRemotes);
    
    fprintf(stderr, "pony remote shutdown\n");
    pony_remote_shutdown();
    
    fprintf(stderr, "pony scheduler shutdown\n");
    ponyint_sched_stop();
    
    fprintf(stderr, "pony shutdown finished\n");
    pony_is_inited = false;
}

int pony_core_count() {
    return ponyint_core_count();
}

int pony_e_core_count() {
    return ponyint_e_core_count();
}

int pony_p_core_count() {
    return ponyint_p_core_count();
}

int pony_remote_core_count() {
    return ponyint_remote_core_count();
}

int pony_remote_core_count_by_socket(int socketfd) {
    return ponyint_remote_core_count_by_socket(socketfd);
}

int pony_remote_nodes_count() {
    return ponyint_remote_nodes_count();
}

bool pony_core_affinity_enabled() {
    return ponyint_hybrid_cores_enabled() != 0;
}

void * pony_actor_create() {
    return ponyint_create_actor(pony_ctx());
}

void pony_actor_send_message(void * actor, void * argumentPtr, void (*handleMessageFunc)(void * message)) {
    if (pony_is_inited == false) { return; }
    pony_send_message(pony_ctx(), actor, argumentPtr, handleMessageFunc);
}

void pony_actor_setpriority(void * actor, int priority) {
    if (pony_is_inited == false) { return; }
    ponyint_actor_setpriority(actor, priority);
}

int pony_actor_getpriority(void * actor) {
    if (pony_is_inited == false) { return 0; }
    return ponyint_actor_getpriority(actor);
}

void pony_actor_setbatchSize(void * actor, int batchSize) {
    if (pony_is_inited == false) { return; }
    ponyint_actor_setbatchSize(actor, batchSize);
}

int pony_actor_getbatchSize(void * actor) {
    if (pony_is_inited == false) { return 100; }
    return ponyint_actor_getbatchSize(actor);
}

void pony_actor_setcoreAffinity(void * actor, int coreAffinity) {
    if (pony_is_inited == false) { return; }
    ponyint_actor_setcoreAffinity(actor, coreAffinity);
}

int pony_actor_getcoreAffinity(void * actor) {
    if (pony_is_inited == false) { return 0; }
    return ponyint_actor_getcoreAffinity(actor);
}

void pony_actor_yield(void * actor) {
    if (pony_is_inited == false) { return; }
    ponyint_yield_actor(actor);
}

int pony_actors_load_balance(void * actorArray, int num_actors) {
    if (pony_is_inited == false) { return 0; }
    pony_actor_t ** actorsPtr = (pony_actor_t**)actorArray;
    pony_actor_t * minActor = *actorsPtr;
    int minIdx = 0;
    for (int i = 0; i < num_actors; i++) {
        if(actorsPtr[i]->q.num_messages < minActor->q.num_messages) {
            minActor = actorsPtr[i];
            minIdx = i;
            if (minActor->q.num_messages == 0) {
                return minIdx;
            }
        }
    }
    return minIdx;
}

bool pony_actors_should_wait(int min_msgs, void * actorArray, int num_actors) {
    if (pony_is_inited == false) { return false; }
    // we hard wait until all actors we have been given have no messages waiting
    pony_actor_t ** actorsPtr = (pony_actor_t**)actorArray;
    int32_t n = 0;
    for (int i = 0; i < num_actors; i++) {
        n += actorsPtr[i]->q.num_messages;
    }
    if (n <= min_msgs) {
        return false;
    }
    return true;
}

void pony_actors_wait(int min_msgs, void * actorArray, int num_actors) {
    if (pony_is_inited == false) { return; }
    // we hard wait until all actors we have been given have no messages waiting
    pony_actor_t ** actorsPtr = (pony_actor_t**)actorArray;
    int scaling_sleep = 10;
    int max_scaling_sleep = 500;
    while (pony_actors_should_wait(min_msgs, actorArray, num_actors)) {
        ponyint_cpu_sleep(scaling_sleep);
        scaling_sleep += 1;
        if (scaling_sleep > max_scaling_sleep) {
            scaling_sleep = max_scaling_sleep;
        }
    }
}

void pony_actor_wait(int min_msgs, void * actor) {
    if (pony_is_inited == false) { return; }
    pony_actors_wait(min_msgs, &actor, 1);
}

int pony_actor_num_messages(void * actor) {
    if (pony_is_inited == false) { return 0; }
    return (int)ponyint_actor_num_messages(actor);
}

void pony_actor_destroy(void * actor) {
    if (pony_is_inited == false) { return; }
    ponyint_destroy_actor(actor);
}

unsigned long pony_max_memory() {
    // TODO: FIX ME
    //return (unsigned long)ponyint_max_memory();
    return 0;
}

unsigned long pony_current_memory() {
    // TODO: FIX ME
    //return (unsigned long)ponyint_total_memory();
    return 0;
}

unsigned long pony_mapped_memory() {
    // TODO: FIX ME
    //return (unsigned long)ponyint_usafe_mapped_memory();
    return 0;
}

