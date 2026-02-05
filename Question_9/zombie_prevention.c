
// zombie_prevention.c
// Demonstrates preventing zombie processes by reaping children with waitpid().
// - Creates multiple child processes
// - Reaps them via a SIGCHLD handler using waitpid(..., WNOHANG)
// - Parent prints the PID of each child it cleans up

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>
#include <errno.h>
#include <time.h>

static volatile sig_atomic_t reaped_count = 0;
static int target_children = 0;

static void sigchld_handler(int sig) {
    (void)sig;
    int saved_errno = errno;
    while (1) {
        int status;
        pid_t pid = waitpid(-1, &status, WNOHANG);
        if (pid > 0) {
            if (WIFEXITED(status)) {
                printf("[parent] Reaped child PID=%d (exit=%d)
", pid, WEXITSTATUS(status));
            } else if (WIFSIGNALED(status)) {
                printf("[parent] Reaped child PID=%d (killed by signal %d)
", pid, WTERMSIG(status));
            } else {
                printf("[parent] Reaped child PID=%d (status changed)
", pid);
            }
            fflush(stdout);
            reaped_count++;
        } else if (pid == 0) {
            break;
        } else {
            if (errno == ECHILD) break;
            if (errno == EINTR) continue;
            break;
        }
    }
    errno = saved_errno;
}

int main(int argc, char *argv[]) {
    target_children = (argc >= 2) ? atoi(argv[1]) : 5;
    if (target_children <= 0) {
        fprintf(stderr, "Usage: %s [num_children]
", argv[0]);
        fprintf(stderr, "num_children must be a positive integer (default 5)
");
        return 1;
    }

    struct sigaction sa;
    sa.sa_handler = sigchld_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART | SA_NOCLDSTOP;
    if (sigaction(SIGCHLD, &sa, NULL) == -1) { perror("sigaction"); return 1; }

    printf("[parent] PID=%d — creating %d children
", getpid(), target_children);
    fflush(stdout);

    for (int i = 0; i < target_children; i++) {
        pid_t pid = fork();
        if (pid < 0) { perror("fork"); break; }
        else if (pid == 0) {
            srand((unsigned int)(getpid() ^ time(NULL)));
            int work = (rand() % 3) + 1;
            printf("  [child] PID=%d (ppid=%d) working for ~%d sec...
", getpid(), getppid(), work);
            fflush(stdout);
            sleep((unsigned int)work);
            _exit((i % 100));
        }
    }

    while (reaped_count < target_children) {
        usleep(100 * 1000);
    }

    printf("[parent] All children cleaned up. Reaped=%d
", reaped_count);
    return 0;
}
