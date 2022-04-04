# OInspect
Inspector for OCaml runtime values 

## What it does

Use this library to inspect runtime integer and block values of OCaml, which shall be compiled using the 
native code compiler. The following block tags are supported:

|      Tag Name                 | Tag Value |
| -------------                 | --------- |
| non-constant constructor tags | 0 ~ 245  |
| closure tag                   |  247     |
| object tag                    |  248     |
| infix tag                     |  249     |
| abstract tag                  |  251     |
| string tag                    |  252     |
| double tag                    |  253     |
| double array tag              |  254     |
| custom tag                    | 255      |


Currently unsupported tags:

- lazy tag : 246
- forward tag : 250

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

## What to expect

If you `inspect "\255\252\000\000\000"`, you will see
```
OCaml Value : 0X0000556A125FA030
     Header : 0X00000000000007FC
              wo-size : 1
              color : 3
              string tag : 252
OCaml string/bytes : (#255)(#252)(#0)(#0)(#0)
           Logical Field 0 :
                    Byte-0 : (#255)
                    Byte-1 : (#252)
                    Byte-2 : (#0)
                    Byte-3 : (#0)
                    Byte-4 : (#0)
                    Byte-5 : (#0)
                    Byte-6 : (#0)
                    Byte-7 : (#2)
```
The header encodes the size of the block (excluding header, in words), the color for GC and the tag. This
header structure is the same independent of the tag. As shown, the size (wo-size) is 1, that is, one machine word (on 64-bit architecture, a word has 8 bytes).
The last byte of the last field means the number of bytes immediately before it which do *not*
belong to the OCaml string.

As another example, if you `inspect @@ List.fold_right (plus 0) [1;2;3]`, you get the list below. The header field indicates there
are five fields (wo-size : 5). Field 0 is a code pointer to the code for partial application; it is this code that will be called if we provide the last argument to the fold function. Field 1 is a word encoding
the arity of the closure (which is 1, because there is still an initial value missing for the fold function), with the field index
where the environment for the closure starts : some closures have an environment, some don't. Field 2 - 4 constitute the environment, 
which basically says that the expression under inspection is a partial application of the function `fold_right` (see the Field 4 near the bottom with no dot `....` prefixes) 
to the arguments `(plus 0)` (see Field 2) and `[1;2;3]` (see Field 3). There are different level of fields indicated by the prefixing dots; prefixing dots of the same length mean the same level. 
```
OCaml Value : 0X00007FBC49BA1A08
     Header : 0X00000000000014F7
              wo-size : 5
              color : 0
              closure tag : 247
    Field 0 : 0X00005559607840C0 ... code partial appl.
    Field 1 : 0X0100000000000005 ... info
              Arity : 1
              Env.  : 2
    env starts ...
    Field 2 :
....OCaml Value : 0X00007FBC49BA1A38
....     Header : 0X00000000000014F7
....              wo-size : 5
....              color : 0
....              closure tag : 247
....    Field 0 : 0X0000555960783E90 ... code partial appl.
....    Field 1 : 0X0200000000000007 ... info
....              Arity : 2
....              Env.  : 3
....    Field 2 : 0X00005559607840B0 ... code total appl.
....    env starts ...
....    Field 3 :
........OCaml Value : 0X0000000000000001
........ Is integer : 0 (in decimal)
....    Field 4 :
........OCaml Value : 0X00005559607EB730
........     Header : 0X0000000000000FF7
........              wo-size : 3
........              color : 3
........              closure tag : 247
........    Field 0 : 0X0000555960783DA0 ... code partial appl.
........    Field 1 : 0X0300000000000007 ... info
........              Arity : 3
........              Env.  : 3
........    Field 2 : 0X00005559607840A0 ... code total appl.
........    ... no env.
    Field 3 :
....OCaml Value : 0X00005559607EBEE8
....     Header : 0X0000000000000B00
....              wo-size : 2
....              color : 3
....              tag : 0
....Field 0:
........OCaml Value : 0X0000000000000003
........ Is integer : 1 (in decimal)
....Field 1:
........OCaml Value : 0X00005559607EBFF0
........     Header : 0X0000000000000B00
........              wo-size : 2
........              color : 3
........              tag : 0
........Field 0:
............OCaml Value : 0X0000000000000005
............ Is integer : 2 (in decimal)
........Field 1:
............OCaml Value : 0X00005559607EC100
............     Header : 0X0000000000000B00
............              wo-size : 2
............              color : 3
............              tag : 0
............Field 0:
................OCaml Value : 0X0000000000000007
................ Is integer : 3 (in decimal)
............Field 1:
................OCaml Value : 0X0000000000000001
................ Is integer : 0 (in decimal)
    Field 4 :
....OCaml Value : 0X00005559607F1AC0
....     Header : 0X0000000000000FF7
....              wo-size : 3
....              color : 3
....              closure tag : 247
....    Field 0 : 0X0000555960783DA0 ... code partial appl.
....    Field 1 : 0X0300000000000007 ... info
....              Arity : 3
....              Env.  : 3
....    Field 2 : 0X000055596078A3C0 ... code total appl.
....    ... no env.

```


## Useful Resources

- The books *Developing Applications in Objective Caml* and *Real World OCaml* both have a chapter on interoperability with C, where you
can find description of runtime values. The OCaml Reference Manual also has such a chapter.

- There is a library to graphically display OCaml runtime values: [ocaml-memgraph](https://github.com/Gbury/ocaml-memgraph).
