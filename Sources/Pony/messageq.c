
// Note: This code is derivative of the Pony runtime; see README.md for more details

#include "platform.h"

#include "ponyrt.h"
#include "messageq.h"
#include "memory.h"

static bool messageq_push(messageq_t* q, pony_msg_t* first, pony_msg_t* last)
{
    atomic_fetch_add_explicit(&q->num_messages, 1, memory_order_relaxed);
    
    atomic_store_explicit(&last->next, NULL, memory_order_relaxed);
    
    // Without that fence, the store to last->next above could be reordered after
    // the exchange on the head and after the store to prev->next done by the
    // next push, which would result in the pop incorrectly seeing the queue as
    // empty.
    // Also synchronise with the pop on prev->next.
    atomic_thread_fence(memory_order_release);
    
    pony_msg_t* prev = atomic_exchange_explicit(&q->head, last,
                                                memory_order_relaxed);
    
    bool was_empty = ((uintptr_t)prev & 1) != 0;
    prev = (pony_msg_t*)((uintptr_t)prev & ~(uintptr_t)1);
    
    atomic_store_explicit(&prev->next, first, memory_order_relaxed);
    
    return was_empty;
}

void ponyint_messageq_init(messageq_t* q)
{
    pony_msg_t* stub = ponyint_pool_alloc(sizeof(pony_msg_t));
    stub->alloc_size = sizeof(pony_msg_t);
    atomic_store_explicit(&stub->next, NULL, memory_order_relaxed);
    
    atomic_store_explicit(&q->head, (pony_msg_t*)((uintptr_t)stub | 1),
                          memory_order_relaxed);
    q->tail = stub;
    
    atomic_store_explicit(&q->num_messages, 0, memory_order_relaxed);
}

void ponyint_messageq_destroy(messageq_t* q)
{
    while(ponyint_thread_messageq_pop(q) != NULL) { ; }

    pony_msg_t* tail = q->tail;
    assert((((uintptr_t)atomic_load_explicit(&q->head, memory_order_relaxed) & ~(uintptr_t)1)) == (uintptr_t)tail);
    
    ponyint_pool_free(tail, tail->alloc_size);
    atomic_store_explicit(&q->head, NULL, memory_order_relaxed);
    q->tail = NULL;
    atomic_store_explicit(&q->num_messages, 0, memory_order_relaxed);
}

bool ponyint_actor_messageq_push(messageq_t* q, pony_msg_t* first, pony_msg_t* last)
{
    return messageq_push(q, first, last);
}

pony_msg_t* ponyint_actor_messageq_pop(messageq_t* q)
{
    pony_msg_t* tail = q->tail;
    pony_msg_t* next = atomic_load_explicit(&tail->next, memory_order_relaxed);
    
    if(next != NULL)
    {
        q->tail = next;
        atomic_thread_fence(memory_order_acquire);
        ponyint_pool_free(tail, tail->alloc_size);
    }
    
    return next;
}

void ponyint_actor_messageq_pop_mark_done(messageq_t* q) {
    atomic_fetch_sub_explicit(&q->num_messages, 1, memory_order_relaxed);
}

pony_msg_t* ponyint_thread_messageq_pop(messageq_t* q)
{
    pony_msg_t* tail = q->tail;
    pony_msg_t* next = atomic_load_explicit(&tail->next, memory_order_relaxed);
    
    if(next != NULL)
    {
        q->tail = next;
        atomic_thread_fence(memory_order_acquire);
        ponyint_pool_free(tail, tail->alloc_size);
        
        atomic_fetch_sub_explicit(&q->num_messages, 1, memory_order_relaxed);
    }
    
    return next;
}

bool ponyint_messageq_markempty(messageq_t* q)
{
    pony_msg_t* tail = q->tail;
    pony_msg_t* head = atomic_load_explicit(&q->head, memory_order_relaxed);
    
    if(((uintptr_t)head & 1) != 0) {
        atomic_store_explicit(&q->num_messages, 0, memory_order_relaxed);
        return true;
    }
    
    if(head != tail)
        return false;
    
    head = (pony_msg_t*)((uintptr_t)head | 1);
    
    bool empty = atomic_compare_exchange_strong_explicit(&q->head, &tail, head,
                                                         memory_order_release, memory_order_relaxed);
    if(empty) {
        atomic_store_explicit(&q->num_messages, 0, memory_order_relaxed);
    }
    return empty;
}
