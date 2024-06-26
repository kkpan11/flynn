
#include "platform.h"

#ifdef PLATFORM_SUPPORTS_REMOTES

#include <stdlib.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <string.h>
#include <unistd.h>
#include <netinet/tcp.h>

#include "../ponyrt.h"

#include "../messageq.h"
#include "../scheduler.h"
#include "../actor.h"
#include "../cpu.h"
#include "../memory.h"

#include "remote.h"

extern void root_shutdown();
extern void node_shutdown();

char * BUILD_VERSION_UUID = __TIMESTAMP__;

#ifdef PLATFORM_IS_APPLE
int sendFlags = 0;
#else
int sendFlags = MSG_NOSIGNAL;
#endif



void disableSIGPIPE(int fd) {
#ifdef PLATFORM_IS_APPLE
    int on = 1;
    setsockopt (fd, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));
#endif
}

// Communication between root and node uses the following format:
//  bytes      meaning
//   [0] U8     type of command this is
//
//  COMMAND_CORE_COUNT (node -> root)
//   [0-4]      number of cores this node has
//
//  COMMAND_HEARTBEAT (node -> root)
//
//  COMMAND_VERSION_CHECK (root -> node)
//   [1] U8     number of bytes for version uuid
//   [?]        version uuid as string
//
//  COMMAND_REGISTER_WITH_ROOT (node -> root)
//   [0-4]     number of bytes for registration string
//   [?]        registration string
//
//  COMMAND_CREATE_ACTOR (root -> node)
//   [1] U8     number of bytes for actor uuid
//   [?]        actor uuid as string
//   [1] U8     number of bytes for actor class name
//   [?]        actor class name
//
//  COMMAND_DESTROY_ACTOR (root -> node)
//   [1] U8     number of bytes for actor uuid
//   [?]        actor uuid as string
//
//  COMMAND_SEND_MESSAGE (root -> node)
//   [1] U8     number of bytes for actor uuid
//   [?]        actor uuid as string
//   [?]        behavior type as string
//   [0-4]      messageID
//   [0-4]      number of bytes for message data
//   [?]        message data
//
//  COMMAND_SEND_REPLY (root <- node)
//   [1] U8     number of bytes for actor uuid
//   [?]        actor uuid as string
//   [0-4]      number of bytes for message data
//   [?]        message data
//

void cork(int fd) {
    int state = 0;
    setsockopt (fd, IPPROTO_TCP, TCP_NODELAY, &state, sizeof(state));
}

void uncork(int fd) {
    int state = 1;
    setsockopt (fd, IPPROTO_TCP, TCP_NODELAY, &state, sizeof(state));
    send(fd, &state, 0, sendFlags);
}


// MARK: - COMMANDS

int recvall(int fd, void * ptr, int size) {
    // keep reading until we receive all of the data we asked for. Fail if we fail.
    char * cptr = ptr;
    char * start_ptr = ptr;
    char * end_ptr = ptr + size;
    
    while (cptr < end_ptr) {
        ssize_t bytes_read = recv(fd, cptr, end_ptr - cptr, 0);
        if (bytes_read <= 0) {
            return (int)bytes_read;
        }
        cptr += bytes_read;
    }
    
    return size;
}

int sendall(int fd, void * ptr, int size) {
    // keep sending until we send all of the data we asked for. Fail if we fail.
    char * cptr = ptr;
    char * start_ptr = ptr;
    char * end_ptr = ptr + size;
    
    while (cptr < end_ptr) {
        ssize_t bytes_read = send(fd, cptr, end_ptr - cptr, sendFlags);
        if (bytes_read <= 0) {
            return -1;
        }
        cptr += bytes_read;
    }
    
    return size;
}

bool read_int(int socketfd, uint32_t * count) {
    if (recvall(socketfd, count, sizeof(uint32_t)) <= 0) {
        return false;
    }
    *count = ntohl(*count);
    return true;
}

char * read_intcount_buffer(int socketfd, uint32_t * count) {
    if (recvall(socketfd, count, sizeof(uint32_t)) <= 0) {
        return NULL;
    }
    *count = ntohl(*count);
    
    if (*count == 0) {
        return NULL;
    }
    
    char * bytes = malloc(*count);
    if (recvall(socketfd, bytes, *count) <= 0) {
        return NULL;
    }
    return bytes;
}

bool read_bytecount_buffer(int socketfd, char * dst, size_t max_length) {
    uint8_t count = 0;
    recvall(socketfd, &count, 1);
    
    if (count >= max_length) {
        close_socket(socketfd);
        return false;
    }
    recvall(socketfd, dst, count);
    return true;
}

uint8_t read_command(int socketfd) {
    uint8_t command = COMMAND_NULL;
    int result = recvall(socketfd, &command, 1);
    if(result <= 0) {
        return COMMAND_NULL;
    }
    return command;
}

void send_version_check(int socketfd) {
    char buffer[512];
    int idx = 0;
    
    buffer[idx++] = COMMAND_VERSION_CHECK;
    
    uint8_t uuid_count = strlen(BUILD_VERSION_UUID);
    buffer[idx++] = uuid_count;
    memcpy(buffer + idx, BUILD_VERSION_UUID, uuid_count);
    idx += uuid_count;
        
    sendall(socketfd, buffer, idx);
}

void send_core_count(int socketfd) {
    char command = COMMAND_CORE_COUNT;
    sendall(socketfd, &command, sizeof(command));
    uint32_t core_count = ponyint_core_count();
    core_count = htonl(core_count);
    sendall(socketfd, &core_count, sizeof(core_count));
}

int send_heartbeat(int socketfd) {
    char command = COMMAND_HEARTBEAT;
    return sendall(socketfd, &command, sizeof(command));
}

int send_destroy_actor_ack(int socketfd) {
    char command = COMMAND_DESTROY_ACTOR_ACK;
    return sendall(socketfd, &command, sizeof(command));
}

void send_register_with_root(int socketfd, const char * registrationString) {
    char buffer[512];
    int idx = 0;
    
    buffer[idx++] = COMMAND_REGISTER_WITH_ROOT;
    sendall(socketfd, buffer, idx);
    
    uint32_t count = (uint32_t)strnlen(registrationString, 4090) + 1;
    
    uint32_t net_count = htonl(count);
    if (sendall(socketfd, &net_count, sizeof(net_count)) < 0) {
        return;
    }
    
    if (sendall(socketfd, (char *)registrationString, count) < 0) {
        return;
    }
        
#if REMOTE_DEBUG
    pony_syslog2("Flynn", "[%d] registering with root on socket\n", socketfd);
#endif
}

void send_create_actor(int socketfd, const char * actorUUID, const char * actorType) {
    char buffer[512];
    int idx = 0;
    
    buffer[idx++] = COMMAND_CREATE_ACTOR;
    
    uint8_t uuid_count = strlen(actorUUID);
    buffer[idx++] = uuid_count;
    memcpy(buffer + idx, actorUUID, uuid_count);
    idx += uuid_count;
    
    uint8_t type_count = strlen(actorType);
    buffer[idx++] = type_count;
    memcpy(buffer + idx, actorType, type_count);
    idx += type_count;
    
    sendall(socketfd, buffer, idx);
    
#if REMOTE_DEBUG
    pony_syslog2("Flynn", "[%d] sending create actor to socket\n", socketfd);
#endif
}

void send_destroy_actor(int socketfd, const char * actorUUID) {
    char buffer[512];
    int idx = 0;
    
    buffer[idx++] = COMMAND_DESTROY_ACTOR;
    
    uint8_t uuid_count = strlen(actorUUID);
    buffer[idx++] = uuid_count;
    memcpy(buffer + idx, actorUUID, uuid_count);
    idx += uuid_count;
        
    sendall(socketfd, buffer, idx);
    
#if REMOTE_DEBUG
    pony_syslog2("Flynn", "[%d] root sending destroy actor to socket\n", socketfd);
#endif
}

int send_message(int socketfd, int messageID, const char * actorUUID, const char * behaviorType, const void * bytes, uint32_t count) {
    char buffer[512];
    int idx = 0;
    
    buffer[idx++] = COMMAND_SEND_MESSAGE;
    
    uint8_t uuid_count = strlen(actorUUID);
    buffer[idx++] = uuid_count;
    memcpy(buffer + idx, actorUUID, uuid_count);
    idx += uuid_count;
    
    uint8_t behavior_count = strlen(behaviorType);
    buffer[idx++] = behavior_count;
    memcpy(buffer + idx, behaviorType, behavior_count);
    idx += behavior_count;
        
    if (sendall(socketfd, buffer, idx) < 0) {
        return -1;
    }
    
    uint32_t net_messageID = htonl(messageID);
    if (sendall(socketfd, &net_messageID, sizeof(net_messageID)) < 0) {
        return -1;
    }
    
    uint32_t net_count = htonl(count);
    if (sendall(socketfd, &net_count, sizeof(net_count)) < 0) {
        return -1;
    }
    
    if (sendall(socketfd, (char *)bytes, count) < 0) {
        return -1;
    }
    
#if REMOTE_DEBUG
    pony_syslog2("Flynn", "[%d] root sending message id %d to socket\n", socketfd, messageID);
#endif
    
    return idx + sizeof(net_count) + count;
}

void send_reply(int socketfd, uint32_t messageID, const void * bytes, uint32_t count) {
    char buffer[512];
    int idx = 0;
    
    buffer[idx++] = COMMAND_SEND_REPLY;
    sendall(socketfd, buffer, idx);
    
    uint32_t net_messageID = htonl(messageID);
    sendall(socketfd, &net_messageID, sizeof(net_messageID));
    
    uint32_t net_count = htonl(count);
    sendall(socketfd, &net_count, sizeof(net_count));
    
    sendall(socketfd, (char *)bytes, count);
    
#if REMOTE_DEBUG
    pony_syslog2("Flynn", "[%d] node sending reply to messageID %d\n", socketfd, messageID);
#endif
}

// MARK: - SHUTDOWN

int pony_remote_enabled() {
    return 1;
}

void pony_remote_shutdown() {
    root_shutdown();
    node_shutdown();
}

void close_socket(int fd) {
    shutdown(fd, SHUT_RDWR);
    close(fd);
}

#else

int pony_remote_enabled() {
    return 0;
}

void pony_remote_shutdown() {
    
}

#endif
