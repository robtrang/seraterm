VPATH = src
DEPDIR := .deps

FOENIX = module/Calypsi-m68k-Foenix

# Common source files
ASM_SRCS =
C_SRCS = main.c

CFLAGS=-Iinclude

MODEL = --code-model=large --data-model=small
LIB_MODEL = lc-sd

FOENIX_LIB = $(FOENIX)/foenix-$(LIB_MODEL).a
A2560U_RULES = $(FOENIX)/linker-files/a2560u-simplified.scm
A2560K_RULES = $(FOENIX)/linker-files/a2560k-simplified.scm

# Object files
OBJS = $(ASM_SRCS:%.s=obj/%.o) $(C_SRCS:%.c=obj/%.o)
OBJS_DEBUG = $(ASM_SRCS:%.s=obj/%-debug.o) $(C_SRCS:%.c=obj/%-debug.o)

obj/%.o: %.s
	as68k --core=68000 $(MODEL) --target=Foenix --debug --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%.o: %.c $(DEPDIR)/%.d | $(DEPDIR)
	@cc68k $(CFLAGS) --core=68000 $(MODEL) --target=Foenix --debug --dependencies -MQ$@ >$(DEPDIR)/$*.d $<
	cc68k $(CFLAGS) --core=68000 $(MODEL) --target=Foenix --debug --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%-debug.o: %.s
	as68k --core=68000 $(MODEL) --debug --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%-debug.o: %.c $(DEPDIR)/%-debug.d | $(DEPDIR)
	@cc68k $(CFLAGS) --core=68000 $(MODEL) --debug --dependencies -MQ$@ >$(DEPDIR)/$*-debug.d $<
	cc68k $(CFLAGS) --core=68000 $(MODEL) --debug --list-file=$(@:%.o=%.lst) -o $@ $<

seraterm.pgz:  $(OBJS) $(FOENIX_LIB)
	ln68k -o $@ $^ $(A2560U_RULES) clib-68000-$(LIB_MODEL)-Foenix.a --output-format=pgz --list-file=seraterm.lst --cross-reference --rtattr printf=reduced --rtattr cstartup=Foenix_user

seraterm.hex:  $(OBJS) $(FOENIX_LIB)
	ln68k -o $@ $^ $(A2560K_RULES) clib-68000-$(LIB_MODEL)-Foenix.a --output-format=intel-hex --list-file=seraterm.lst --cross-reference --rtattr printf=reduced --rtattr cstartup=Foenix_morfe --stack-size=2000

$(FOENIX_LIB):
	(cd $(FOENIX) ; make all)

all:	seraterm.pgz seraterm.hex 

clean:
	-rm $(DEPFILES)
	-rm $(OBJS) $(OBJS:%.o=%.lst) $(OBJS_DEBUG) $(OBJS_DEBUG:%.o=%.lst) $(FOENIX_LIB)
	-rm -f seraterm.hex seraterm.pgz seraterm.lst
#	-(cd $(FOENIX) ; make clean)

$(DEPDIR): ; @mkdir -p $@

DEPFILES := $(C_SRCS:%.c=$(DEPDIR)/%.d) $(C_SRCS:%.c=$(DEPDIR)/%-debug.d)
$(DEPFILES):

include $(wildcard $(DEPFILES))
