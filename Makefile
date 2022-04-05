EXE = out.opt
BYT = out.byt
LIB = Extoinsp.c oinsp.mli oinsp.ml
TEST = test.ml
SRC = $(LIB) $(TEST)

.PHONY: clean 

native : $(EXE)
	./$(EXE)

byte : $(BYT)
	./$(BYT)

$(BYT) : $(SRC)
	ocamlc -custom -o $(BYT) -rectypes $(SRC)

$(EXE) : $(SRC)
	ocamlopt -o $(EXE) -rectypes  $(SRC)

clean :
	rm -f *.o *.opt *.cmi *.cmx *.byt *.cmo
