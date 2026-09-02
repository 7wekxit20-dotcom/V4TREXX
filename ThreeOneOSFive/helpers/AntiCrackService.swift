import Foundation
import Darwin

enum AntiCrackService {
    /// Performs runtime anti-debugging and anti-tampering checks.
    /// Exits or invalidates execution if an active debugger or hook engine is detected.
    static func enforceProtection() {
        #if !DEBUG
        // 1. Sysctl P_TRACED Debugger Detection
        if isDebuggerAttached() {
            log("security: Debugger detection triggered.")
            exit(0)
        }

        // 2. Deny Attach via ptrace
        denyPtraceAttach()

        // 3. Detect Injection of Frida / Cycript / Substrate / MobileSubstrate
        if isHookFrameworkLoaded() {
            log("security: Hook framework detected.")
            exit(0)
        }
        #endif
    }

    private static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]

        let junk = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")

        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    private static func denyPtraceAttach() {
        typealias PTraceType = @convention(c) (Int32, pid_t, caddr_t?, Int32) -> Int32
        let handle = dlopen(nil, RTLD_GLOBAL | RTLD_NOW)
        if let sym = dlsym(handle, "ptrace") {
            let ptrace = unsafeBitCast(sym, to: PTraceType.self)
            _ = ptrace(31, 0, nil, 0) // PT_DENY_ATTACH = 31
        }
    }

    private static func isHookFrameworkLoaded() -> Bool {
        let suspiciousLibraries = [
            "FridaGadget",
            "frida",
            "cynject",
            "libcycript",
            "SubstrateLoader",
            "MobileSubstrate"
        ]

        let count = _dyld_image_count()
        for i in 0..<count {
            if let nameC = _dyld_get_image_name(i) {
                let name = String(cString: nameC)
                for suspicious in suspiciousLibraries {
                    if name.lowercased().contains(suspicious.lowercased()) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
