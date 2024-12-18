
// Note: This code is derivative of the Pony runtime; see README.md for more details

#include "platform.h"

#ifndef sched_scheduler_h
#define sched_scheduler_h

#include <stdalign.h>
#include "mpmcq.h"
#include "threads.h"

typedef struct scheduler_t scheduler_t;

#include "messageq.h"

// default actor priority
#define PONY_DEFAULT_ACTOR_PRIORITY 0

#define SPECIAL_THREADID_KQUEUE   -10
#define SPECIAL_THREADID_IOCP     -11
#define SPECIAL_THREADID_EPOLL    -12
#define SPECIAL_THREADID_ANALYSIS    -13

typedef struct pony_ctx_t
{
    scheduler_t* scheduler;
} pony_ctx_t;

struct scheduler_t
{
    // These are rarely changed.
    pony_thread_id_t tid;
    int32_t index;
    int32_t coreAffinity;
    bool idle;
    bool terminate;
    
    // These are changed primarily by the owning scheduler thread.
    alignas(64) struct scheduler_t* last_victim;
    
    pony_ctx_t ctx;
    
    // These are accessed by other scheduler threads. The mpmcq_t is aligned.
    mpmcq_t q;
    messageq_t mq;
};

pony_ctx_t* pony_ctx(void);

pony_ctx_t* ponyint_sched_init(int force_scheduler_count, int minimum_scheduler_count);;

bool ponyint_sched_start(void);

void ponyint_sched_stop(void);

void ponyint_sched_wait(bool waitForRemotes);

void ponyint_sched_add(pony_ctx_t* ctx, pony_actor_t* actor);

uint32_t ponyint_sched_cores(void);

// Retrieves the global main thread context for scheduling
// special actors on the inject queue.
pony_ctx_t* ponyint_sched_get_inject_context(void);

#endif
