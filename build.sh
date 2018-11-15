rm -f opt_ir.llc opt_final.o
$(echo $LLVM_ROOT)opt -internalize -internalize-public-api-list c1 -internalize-public-api-list c2 -globaldce bad_ir.ll -o opt_ir.llc
$(echo $LLVM_ROOT)llc opt_ir.llc -filetype=obj -o opt_final.o
ld opt_final.o
