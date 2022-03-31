# OInspect
Inspector for OCaml runtime values

## What it does

Use this library to inspect runtime integer and block values of OCaml, which shall be compiled using the 
native code compiler `ocamlopt`. The following block tags are supported:

- non-constant constructor tags : 0 ~ 245  
- closure tag                   : 247
- infix tag                     : 249
- string tag                    : 252
- double tag                    : 253
- double array tag              : 254

Currently unsupported tags:

- lazy tag : 246
- object tag : 248
- forward tag : 250
- abstract tag : 251
- custom tag : 255

## Compatibility

The code is tested with OCaml 4.12.0. Blocks with a closure tag is structured differently in earlier OCaml versions and are not
inspectable using this library.  

## How to use

Say you want to inspect the runtime representation of the expression
```ocaml
List.fold_right (plus 0) [1;2;3]
``` 
First, create a test file:

```ocaml
(* test.ml *)

open Oinsp

let plus : int -> int -> int -> int = fun x y z -> x + y + z

let _ = inspect @@ List.fold_right (plus 0) [1;2;3]
```
Then,  put your test file and the library source files ([oinsp.mli](./oinsp.mli), [oinsp.ml](./oinsp.ml) and [Extoinsp.c](./Extoinsp.c)) under 
the same directory, and execute the commands
```
ocamlopt -o out.opt Extoinsp.c oinsp.mli oinsp.ml test.ml
./out.opt
``` 
A text description of the runtime representation of the expression shall be displayed on your terminal.


### Ready-made tests

The [test.ml](./test.ml) file gives numerous examples of using the library to inspect runtime values. To view
these examples, change your working directory to the library directory, and 
```
make clean && make && make run
```
You can then compare the runtime representations with the source expressions.



## Useful Resources

- The books *Developing Applications in Objective Caml* and *Real World OCaml* both have a chapter on interoperability with C, where you
can find description of runtime values. The OCaml Reference Manual also has such a chapter.

- There is a library to graphically display OCaml runtime values: [ocaml-memgraph](https://github.com/Gbury/ocaml-memgraph).
