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

static int mib[4] = { -1, -1, -1, -1 };

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

void
_info(int pid)
    PREINIT:
    PPCODE:
