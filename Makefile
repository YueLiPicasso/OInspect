EXE = out.opt
LIB = Extoinsp.c oinsp.mli oinsp.ml
TEST = test.ml
SRC = $(LIB) $(TEST)

.PHONY: clean

$(EXE) : $(SRC)
	ocamlopt -o $(EXE) -rectypes  $(SRC)

clean :
	rm -f *.o *.opt *.cmi *.cmx 

run : $(EXE)
	./$(EXE)
