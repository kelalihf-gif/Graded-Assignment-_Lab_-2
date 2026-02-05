
// signal_demo.c
// Parent runs indefinitely; child1 sends SIGTERM after 5s; child2 sends SIGINT after 10s.
// Parent handles SIGTERM by logging/continuing and SIGINT by graceful exit (reap children).

#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <errno.h>

static volatile sig_atomic_t got_sigterm = 0;
static volatile sig_atomic_t got_sigint  = 0;

static void on_sigterm(int sig){ (void)sig; got_sigterm = 1; }
static void on_sigint (int sig){ (void)sig; got_sigint  = 1; }

static void install_handlers(void){
    struct sigaction sa;
    sa.sa_flags = SA_RESTART;
    sigemptyset(&sa.sa_mask);
    sa.sa_handler = on_sigterm; if (sigaction(SIGTERM, &sa, NULL)==-1){ perror("sigaction(SIGTERM)"); exit(1);} 
    sa.sa_handler = on_sigint;  if (sigaction(SIGINT,  &sa, NULL)==-1){ perror("sigaction(SIGINT)");  exit(1);} 
}

static void reap_children(void){
    int status; pid_t pid;
    while ((pid = waitpid(-1, &status, 0)) > 0){
        if (WIFEXITED(status)) printf("[parent] Reaped child PID=%d (exit=%d)
", pid, WEXITSTATUS(status));
        else if (WIFSIGNALED(status)) printf("[parent] Reaped child PID=%d (signal=%d)
", pid, WTERMSIG(status));
        else printf("[parent] Reaped child PID=%d (status change)
", pid);
        fflush(stdout);
    }
}

int main(void){
    install_handlers();
    pid_t ppid = getpid();
    printf("[parent] PID=%d — starting up
", ppid); fflush(stdout);

    pid_t c1 = fork();
    if (c1 == 0){ sleep(5); printf("  [child1] PID=%d sending SIGTERM to %d
", getpid(), getppid()); fflush(stdout); kill(getppid(), SIGTERM); _exit(0);} 
    else if (c1 < 0){ perror("fork child1"); return 1; }

    pid_t c2 = fork();
    if (c2 == 0){ sleep(10); printf("  [child2] PID=%d sending SIGINT to %d
", getpid(), getppid()); fflush(stdout); kill(getppid(), SIGINT); _exit(0);} 
    else if (c2 < 0){ perror("fork child2"); return 1; }

    printf("[parent] Children created: c1=%d (SIGTERM@5s), c2=%d (SIGINT@10s)
", c1, c2); fflush(stdout);

    int term_logged = 0;
    for(;;){
        if (got_sigterm && !term_logged){ printf("[parent] SIGTERM received — continuing...
"); fflush(stdout); term_logged = 1; }
        if (got_sigint){ printf("[parent] SIGINT received — graceful shutdown...
"); fflush(stdout); break; }
        printf("[parent] Heartbeat... PID=%d
", ppid); fflush(stdout); sleep(1);
    }

    reap_children();
    printf("[parent] Clean exit. Goodbye.
");
    return 0;
}
