$c1 = comdat any
$c2 = comdat any

; Since both used_global and and unused_fn share a COMDAT, they should both be kept,
; keeping the !associated metadata pointing at unused_fn
; CHECK: @used_global = internal global i8 0, comdat($c1), !associated !0
@global_dangling_assoc = global i8 0, section "my_sec", comdat($c1), !associated !0
@global_good_assoc = global i8 0, section "my_sec", comdat($c2), !associated !1

@llvm.used = appending global [3 x i8*] [i8* @global_dangling_assoc, i8* @global_good_assoc, i8* bitcast(void()* @unused_fn to i8*)], section "llvm.metadata"

; CHECK: define internal void @unused_fn() comdat($c1) {
define void @unused_fn() comdat($c1) {
  ret void
}

define void @used_fn() comdat($c2) {
  ret void
}

; CHECK: !0 = !{void ()* @unused_fn}
!0 = !{void ()* @unused_fn}
!1 = !{void()* @used_fn}
