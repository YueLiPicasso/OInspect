# OInspect
Inspector for OCaml runtime values 

## What it does

Use this library to inspect runtime integer and block values of OCaml. The following block tags are supported:

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

The code is tested with OCaml 4.12.0. Blocks with a closure tag is structured differently in earlier OCaml versions and are not inspectable using this library.  

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
Then,  put your test file and the library source files ([oinsp.mli](./oinsp.mli), [oinsp.ml](./oinsp.ml) and [Extoinsp.c](./Extoinsp.c)) under the same directory, and execute the commands
```
ocamlopt -o out.opt Extoinsp.c oinsp.mli oinsp.ml test.ml
./out.opt
``` 
which calls the native-code compiler; or alternatively, execute the commands
```
ocamlc -o out.byt -custom Extoinsp.c oinsp.mli oinsp.ml test.ml
./out.byt
```
which calls the byte-code compiler. A text description of the runtime representation of the expression shall be displayed on your terminal.


### Ready-made tests

The [test.ml](./test.ml) file gives numerous examples of using the library to inspect runtime values. To view these examples, change your working directory to the library directory, and 
```
make clean && make 
```
`make` defaults to `make native`; alternatively,
```
make clean && make byte
```
You can then compare the runtime representations with the source expressions, or compare the difference between using the bytecode and native-code compiler.

## What to expect

If you `inspect "\255\252\000\000\000"`, you will see (no matter which compiler you use)
```
OCaml Value : 0X00007FABCB271A80
     Header : 0X00000000000004FC
              wo-size : 1
              color : 0
              string tag : 252
    Field 0 :
     Byte-0 : (#255)
     Byte-1 : (#252)
     Byte-2 : (#0)
     Byte-3 : (#0)
     Byte-4 : (#0)
     Byte-5 : (#0)
     Byte-6 : (#0)
     Byte-7 : (#2)
    OCaml string/bytes : (#255)(#252)(#0)(#0)(#0)
```
The header encodes the size of the block (excluding header, in words), the color for GC and the tag. This
header structure is the same independent of the tag. As shown, the size (wo-size) is 1, that is, one machine word (on 64-bit architecture, a word has 8 bytes).
The last byte of the last field means the number of bytes immediately before it which do *not* belong to the OCaml string.

As another example, if you `inspect @@ List.fold_right (plus 0) [1;2;3]` once with the byte-code compiler and another time with the native-code compiler, you get different representations. In both cases, the header indicates there are five fields (wo-size : 5) and there is a closure tag; however, under byte-code compilation, field 2, 3 and 4 contain respectively repr. of  `List.fold_right`, `(plus 0)` and `[1;2;3]`; but under native-code compilation those fields contain resp. `(plus 0)`, `[1;2;3]` and `List.fold_right`; there are further differences regarding arity and field organisation. For visual aide, different levels of field are indented by prefixing dots of different lengths; dots of the same length mean the same level. 
<table>
<tr>
<td> Byte-code Compilation </td> <td> Native-code Compilation</td>
</tr>
<tr>
<td>

```
OCaml Value : 0X00007FEBFDDF82D8
     Header : 0X00000000000014F7
              wo-size : 5
              color : 0
              closure tag : 247
    Field 0 : 0X000055B9EB1CC34C ... code pointer.
    Field 1 : 0X0000000000000005 ... info
              Arity : 0
              Env.  : 2
    env starts ...
    Field 2 :
....OCaml Value : 0X00007FEBFDDF8990
....     Header : 0X00000000000008F7
....              wo-size : 2
....              color : 0
....              closure tag : 247
....    Field 0 : 0X000055B9EB1CC350 ... code pointer.
....    Field 1 : 0X0000000000000005 ... info
....              Arity : 0
....              Env.  : 2
....    ... no env.
    Field 3 :
....OCaml Value : 0X00007FEBFDDF8308
....     Header : 0X00000000000010F7
....              wo-size : 4
....              color : 0
....              closure tag : 247
....    Field 0 : 0X000055B9EB1CFE68 ... code pointer.
....    Field 1 : 0X0000000000000005 ... info
....              Arity : 0
....              Env.  : 2
....    env starts ...
....    Field 2 :
........OCaml Value : 0X00007FEBFDDF8330
........     Header : 0X00000000000008F7
........              wo-size : 2
........              color : 0
........              closure tag : 247
........    Field 0 : 0X000055B9EB1CFE6C ... code pointer.
........    Field 1 : 0X0000000000000005 ... info
........              Arity : 0
........              Env.  : 2
........    ... no env.
....    Field 3 :
........OCaml Value : 0X0000000000000001
........ Is integer : 0 (decimal)
    Field 4 :
....OCaml Value : 0X00007FEBFDBF7FC0
....     Header : 0X0000000000000800
....              wo-size : 2
....              color : 0
....              Constr. tag : 0
....    Field 0 :
........OCaml Value : 0X0000000000000003
........ Is integer : 1 (decimal)
....    Field 1 :
........OCaml Value : 0X00007FEBFDBF7FD8
........     Header : 0X0000000000000800
........              wo-size : 2
........              color : 0
........              Constr. tag : 0
........    Field 0 :
............OCaml Value : 0X0000000000000005
............ Is integer : 2 (decimal)
........    Field 1 :
............OCaml Value : 0X00007FEBFDBF7FF0
............     Header : 0X0000000000000800
............              wo-size : 2
............              color : 0
............              Constr. tag : 0
............    Field 0 :
................OCaml Value : 0X0000000000000007
................ Is integer : 3 (decimal)
............    Field 1 :
................OCaml Value : 0X0000000000000001
................ Is integer : 0 (decimal)
```

</td>
<td>

```
OCaml Value : 0X00007FB439C80DA8
     Header : 0X00000000000014F7
              wo-size : 5
              color : 0
              closure tag : 247
    Field 0 : 0X000056378F0D5C00 ... code pointer.
    Field 1 : 0X0100000000000005 ... info
              Arity : 1
              Env.  : 2
    env starts ...
    Field 2 :
....OCaml Value : 0X00007FB439C80DD8
....     Header : 0X00000000000014F7
....              wo-size : 5
....              color : 0
....              closure tag : 247
....    Field 0 : 0X000056378F0D5AB0 ... code pointer.
....    Field 1 : 0X0200000000000007 ... info
....              Arity : 2
....              Env.  : 3
....    Field 2 : 0X000056378F0D5BF0 ... code pointer
....    env starts ...
....    Field 3 :
........OCaml Value : 0X0000000000000001
........ Is integer : 0 (decimal)
....    Field 4 :
........OCaml Value : 0X000056378F111C98
........     Header : 0X0000000000000FF7
........              wo-size : 3
........              color : 3
........              closure tag : 247
........    Field 0 : 0X000056378F0D59C0 ... code pointer.
........    Field 1 : 0X0300000000000007 ... info
........              Arity : 3
........              Env.  : 3
........    Field 2 : 0X000056378F0D5BE0 ... code pointer
........    ... no env.
    Field 3 :
....OCaml Value : 0X000056378F111CD8
....     Header : 0X0000000000000B00
....              wo-size : 2
....              color : 3
....              Constr. tag : 0
....    Field 0 :
........OCaml Value : 0X0000000000000003
........ Is integer : 1 (decimal)
....    Field 1 :
........OCaml Value : 0X000056378F111CF0
........     Header : 0X0000000000000B00
........              wo-size : 2
........              color : 3
........              Constr. tag : 0
........    Field 0 :
............OCaml Value : 0X0000000000000005
............ Is integer : 2 (decimal)
........    Field 1 :
............OCaml Value : 0X000056378F111D08
............     Header : 0X0000000000000B00
............              wo-size : 2
............              color : 3
............              Constr. tag : 0
............    Field 0 :
................OCaml Value : 0X0000000000000007
................ Is integer : 3 (decimal)
............    Field 1 :
................OCaml Value : 0X0000000000000001
................ Is integer : 0 (decimal)
    Field 4 :
....OCaml Value : 0X000056378F116210
....     Header : 0X0000000000000FF7
....              wo-size : 3
....              color : 3
....              closure tag : 247
....    Field 0 : 0X000056378F0D59C0 ... code pointer.
....    Field 1 : 0X0300000000000007 ... info
....              Arity : 3
....              Env.  : 3
....    Field 2 : 0X000056378F0D9F00 ... code pointer
....    ... no env.
```

</td>
</tr>
</table>


## Useful Resources

- The books *Developing Applications in Objective Caml* and *Real World OCaml* both have a chapter on interoperability with C, where you can find description of runtime values.  The OCaml Reference Manual also has such a chapter. The first book (*Dev. App. in O. Caml*) focuses on runtime value representation under byte-code compilation.

- There is a library to graphically display OCaml runtime values: [ocaml-memgraph](https://github.com/Gbury/ocaml-memgraph).
