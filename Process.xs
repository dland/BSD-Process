#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/* define _FreeBSD_version where applicable */
#if __FreeBSD__ >= 2
#include <osreldate.h>
#endif

#include <kvm.h>
#include <sys/types.h>
#include <sys/sysctl.h> /* KERN_PROC_* */
#include <pwd.h> /* struct passwd */
#include <grp.h> /* struct group */

#include <sys/param.h> /* struct kinfo_proc prereq*/
#if __FreeBSD__ >= 5
#define cv bsd_cv
#endif
#include <sys/user.h>  /* struct kinfo_proc */
#if __FreeBSD__ >= 5
#undef cv
#endif

#include <fcntl.h> /* O_RDONLY */
#include <limits.h> /* _POSIX2_LINE_MAX */

#define PATH_DEV_NULL "/dev/null"

#define TIME_FRAC(t) ( (double)(t).tv_sec + (double)(t).tv_usec/1000000 )
#define P_FLAG(f)    ((ki.ki_flag   & f) ? 1 : 0))
#define KI_FLAG(f)   ((ki.ki_kiflag & f) ? 1 : 0))

static int proc_info_mib[4] = { -1, -1, -1, -1 };

MODULE = BSD::Process   PACKAGE = BSD::Process

PROTOTYPES: ENABLE

short
max_kernel_groups()
    CODE:
        RETVAL = KI_NGROUPS;
    OUTPUT:
        RETVAL

void
_list(int request, int param)
    PREINIT:
        struct kinfo_proc *kip;
        kvm_t *kd;
        int nr;
        char errbuf[_POSIX2_LINE_MAX];
        const char *nlistf, *memf;
    PPCODE:
        nlistf = memf = PATH_DEV_NULL;
        kd = kvm_openfiles(nlistf, memf, NULL, O_RDONLY, errbuf);
        switch(request) {
        case 0:
            kip = kvm_getprocs(kd, KERN_PROC_ALL, 0, &nr);
            break;
        case 1:
            kip = kvm_getprocs(kd, KERN_PROC_PID, param, &nr);
            break;
        case 2:
            kip = kvm_getprocs(kd, KERN_PROC_PGRP, param, &nr);
            break;
        case 3:
            kip = kvm_getprocs(kd, KERN_PROC_SESSION, param, &nr);
            break;
        default:
            kip = kvm_getprocs(kd, KERN_PROC_ALL, 0, &nr);
            break;
        }
        if (kip) {
            int p;
            for (p = 0; p < nr; ++kip, ++p)
                mPUSHi(kip->ki_pid);
        }
        else {
            warn("list() failed: %s\n", kvm_geterr(kd));
            XSRETURN_UNDEF;
        }
        XSRETURN(nr);

SV *
_info(int pid, int resolve)
    PREINIT:
        /* TODO: int pid should be pid_t pid */
        size_t len;
        struct kinfo_proc ki;
        kvm_t *kd;
        char errbuf[_POSIX2_LINE_MAX];
        const char *nlistf, *memf;
        char **argv;
        SV *argsv;
        struct passwd *pw;
        struct group *gr;
        short g;
        AV *grlist;
        struct rusage *rp;
        HV *h;

    CODE:
        if (proc_info_mib[0] == -1) {
            len = sizeof(proc_info_mib)/sizeof(proc_info_mib[0]);
            if (sysctlnametomib("kern.proc.pid", proc_info_mib, &len) == -1) {
                warn( "kern.proc.pid is insane\n");
                XSRETURN_UNDEF;
            }
        }
        proc_info_mib[3] = pid;
        len = sizeof(ki);
        if (sysctl(proc_info_mib, sizeof(proc_info_mib)/sizeof(proc_info_mib[0]), &ki, &len, NULL, 0) == -1) {
            /* process identified by pid has probably exited */
            XSRETURN_UNDEF;
        }
        nlistf = memf = PATH_DEV_NULL;
        kd = kvm_openfiles(nlistf, memf, NULL, O_RDONLY, errbuf);
        argv = kvm_getargv(kd, &ki, 0);

        /*
        if( *argv ) {
            len = strlen(*argv);
            argsv = newSVpvn(*argv, len);
            while (*++argv) {
                sv_catpvn(argsv, " ", 1);
                sv_catpvn(argsv, *argv, strlen(*argv));
                len += strlen(*argv)+1;
            }
            warn( "%s\n", SvPVX(argsv) );
            hv_store(h, "args", 4, newSVpvn(SvPVX(argsv), 0), 0);
        }
        else {
            hv_store(h, "args", 4, newSVpvn("-", 1), 0);
        }
        */

        h = (HV *)sv_2mortal((SV *)newHV());
        RETVAL = newRV((SV *)h);
        hv_store(h, "pid",   3, newSViv(ki.ki_pid), 0);
        hv_store(h, "ppid",  4, newSViv(ki.ki_ppid), 0);
        hv_store(h, "pgid",  4, newSViv(ki.ki_pgid), 0);
        hv_store(h, "tpgid", 5, newSViv(ki.ki_tpgid), 0);
        hv_store(h, "sid",   3, newSViv(ki.ki_sid), 0);
        hv_store(h, "tsid",  4, newSViv(ki.ki_tsid), 0);
        hv_store(h, "jobc",  4, newSViv(ki.ki_jobc), 0);
        if (!resolve) {
            /* numeric user and group ids */
            hv_store(h, "uid",   3, newSViv(ki.ki_uid), 0);
            hv_store(h, "ruid",  4, newSViv(ki.ki_ruid), 0);
            hv_store(h, "svuid", 5, newSViv(ki.ki_svuid), 0);
            hv_store(h, "rgid",  4, newSViv(ki.ki_rgid), 0);
            hv_store(h, "svgid", 5, newSViv(ki.ki_svgid), 0);
        }
        else {
            /* first, the user ids */
            pw = getpwuid(ki.ki_uid);
            if (!pw) {
                /* shouldn't ever happen... */
                hv_store(h, "uid", 3, newSViv(ki.ki_uid), 0);
            }
            else {
                len = strlen(pw->pw_name);
                hv_store(h, "uid", 3, newSVpvn(pw->pw_name,len), 0);
            }

            /* if the real uid is the same, use the previous results */
            if (ki.ki_ruid != ki.ki_uid) {
                pw = getpwuid(ki.ki_ruid);
                if (pw) {
                    len = strlen(pw->pw_name);
                }
            }
            if (pw) {
                hv_store(h, "ruid", 4, newSVpvn(pw->pw_name,len), 0);
            }
            else {
                hv_store(h, "ruid", 4, newSViv(ki.ki_ruid), 0);
            }

            if (ki.ki_svuid != ki.ki_uid) {
                pw = getpwuid(ki.ki_svuid);
                len = strlen(pw->pw_name);
            }
            if (pw) {
                hv_store(h, "svuid", 5, newSVpvn(pw->pw_name,len), 0);
            }
            else {
                hv_store(h, "svuid", 5, newSViv(ki.ki_svuid), 0);
            }

            /* and now the group ids */
            gr = getgrgid(ki.ki_rgid);
            if (gr) {
                len = strlen(gr->gr_name);
                hv_store(h, "rgid", 4, newSVpvn(gr->gr_name,len), 0);
            }
            else {
                hv_store(h, "rgid", 4, newSViv(ki.ki_rgid), 0);
            }

            if (ki.ki_svgid != ki.ki_rgid) {
                gr = getgrgid(ki.ki_svgid);
                if (gr) {
                    len = strlen(gr->gr_name);
                }
            }
            if (gr) {
                hv_store(h, "svgid", 5, newSVpvn(gr->gr_name,len), 0);
            }
            else {
                hv_store(h, "svgid", 5, newSViv(ki.ki_svgid), 0);
            }
        }

        # deal with groups array
        grlist = (AV *)sv_2mortal((SV *)newAV());
        for (g = 0; g < ki.ki_ngroups; ++g) {
            if (resolve && (gr = getgrgid(ki.ki_groups[g]))) {
                av_push(grlist, newSVpvn(gr->gr_name, strlen(gr->gr_name)));
            }
            else {
                av_push(grlist, newSViv(ki.ki_groups[g]));
            }
        }
        hv_store(h, "groups", 6, newRV((SV *)grlist), 0);

        hv_store(h, "ngroups",   7, newSViv(ki.ki_ngroups), 0);
        hv_store(h, "size",      4, newSViv(ki.ki_size), 0);
        hv_store(h, "rssize",    6, newSViv(ki.ki_rssize), 0);
        hv_store(h, "swrss",     5, newSViv(ki.ki_swrss), 0);
        hv_store(h, "tsize",     5, newSViv(ki.ki_tsize), 0);
        hv_store(h, "dsize",     5, newSViv(ki.ki_dsize), 0);
        hv_store(h, "ssize",     5, newSViv(ki.ki_ssize), 0);
        hv_store(h, "xstat",     5, newSViv(ki.ki_xstat), 0);
        hv_store(h, "acflag",    6, newSViv(ki.ki_acflag), 0);
        hv_store(h, "pctcpu",    6, newSViv(ki.ki_pctcpu), 0);
        hv_store(h, "estcpu",    6, newSViv(ki.ki_estcpu), 0);
        hv_store(h, "slptime",   7, newSViv(ki.ki_slptime), 0);
        hv_store(h, "swtime",    6, newSViv(ki.ki_swtime), 0);
        hv_store(h, "runtime",   7, newSViv(ki.ki_runtime), 0);
        hv_store(h, "start",     5, newSVnv(TIME_FRAC(ki.ki_start)), 0);
        hv_store(h, "childtime", 9, newSVnv(TIME_FRAC(ki.ki_childtime)), 0);

        hv_store(h, "flag",         4, newSViv(ki.ki_flag), 0);
        hv_store(h, "advlock",      7, newSViv(P_FLAG(P_ADVLOCK), 0);
        hv_store(h, "controlt",     8, newSViv(P_FLAG(P_CONTROLT), 0);
        hv_store(h, "kthread",      7, newSViv(P_FLAG(P_KTHREAD), 0);
        hv_store(h, "noload",       6, newSViv(P_FLAG(P_NOLOAD), 0);
        hv_store(h, "ppwait",       6, newSViv(P_FLAG(P_PPWAIT), 0);
        hv_store(h, "profil",       6, newSViv(P_FLAG(P_PROFIL), 0);
        hv_store(h, "stopprof",     8, newSViv(P_FLAG(P_STOPPROF), 0);
        hv_store(h, "hadthreads",  10, newSViv(P_FLAG(P_HADTHREADS), 0);
        hv_store(h, "sugid",        5, newSViv(P_FLAG(P_SUGID), 0);
        hv_store(h, "system",       6, newSViv(P_FLAG(P_SYSTEM), 0);
        hv_store(h, "single_exit", 11, newSViv(P_FLAG(P_SINGLE_EXIT), 0);
        hv_store(h, "traced",       6, newSViv(P_FLAG(P_TRACED), 0);
        hv_store(h, "waited",       6, newSViv(P_FLAG(P_WAITED), 0);
        hv_store(h, "wexit",        5, newSViv(P_FLAG(P_WEXIT), 0);
        hv_store(h, "exec",         4, newSViv(P_FLAG(P_EXEC), 0);

        hv_store(h, "kiflag",    6, newSViv(ki.ki_kiflag), 0);
        hv_store(h, "locked",    6, newSViv(KI_FLAG(KI_LOCKBLOCK), 0);
        hv_store(h, "isctty",    6, newSViv(KI_FLAG(KI_CTTY), 0);
        hv_store(h, "issleader", 9, newSViv(KI_FLAG(KI_SLEADER), 0);

        hv_store(h, "stat",        4, newSViv((int)ki.ki_stat), 0);
        hv_store(h, "stat_1",      6, newSViv((int)ki.ki_stat == 1 ? 1 : 0), 0);
        hv_store(h, "stat_2",      6, newSViv((int)ki.ki_stat == 2 ? 1 : 0), 0);
        hv_store(h, "stat_3",      6, newSViv((int)ki.ki_stat == 3 ? 1 : 0), 0);
        hv_store(h, "stat_4",      6, newSViv((int)ki.ki_stat == 4 ? 1 : 0), 0);
        hv_store(h, "stat_5",      6, newSViv((int)ki.ki_stat == 5 ? 1 : 0), 0);
        hv_store(h, "stat_6",      6, newSViv((int)ki.ki_stat == 6 ? 1 : 0), 0);
        hv_store(h, "stat_7",      6, newSViv((int)ki.ki_stat == 7 ? 1 : 0), 0);
        hv_store(h, "nice",        4, newSViv(ki.ki_nice), 0);
        hv_store(h, "lock",        4, newSViv(ki.ki_lock), 0);
        hv_store(h, "rqindex",     7, newSViv(ki.ki_rqindex), 0);
        hv_store(h, "oncpu",       5, newSViv(ki.ki_oncpu), 0);
        hv_store(h, "lastcpu",     7, newSViv(ki.ki_lastcpu), 0);
        hv_store(h, "ocomm",       5, newSVpv(ki.ki_ocomm, 0), 0);
        hv_store(h, "wmesg",       5, newSVpv(ki.ki_wmesg, 0), 0);
        hv_store(h, "login",       5, newSVpv(ki.ki_login, 0), 0);
        hv_store(h, "lockname",    8, newSVpv(ki.ki_lockname, 0), 0);
        hv_store(h, "comm",        4, newSVpv(ki.ki_comm, 0), 0);
        hv_store(h, "emul",        4, newSVpv(ki.ki_emul, 0), 0);
        hv_store(h, "jid",         3, newSViv(ki.ki_jid), 0);
        hv_store(h, "numthreads", 10, newSViv(ki.ki_numthreads), 0);

        hv_store(h, "pri_class",   9, newSViv(ki.ki_pri.pri_class), 0);
        hv_store(h, "pri_level",   9, newSViv(ki.ki_pri.pri_level), 0);
        hv_store(h, "pri_native", 10, newSViv(ki.ki_pri.pri_native), 0);
        hv_store(h, "pri_user",    8, newSViv(ki.ki_pri.pri_user), 0);

        rp = &ki.ki_rusage;
        hv_store(h, "utime",    5, newSVnv(TIME_FRAC(rp->ru_utime)), 0);
        hv_store(h, "stime",    5, newSVnv(TIME_FRAC(rp->ru_stime)), 0);
        hv_store(h, "maxrss",   6, newSVnv(rp->ru_maxrss), 0);
        hv_store(h, "ixrss",    5, newSVnv(rp->ru_ixrss), 0);
        hv_store(h, "idrss",    5, newSVnv(rp->ru_idrss), 0);
        hv_store(h, "isrss",    5, newSVnv(rp->ru_isrss), 0);
        hv_store(h, "minflt",   6, newSVnv(rp->ru_minflt), 0);
        hv_store(h, "majflt",   6, newSVnv(rp->ru_majflt), 0);
        hv_store(h, "nswap",    5, newSVnv(rp->ru_nswap), 0);
        hv_store(h, "inblock",  7, newSVnv(rp->ru_inblock), 0);
        hv_store(h, "oublock",  7, newSVnv(rp->ru_oublock), 0);
        hv_store(h, "msgsnd",   6, newSVnv(rp->ru_msgsnd), 0);
        hv_store(h, "msgrcv",   6, newSVnv(rp->ru_msgrcv), 0);
        hv_store(h, "nsignals", 8, newSViv(rp->ru_nsignals), 0);
        hv_store(h, "nvcsw",    5, newSViv(rp->ru_nvcsw), 0);
        hv_store(h, "nivcsw",   6, newSViv(rp->ru_nivcsw), 0);

        rp = &ki.ki_rusage_ch;
        hv_store(h, "utime_ch",    3+5, newSVnv(TIME_FRAC(rp->ru_utime)), 0);
        hv_store(h, "stime_ch",    3+5, newSVnv(TIME_FRAC(rp->ru_stime)), 0);
        hv_store(h, "maxrss_ch",   3+6, newSVnv(rp->ru_maxrss), 0);
        hv_store(h, "ixrss_ch",    3+5, newSVnv(rp->ru_ixrss), 0);
        hv_store(h, "idrss_ch",    3+5, newSVnv(rp->ru_idrss), 0);
        hv_store(h, "isrss_ch",    3+5, newSVnv(rp->ru_isrss), 0);
        hv_store(h, "minflt_ch",   3+6, newSVnv(rp->ru_minflt), 0);
        hv_store(h, "majflt_ch",   3+6, newSVnv(rp->ru_majflt), 0);
        hv_store(h, "nswap_ch",    3+5, newSVnv(rp->ru_nswap), 0);
        hv_store(h, "inblock_ch",  3+7, newSVnv(rp->ru_inblock), 0);
        hv_store(h, "oublock_ch",  3+7, newSVnv(rp->ru_oublock), 0);
        hv_store(h, "msgsnd_ch",   3+6, newSVnv(rp->ru_msgsnd), 0);
        hv_store(h, "msgrcv_ch",   3+6, newSVnv(rp->ru_msgrcv), 0);
        hv_store(h, "nsignals_ch", 3+8, newSViv(rp->ru_nsignals), 0);
        hv_store(h, "nvcsw_ch",    3+5, newSViv(rp->ru_nvcsw), 0);
        hv_store(h, "nivcsw_ch",   3+6, newSViv(rp->ru_nivcsw), 0);

    OUTPUT:
        RETVAL
