
#include "platform.h"

#include "../ponyrt.h"

#include "../messageq.h"
#include "../scheduler.h"
#include "../actor.h"
#include "../cpu.h"
#include "../memory.h"

#include "remote.h"

#ifdef PLATFORM_SUPPORTS_REMOTES

#include <stdlib.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <string.h>
#include <unistd.h>

#ifndef max
    #define max(a,b) ((a) > (b) ? (a) : (b))
#endif

// MARK: - NODE

#define kMaxIPAddress 128

typedef struct root_t
{
    char address[kMaxIPAddress];
    int port;
    bool automaticReconnect;
    int socketfd;
    CreateActorFunc createActorFuncPtr;
    DestroyActorFunc destroyActorFuncPtr;
    MessageActorFunc messageActorFuncPtr;
    RegisterActorsOnRootFunc registerActorsOnRootFuncPtr;
    pony_thread_id_t read_thread_tid;
    pony_thread_id_t write_thread_tid;
    messageq_t write_queue;
} root_t;

#define kMaxRoots 2048

static root_t roots[kMaxRoots+1] = {0};

static PONY_MUTEX roots_mutex;
static bool inited = false;

static DECLARE_THREAD_FN(node_read_from_root_thread);
static DECLARE_THREAD_FN(node_write_to_root_thread);

static void init_all_roots() {
    root_t * ptr = roots;
    while (ptr < (roots + kMaxRoots)) {
        ptr->socketfd = -1;
        ptr++;
    }
}

static root_t * find_root_by_socket(int socketfd) {
    root_t * ptr = roots;
    while (ptr < (roots + kMaxRoots)) {
        if (ptr->socketfd == socketfd) {
            return ptr;
        }
        ptr++;
    }
    return NULL;
}

static bool node_add_root(const char * address,
                          int port,
                          bool automaticReconnect,
                          CreateActorFunc createActorFuncPtr,
                          DestroyActorFunc destroyActorFuncPtr,
                          MessageActorFunc messageActorFuncPtr,
                          RegisterActorsOnRootFunc registerActorsOnRootFuncPtr) {
    for (int i = 0; i < kMaxRoots; i++) {
        if (roots[i].read_thread_tid == 0) {
            ponyint_mutex_lock(roots_mutex);
            strncpy(roots[i].address, address, kMaxIPAddress);
            roots[i].port = port;
            roots[i].automaticReconnect = automaticReconnect;
            roots[i].createActorFuncPtr = createActorFuncPtr;
            roots[i].destroyActorFuncPtr = destroyActorFuncPtr;
            roots[i].messageActorFuncPtr = messageActorFuncPtr;
            roots[i].registerActorsOnRootFuncPtr = registerActorsOnRootFuncPtr;
            ponyint_messageq_init(&roots[i].write_queue);
            ponyint_thread_create(&roots[i].read_thread_tid, node_read_from_root_thread, QOS_CLASS_UTILITY, roots + i);
            ponyint_thread_create(&roots[i].write_thread_tid, node_write_to_root_thread, QOS_CLASS_UTILITY, roots + i);
            ponyint_mutex_unlock(roots_mutex);
            return true;
        }
    }
    return false;
}

static void node_remove_root(root_t * rootPtr) {
    ponyint_mutex_lock(roots_mutex);
    if (rootPtr->read_thread_tid != 0) {
        close_socket(rootPtr->socketfd);
        
        pony_thread_id_t read_thread = rootPtr->read_thread_tid;
        pony_thread_id_t write_thread = rootPtr->write_thread_tid;
        rootPtr->read_thread_tid = 0;
        rootPtr->write_thread_tid = 0;
        rootPtr->port = 0;
        rootPtr->automaticReconnect = false;
        rootPtr->createActorFuncPtr = NULL;
        rootPtr->destroyActorFuncPtr = NULL;
        rootPtr->messageActorFuncPtr = NULL;
        rootPtr->registerActorsOnRootFuncPtr = NULL;
        rootPtr->address[0] = 0;
        rootPtr->socketfd = -1;
        ponyint_messageq_destroy(&rootPtr->write_queue);
    }
    ponyint_mutex_unlock(roots_mutex);
}

static void node_remove_all_roots() {
    if (inited == false) {
        return;
    }
    
    // we just invalidate the socket, the root connections will remove themselves
    for (int i = 0; i < kMaxRoots; i++) {
        ponyint_mutex_lock(roots_mutex);
        pony_thread_id_t write_thread_tid = roots[i].write_thread_tid;
        roots[i].socketfd = -1;
        ponyint_mutex_unlock(roots_mutex);
        
        if (write_thread_tid != 0) {
            ponyint_thread_join(write_thread_tid);
        }
    }
}

void pony_node_send_version_check(root_t * rootPtr)
{
    pony_msg_remote_version_t* m = (pony_msg_remote_version_t*)pony_alloc_msg(sizeof(pony_msg_remote_version_t), kRemote_Version);
    ponyint_actor_messageq_push(&rootPtr->write_queue, &m->msg, &m->msg);
}

void pony_node_send_register(root_t * rootPtr, const char * registration)
{
    pony_msg_remote_register_t* m = (pony_msg_remote_register_t*)pony_alloc_msg(sizeof(pony_msg_remote_register_t), kRemote_RegisterWithRoot);
    uint32_t length = max(2048, (uint32_t)strlen(registration) + 1);
    m->registration = (char *)ponyint_pool_alloc(length);
    strncpy(m->registration, registration, length-1);
    m->length = length;
    ponyint_actor_messageq_push(&rootPtr->write_queue, &m->msg, &m->msg);
}

void pony_node_send_core_count(root_t * rootPtr)
{
    pony_msg_remote_core_count_t* m = (pony_msg_remote_core_count_t*)pony_alloc_msg(sizeof(pony_msg_remote_core_count_t), kRemote_SendCoreCount);
    ponyint_actor_messageq_push(&rootPtr->write_queue, &m->msg, &m->msg);
}

void pony_node_send_heartbeat(root_t * rootPtr)
{
    pony_msg_remote_heartbeat_t* m = (pony_msg_remote_heartbeat_t*)pony_alloc_msg(sizeof(pony_msg_remote_heartbeat_t), kRemote_SendHeartbeat);
    ponyint_actor_messageq_push(&rootPtr->write_queue, &m->msg, &m->msg);
}

void pony_node_send_destroy_actor_ack(root_t * rootPtr)
{
    pony_msg_remote_destroy_actor_ack_t* m = (pony_msg_remote_destroy_actor_ack_t*)pony_alloc_msg(sizeof(pony_msg_remote_destroy_actor_ack_t), kRemote_DestroyActorAck);
    ponyint_actor_messageq_push(&rootPtr->write_queue, &m->msg, &m->msg);
}

void pony_node_send_reply(root_t * rootPtr,
                          uint32_t messageId,
                          const void * payload,
                          uint32_t length)
{
    pony_msg_remote_sendreply_t* m = (pony_msg_remote_sendreply_t*)pony_alloc_msg(sizeof(pony_msg_remote_sendreply_t), kRemote_SendReply);
    m->messageId = messageId;
    m->payload = (void *)malloc(length);
    memcpy(m->payload, payload, length);
    m->length = length;
    ponyint_actor_messageq_push(&rootPtr->write_queue, &m->msg, &m->msg);
}

static DECLARE_THREAD_FN(node_write_to_root_thread)
{
    ponyint_thead_setname_actual("Flynn Node -> Root");
    
    extern void send_version_check(int socketfd);
    extern void send_core_count(int socketfd);
    extern void send_register_with_root(int socketfd, const char * registrationString);
    extern int send_heartbeat(int socketfd);
    extern int send_destroy_actor_ack(int socketfd);
    extern void send_reply(int socketfd, uint32_t messageID, const void * bytes, uint32_t count);
    
    // node writing information to be sent to the root. Uses pony message
    // queue to allow other threads to add messages to the queue, and this
    // just drains the queue and writes to the socket
    root_t * rootPtr = (root_t *) arg;
    pony_msg_t* msg;
    
    while(rootPtr->read_thread_tid != 0) {
        
        bool didSend = false;
        
        while((msg = (pony_msg_t *)ponyint_actor_messageq_pop(&rootPtr->write_queue)) != NULL) {
            
            if (didSend == false) {
                didSend = true;
                cork(rootPtr->socketfd);
            }
            
            switch(msg->msgId) {
                case kRemote_Version: {
                    send_version_check(rootPtr->socketfd);
                } break;
                case kRemote_RegisterWithRoot: {
                    pony_msg_remote_register_t * m = (pony_msg_remote_register_t *)msg;
                    send_register_with_root(rootPtr->socketfd, m->registration);
                    ponyint_pool_free(m->registration, m->length);
                } break;
                case kRemote_SendCoreCount: {
                    send_core_count(rootPtr->socketfd);
                } break;
                case kRemote_SendHeartbeat: {
                    if (send_heartbeat(rootPtr->socketfd) <= 0) {
                        close_socket(rootPtr->socketfd);
                        rootPtr->socketfd = -1;
                    }
                } break;
                case kRemote_DestroyActorAck: {
                    send_destroy_actor_ack(rootPtr->socketfd);
                } break;
                case kRemote_SendReply: {
                    pony_msg_remote_sendreply_t * m = (pony_msg_remote_sendreply_t *)msg;
                    send_reply(rootPtr->socketfd,
                               m->messageId,
                               m->payload,
                               m->length);
                    free(m->payload);
                } break;
            }
            
            ponyint_actor_messageq_pop_mark_done(&rootPtr->write_queue);
        }
        
        if (didSend) {
            uncork(rootPtr->socketfd);
        }
        
        ponyint_messageq_markempty(&rootPtr->write_queue);
        usleep(500);
    }
    
    ponyint_pool_thread_cleanup();
    return 0;
}

static DECLARE_THREAD_FN(node_read_from_root_thread)
{
    ponyint_thead_setname_actual("Flynn Node <- Root");
    
    extern int send_heartbeat(int socketfd);
    
    root_t * rootPtr = (root_t *) arg;
    
    char name[256] = {0};
    snprintf(name, sizeof(name), "Flynn Node to %s:%d", rootPtr->address, rootPtr->port);
    ponyint_thead_setname_actual(name);
        
    socklen_t len;
    struct sockaddr_in servaddr = {0};
    
    servaddr.sin_family = AF_INET;
    inet_pton(AF_INET, rootPtr->address, &(servaddr.sin_addr));
    servaddr.sin_port = htons(rootPtr->port);
    
    int connectAttemptCount = 0;
    
    while (rootPtr->read_thread_tid != 0) {
        
        // socket create and verification
        rootPtr->socketfd = socket(AF_INET, SOCK_STREAM, 0);
        if (rootPtr->socketfd < 0) {
            pony_syslog2("Flynn", "Flynn Node socket creation failed, exiting...");
            exit(1);
        }
        
        disableSIGPIPE(rootPtr->socketfd);
        
        connectAttemptCount += 1;
        pony_syslog2("Flynn", "reconnect attempt %d to root %s:%d\n", connectAttemptCount, rootPtr->address, rootPtr->port);
        if (connect(rootPtr->socketfd, (struct sockaddr*)&servaddr, sizeof(servaddr)) != 0) {
            close_socket(rootPtr->socketfd);
            sleep(1);
            continue;
        }
        
        pony_node_send_version_check(rootPtr);
        
        rootPtr->registerActorsOnRootFuncPtr(rootPtr->socketfd);
        
        pony_node_send_core_count(rootPtr);
        
        // set the 5 second timeout on reads from the root
        struct timeval timeout;
        timeout.tv_sec = 5;
        timeout.tv_usec = 0;
        setsockopt (rootPtr->socketfd, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
        
        connectAttemptCount = 0;
        pony_syslog2("Flynn", "connected to root %s:%d\n", rootPtr->address, rootPtr->port);
        while(rootPtr->socketfd >= 0) {
#if REMOTE_DEBUG
            pony_syslog2("Flynn", "[%d] node reading socket\n", rootPtr->socketfd);
#endif
            
            // read the command byte
            uint8_t command = read_command(rootPtr->socketfd);
                        
            if (command == COMMAND_NULL) {
                // At this point, we don't know if we timed out reading data or the server
                // disconnected. So we send a heartbeat to the root, and if that fails we know
                ponyint_mutex_lock(roots_mutex);
                if (send_heartbeat(rootPtr->socketfd) <= 0) {
                    close_socket(rootPtr->socketfd);
                    rootPtr->socketfd = -1;
                }
                ponyint_mutex_unlock(roots_mutex);
                continue;
            }
            
            if (command != COMMAND_VERSION_CHECK &&
                command != COMMAND_CREATE_ACTOR &&
                command != COMMAND_DESTROY_ACTOR &&
                command != COMMAND_SEND_MESSAGE) {
                node_remove_root(rootPtr);
                ponyint_pool_thread_cleanup();
                return 0;
            }
                        
            // read the size of the uuid
            char uuid[128] = {0};
            if (!read_bytecount_buffer(rootPtr->socketfd, uuid, sizeof(uuid)-1)) {
                node_remove_root(rootPtr);
                ponyint_pool_thread_cleanup();
                return 0;
            }

            
            switch (command) {
                case COMMAND_VERSION_CHECK: {
                    if (strncmp(BUILD_VERSION_UUID, uuid, strlen(BUILD_VERSION_UUID)) != 0) {
#if REMOTE_DEBUG
                        pony_syslog2("Flynn", "[%d] node -> root version mismatch ( [%s] != [%s] )\n", rootPtr->socketfd, uuid, BUILD_VERSION_UUID);
#endif
                    }
                } break;
                case COMMAND_CREATE_ACTOR: {
                    char type[128] = {0};
                    if (!read_bytecount_buffer(rootPtr->socketfd, type, sizeof(type)-1)) {
                        node_remove_root(rootPtr);
                        ponyint_pool_thread_cleanup();
                        return 0;
                    }
                    
                    rootPtr->createActorFuncPtr(uuid, type, false, rootPtr->socketfd);
                    
#if REMOTE_DEBUG
                    pony_syslog2("Flynn", "[%d] COMMAND_CREATE_ACTOR(node)[%s, %s]\n", rootPtr->socketfd, uuid, type);
#endif
                } break;
                case COMMAND_DESTROY_ACTOR:
                    rootPtr->destroyActorFuncPtr(uuid);
#if REMOTE_DEBUG
                    pony_syslog2("Flynn", "[%d] COMMAND_DESTROY_ACTOR[%s]\n", rootPtr->socketfd, uuid);
#endif
                    break;
                case COMMAND_SEND_MESSAGE: {
                    
                    char behavior[128] = {0};
                    if (!read_bytecount_buffer(rootPtr->socketfd, behavior, sizeof(behavior)-1)) {
                        node_remove_root(rootPtr);
                        ponyint_pool_thread_cleanup();
                        return 0;
                    }
                    
                    uint32_t messageID = 0;
                    if (!read_int(rootPtr->socketfd, &messageID)) {
                        node_remove_root(rootPtr);
                        ponyint_pool_thread_cleanup();
                        return 0;
                    }
                    
                    uint32_t payload_count = 0;
                    recvall(rootPtr->socketfd, &payload_count, sizeof(uint32_t));
                    payload_count = ntohl(payload_count);
                    
                    uint8_t * bytes = malloc(payload_count);
                    recvall(rootPtr->socketfd, bytes, payload_count);
                    
                    rootPtr->messageActorFuncPtr(uuid, behavior, bytes, payload_count, messageID, rootPtr->socketfd);
                    
    #if REMOTE_DEBUG
                    pony_syslog2("Flynn", "[%d] COMMAND_SEND_MESSAGE[%s, %s] %d bytes\n", rootPtr->socketfd, uuid, behavior, payload_count);
    #endif
                } break;
            }
        }
        
        if (rootPtr->automaticReconnect == false) {
            break;
        }
    }
    
    node_remove_root(rootPtr);
    ponyint_pool_thread_cleanup();
    
    return 0;
}

void pony_node(const char * address,
               int port,
               bool automaticReconnect,
               CreateActorFunc createActorFuncPtr,
               DestroyActorFunc destroyActorFuncPtr,
               MessageActorFunc messageActorFuncPtr,
               RegisterActorsOnRootFunc registerActorsOnRootFuncPtr) {
    if (inited == false) {
        inited = true;
        init_all_roots();
        roots_mutex = ponyint_mutex_create();
    }
    
    if(!node_add_root(address,
                      port,
                      automaticReconnect,
                      createActorFuncPtr,
                      destroyActorFuncPtr,
                      messageActorFuncPtr,
                      registerActorsOnRootFuncPtr)) {
        pony_syslog2("Flynn", "Flynn node failed to add root, maximum number of roots exceeded\n");
        return;
    }
}

void node_shutdown() {
    node_remove_all_roots();
}

// MARK: - MESSAGES

void pony_node_send_actor_message_to_root(int socketfd, int messageID, const void * bytes, int count) {
    // When a node is sending back to a root, they send a message by knowing the recipients actor uuid
    // The root knows which messages it sent which are expecting a reply, so it is garaunteed they
    // will be delivered back in order
    
    ponyint_mutex_lock(roots_mutex);
    root_t * rootPtr = find_root_by_socket(socketfd);
    if (rootPtr != NULL) {
        pony_node_send_reply(rootPtr, messageID, bytes, count);
    }
    ponyint_mutex_unlock(roots_mutex);
}

void pony_register_node_to_root(int socketfd, const char * actorRegistrationString) {
    
    ponyint_mutex_lock(roots_mutex);
    root_t * rootPtr = find_root_by_socket(socketfd);
    if (rootPtr != NULL) {
        pony_node_send_register(rootPtr, actorRegistrationString);
    }
    ponyint_mutex_unlock(roots_mutex);
}

void pony_node_destroy_actor_to_root(int socketfd) {
    ponyint_mutex_lock(roots_mutex);
    root_t * rootPtr = find_root_by_socket(socketfd);
    if (rootPtr != NULL) {
        pony_node_send_destroy_actor_ack(rootPtr);
    }
    ponyint_mutex_unlock(roots_mutex);
}

#else

void pony_node(const char * address,
               int port,
               bool automaticReconnect,
               void * createActorFuncPtr,
               void * destroyActorFuncPtr,
               void * messageActorFuncPtr,
               void * registerActorsOnRootFuncPtr) {
    
}

void pony_node_destroy_actor_to_root(int socketfd) {
    
}

void pony_node_send_actor_message_to_root(int socketfd, int messageID, const void * bytes, int count) {
    
}

void pony_register_node_to_root(int socketfd, const char * actorRegistrationString) {
    
}

#endif
