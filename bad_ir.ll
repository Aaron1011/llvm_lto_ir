$c1 = comdat any
$c2 = comdat any

; We create two globals. Each one has a corresponding function that it targets with
; !associated metadata, and shares a comdat with
@global_dangling_assoc = global i8 0, section "my_sec", comdat($c1), !associated !0
@global_good_assoc = global i8 0, section "my_sec", comdat($c2), !associated !1

; Any globals with !associated metadata should be in llvm.used or llvm.compilder.used,
; per the LLVM language reference.
; In a real program, @used_fn would be used by another function. For simplicity, we
; we just add it to llvm.used
@llvm.used = appending global [3 x i8*] [i8* @global_dangling_assoc, i8* @global_good_assoc, i8* bitcast(void()* @used_fn to i8*)], section "llvm.metadata"

define void @unused_fn() comdat($c1) {
  ret void
}

define void @used_fn() comdat($c2) {
  ret void
}

; When internalization is run, both comdats will be dropped
; This allows GlobalDCE to delete unused_fn, removing the !associated metadata on @global_dangling_assoc
; in the process.

; In the final binary, this results in one "my_sec" section having SHF_LINK_ORDER set
; (due to the !associated metadata), and another "my_sec" section without SHF_LINK_ORDER
; (due to the !assocaited metadata on @global_dangling_assoc being removed during GlobalDCE)
; This causes the BFD linker to emit an error due to there being "my_sec" sections both with 
; and with SHF_LINK_ORDER set

!0 = !{void ()* @unused_fn}
!1 = !{void()* @used_fn}
