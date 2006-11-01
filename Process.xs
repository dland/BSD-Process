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

static int proc_info_mib[4] = { -1, -1, -1, -1 };

MODULE = BSD::Process   PACKAGE = BSD::Process

PROTOTYPES: ENABLE

void
list()
    PREINIT:
        struct kinfo_proc *kip;
        kvm_t *kd;
        int nr;
        char errbuf[_POSIX2_LINE_MAX];
        const char *nlistf, *memf;
    PPCODE:
        nlistf = memf = PATH_DEV_NULL;
        kd = kvm_openfiles(nlistf, memf, NULL, O_RDONLY, errbuf);
        if(kip = kvm_getprocs(kd, KERN_PROC_ALL, 0, &nr)) {
            int p;
            for (p = 0; p < nr; ++kip, ++p)
                mPUSHi(kip->ki_pid);
        }
        else {
            warn("%s\n", kvm_geterr(kd));
            XSRETURN_UNDEF;
        }
        XSRETURN(nr);

SV *
_info(int pid)
    PREINIT:
        /* TODO: int pid should be pid_t pid */
        struct kinfo_proc ki;
        struct rusage *rp;
        size_t len;
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
            warn( "kern.proc.pid.%d is insane\n", pid);
            XSRETURN_UNDEF;
        }
        h = (HV *)sv_2mortal((SV *)newHV());
        RETVAL = newRV((SV *)h);
        hv_store(h, "pid",             3, newSViv(ki.ki_pid), 0);
        hv_store(h, "ppid",            4, newSViv(ki.ki_ppid), 0);
        hv_store(h, "pgid",            4, newSViv(ki.ki_pgid), 0);
        hv_store(h, "tpgid",           5, newSViv(ki.ki_tpgid), 0);
        hv_store(h, "sid",             3, newSViv(ki.ki_sid), 0);
        hv_store(h, "tsid",            4, newSViv(ki.ki_tsid), 0);
        hv_store(h, "jobc",            4, newSViv(ki.ki_jobc), 0);
        hv_store(h, "uid",             3, newSViv(ki.ki_uid), 0);
        hv_store(h, "ruid",            4, newSViv(ki.ki_ruid), 0);
        hv_store(h, "svuid",           5, newSViv(ki.ki_svuid), 0);
        hv_store(h, "rgid",            4, newSViv(ki.ki_rgid), 0);
        hv_store(h, "svgid",           5, newSViv(ki.ki_svgid), 0);
        hv_store(h, "ngroups",         7, newSViv(ki.ki_ngroups), 0);
        hv_store(h, "size",            4, newSViv(ki.ki_size), 0);
        hv_store(h, "rssize",          6, newSViv(ki.ki_rssize), 0);
        hv_store(h, "swrss",           5, newSViv(ki.ki_swrss), 0);
        hv_store(h, "tsize",           5, newSViv(ki.ki_tsize), 0);
        hv_store(h, "dsize",           5, newSViv(ki.ki_dsize), 0);
        hv_store(h, "ssize",           5, newSViv(ki.ki_ssize), 0);
        hv_store(h, "xstat",           5, newSViv(ki.ki_xstat), 0);
        hv_store(h, "acflag",          6, newSViv(ki.ki_acflag), 0);
        hv_store(h, "pctcpu",          6, newSViv(ki.ki_pctcpu), 0);
        hv_store(h, "estcpu",          6, newSViv(ki.ki_estcpu), 0);
        hv_store(h, "slptime",         7, newSViv(ki.ki_slptime), 0);
        hv_store(h, "swtime",          6, newSViv(ki.ki_swtime), 0);
        hv_store(h, "runtime",         7, newSViv(ki.ki_runtime), 0);
        hv_store(h, "start",           5, newSVnv(TIME_FRAC(ki.ki_start)), 0);
        hv_store(h, "childtime",       9, newSVnv(TIME_FRAC(ki.ki_childtime)), 0);
        hv_store(h, "stat",            4, newSViv(ki.ki_stat), 0);
        hv_store(h, "nice",            4, newSViv(ki.ki_nice), 0);
        hv_store(h, "ocomm",           5, newSVpv(ki.ki_ocomm, 0), 0);
        hv_store(h, "comm",            4, newSVpv(ki.ki_comm, 0), 0);
        hv_store(h, "wmesg",           5, newSVpv(ki.ki_wmesg, 0), 0);
        hv_store(h, "login",           5, newSVpv(ki.ki_login, 0), 0);
        hv_store(h, "jid",             3, newSViv(ki.ki_jid), 0);
        hv_store(h, "numthreads",     10, newSViv(ki.ki_numthreads), 0);
        hv_store(h, "pri_class",       9, newSViv(ki.ki_pri.pri_class), 0);
        hv_store(h, "pri_level",       9, newSViv(ki.ki_pri.pri_level), 0);
        hv_store(h, "pri_native",     10, newSViv(ki.ki_pri.pri_native), 0);
        hv_store(h, "pri_user",        8, newSViv(ki.ki_pri.pri_user), 0);

        rp = &ki.ki_rusage;
        hv_store(h, "utime",           5, newSVnv(TIME_FRAC(rp->ru_utime)), 0);
        hv_store(h, "utime",           5, newSVnv(TIME_FRAC(rp->ru_stime)), 0);
    OUTPUT:
        RETVAL
