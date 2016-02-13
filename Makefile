CC = gcc
CFLAGS = -Wall
DEBUG = -g
LIBS = -lm
OPT = -O3
export MAXKMERLENGTH = 64
export CATEGORIES = 2
DEF = -D MAXKMERLENGTH=$(MAXKMERLENGTH) -D CATEGORIES=$(CATEGORIES)
# VELVET_DIR=
# VELVET_DIR is in the environment

ifdef BIGASSEMBLY
override DEF := $(DEF) -D BIGASSEMBLY
endif

ifdef VBIGASSEMBLY
override DEF := $(DEF) -D BIGASSEMBLY -D VBIGASSEMBLY
endif

ifdef LONGSEQUENCES
override DEF := $(DEF) -D LONGSEQUENCES
endif

ifdef OPENMP
override CFLAGS := $(CFLAGS) -fopenmp
endif

# Per library coverage
ifdef SINGLE_COV_CAT
override DEF := $(DEF) -D SINGLE_COV_CAT
endif

default : cleanobj oases doc

Z_LIB_FILES=-L$(ZLIB_DIR) -lz

VELVET_SRC_DIR=$(VELVET_DIR)/src
VELVET_OBJ = recycleBin utility graph passageMarker readSet tightString kmer dfibHeap dfib concatenatedGraph graphStats fibHeap fib readCoherentGraph allocArray binarySequences autoOpen
VELVET_FILES = $(VELVET_OBJ:%=$(VELVET_DIR)/obj/%.o)
VELVET_DBG_FILES = $(VELVET_OBJ:%=$(VELVET_DIR)/obj/dbg/%.o)

OBJ = obj/oases.o obj/transcript.o obj/scaffold.o obj/locallyCorrectedGraph2.o obj/correctedGraph.o obj/filterTranscripts.o obj/locus.o obj/nodeList.o obj/oasesExport.o obj/trivialTranscripts.o obj/complexTranscripts.o obj/extractMergedTranscripts.o obj/extractLoci.o
OBJDBG = $(subst obj,obj/dbg,$(OBJ))

clean :
	rm -f obj/*.o obj/dbg/*.o ./oases
	cd doc && make clean

cleanobj:
	rm -f obj/*.o obj/dbg/*.o

doc: OasesManual.pdf

OasesManual.pdf: doc/manual/OasesManual.tex
	cd doc; make

oases : obj $(OBJ)
	$(CC) $(CFLAGS) $(OPT) $(LDFLAGS) -o oases $(OBJ) $(VELVET_FILES) $(Z_LIB_FILES) $(LIBS)


debug : cleanobj velvetdbg obj/dbg $(OBJDBG)
	$(CC) $(CFLAGS) $(DEBUG) $(LDFLAGS) -o oases $(OBJDBG) $(VELVET_DBG_FILES) $(Z_LIB_FILES) $(LIBS)

color : override DEF := $(DEF) -D COLOR
color : cleanobj velvet_de obj $(OBJ)
	$(CC) $(CFLAGS) $(OPT) $(LDFLAGS) -o oases_de $(OBJ) $(VELVET_FILES) $(Z_LIB_FILES) $(LIBS)

colordebug : override DEF := $(DEF) -D COLOR
colordebug : cleanobj velvetdbg_de obj/dbg $(OBJDBG)
	$(CC) $(CFLAGS) $(DEBUG) $(LDFLAGS) -o oases_de $(OBJDBG) $(VELVET_DBG_FILES) $(Z_LIB_FILES) $(LIBS)

obj:
	mkdir -p obj

obj/dbg:
	mkdir -p obj/dbg

obj/%.o: src/%.c
	$(CC) $(CFLAGS) $(OPT) $(DEF) -c $? -o $@ -I$(VELVET_SRC_DIR)

obj/dbg/%.o: src/%.c
	$(CC) $(CFLAGS) $(DEBUG) $(DEF) -c $? -o $@ -I$(VELVET_SRC_DIR)
