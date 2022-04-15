open Oinsp

class addi =
  object
    val mutable li = [0;0;0;0]
    val mutable fl = 7.77
    val mutable mni = Some (Nativeint.minus_one)
    method add a = fl <- (+.) fl a
    method incr () = match mni with Some x -> (mni <- Some (Nativeint.succ x)) | _ -> ()
    method get_fl () = fl
    method get_mni () = mni
   end

let _ = let p = new addi in
  begin
    inspect (p#add);
    inspect (p#incr);
    inspect (p#get_fl);
    inspect (p#get_mni);
  end

let _ = inspect (new addi)

let _ = inspect [new addi; new addi; new addi; new addi]

class point =
   object
     val mutable x = 0
     method get_x = x
     method move d = x <- x + d
     method jump d = x <- x * d
     method set_x nx = x <- nx
   end


let _ = let p = new point in
  begin
    inspect (p#get_x);
    inspect (p#move);
    inspect (p#jump);
    inspect (p#set_x);
  end

let _ = inspect (new point)

let _ = inspect [new point; new point; new point; new point]

let _ = inspect (Int64.minus_one)

let _ = inspect (Int64.(neg (succ (succ (succ zero)))))

let _ = inspect (Int32.minus_one)

let _ = inspect (Int32.(neg (succ (succ (succ zero)))))

let _ = inspect (Nativeint.minus_one)

let _ = inspect (Nativeint.(neg (succ (succ (succ zero)))))

let _ = inspect @@ Stream.of_list ["0.1";"0.2";"0.3"]

let _ = inspect @@ Stream.of_list [0.1;0.2;0.3]

let _ = inspect @@ Stream.of_list [1;2;3;4]
    
let _ = inspect Uchar.bom

(* abstract tag *)
let _ = let wa = Weak.create 4 in
  begin
    inspect wa;
    Weak.set wa 0 (Some ['A']);
    inspect wa;
    Weak.set wa 1(Some ['B']);
    inspect wa;
    Weak.set wa 2 (Some ['C']);
    inspect wa;
    Weak.set wa 3 (Some ['D']);
    inspect wa;
    inspect @@ Weak.length wa
  end

let _ = inspect "\000\001\002\003"

let _ = let ht = Hashtbl.create 16 in
  inspect begin
    Hashtbl.add ht "sixteen" (16.00);
    Hashtbl.add ht "sixteen" (1.6);
    Hashtbl.add ht "sixteen" (0.16);
    Hashtbl.add ht "tnt" (13.00);
    ht
  end

let _ = inspect (-100000023.45)
let _ = inspect (23.45)
let _ = inspect (1.1)
let _ = inspect (1.0)
let _ = inspect (0.1)
let _ = inspect [| 0.1; 0.3; 0.6|]

let _ =
  let gstat = Gc.stat () and gget = Gc.get () in
  inspect gstat; inspect gget

let bf = Buffer.create 8
let _ = inspect bf

let sum_six = fun a -> fun b c d e f -> a + b + c + d + e + f
let psum1 a = sum_six a
let psum2 a b = sum_six a b 

let _ = inspect (sum_six 1 2 3 4 5)
let _ = inspect (psum1   1 2 3 4 5)
let _ = inspect (psum2   1 2 3 4 5)

let sum_six_1 = fun a -> fun b c d e f -> a + b + c + d + e + f
let sum_six_2 = fun a b -> fun c d e f -> a + b + c + d + e + f
let sum_six_3 = fun a b c -> fun d e f -> a + b + c + d + e + f
let sum_six_4 = fun a b c d -> fun e f -> a + b + c + d + e + f
let sum_six_5 = fun a b c d e -> fun f -> a + b + c + d + e + f
let sum_six_6 = fun a b c d e f -> a + b + c + d + e + f

let _ = inspect sum_six_1 
let _ = inspect sum_six_2
let _ = inspect sum_six_3
let _ = inspect sum_six_4
let _ = inspect sum_six_5 
let _ = inspect sum_six_6

let _ = inspect @@ Sys.opaque_identity sum_six_1
let _ = inspect @@ Sys.opaque_identity sum_six_2
let _ = inspect @@ Sys.opaque_identity sum_six_3
let _ = inspect @@ Sys.opaque_identity sum_six_4
let _ = inspect @@ Sys.opaque_identity sum_six_5
let _ = inspect @@ Sys.opaque_identity sum_six_6
                  
let psum1 a         = sum_six_1 a          
let psum2 a b       = sum_six_1 a b        
let psum3 a b c     = sum_six_1 a b c      
let psum4 a b c d   = sum_six_1 a b c d    
let psum5 a b c d e = sum_six_1 a b c d e  

let _ = inspect psum1
let _ = inspect psum2
let _ = inspect psum3
let _ = inspect psum4
let _ = inspect psum5
 
let _ = inspect @@ psum1 1
let _ = inspect @@ psum1 1 2
let _ = inspect @@ psum1 1 2 3
let _ = inspect @@ psum1 1 2 3 4 
let _ = inspect @@ psum1 1 2 3 4 5  
    
let tuple_sum_with_more_1a = fun (x,y,z) ->  let sum = x + y + z in
  fun a b -> sum + a + b
let tuple_sum_with_more_1b (x,y,z) = let sum = x + y + z in
  fun a b -> sum + a + b
             
let tuple_sum_with_more_2a = fun (x,y,z) a -> let sum = x + y + z in
  fun b -> sum + a + b
let tuple_sum_with_more_2b (x,y,z) a = let sum = x + y + z in
  fun b -> sum + a + b
           
let tuple_sum_with_more = tuple_sum_with_more_1b
let f = Sys.opaque_identity tuple_sum_with_more

(* using Sys.opaque_identity makes no difference *)
let _ = inspect tuple_sum_with_more
let _ = inspect f

let _ = inspect tuple_sum_with_more_1a
let _ = inspect tuple_sum_with_more_1b

let _ = inspect tuple_sum_with_more_2a
let _ = inspect tuple_sum_with_more_2b

let plus : int -> int -> int -> int = fun x y z -> x + y + z

let foo = plus 1
let bar x = plus x
let quu x = plus 1 x
let lee x y = plus x y

let _ = inspect foo 
let _ = inspect bar 
let _ = inspect quu 
let _ = inspect lee 

let _ = inspect @@ List.fold_right (plus 0) [1;2;3] 

let _ = inspect @@ List.map (+)

type t = I1 | I2 of int * int | I3 of bool | I4 of char list | I5 | I6

let ft : t -> t -> t -> unit = fun x y z ->
  match x,y,z with
  | I2(a,b), I3 _, I6 -> ()
  | _,_,_ -> Printf.printf "ok\n"

let _ = inspect ft
let _ = inspect @@ ft (I3 true)
let _ = inspect @@ ft (I4 ['A'; 'B']) I1

let f x1 x2 x3 x4 x5 x6 x7 = x1 + x2 + x3 + x4 + x5 + x6 + x7
let f1 = f 1 
let f2 = f1 2
let f3 = f2 3
let f4 = f3 4
let f5 = f4 5
let f6 = f5 6
let f7 = f6 7

let _ = inspect List.fold_right

let _ = inspect f
let _ = inspect f1
let _ = inspect f2 
let _ = inspect f3 
let _ = inspect f4 
let _ = inspect f5 
let _ = inspect f6 
let _ = inspect f7 

let _ = inspect @@ f 1
let _ = inspect @@ f 1 2
let _ = inspect @@ f 1 2 3 
let _ = inspect @@ f 1 2 3 4
let _ = inspect @@ f 1 2 3 4 5
let _ = inspect @@ f 1 2 3 4 5 6
let _ = inspect @@ f 1 2 3 4 5 6 7

let _ = inspect ((fun x y -> x + y) 1)
let _ = inspect ((fun x y z -> x + y + z) 1 2)
let _ = inspect ((fun x y z x1 -> x + y + z + x1) 1 2 3)
let _ = inspect ((fun x y z x1 y1 -> x + y + z + x1 + y1) 1 2 3 4)


let _ = inspect (fun () -> 1)
let _ = inspect (fun x -> x)
let _ = inspect (fun x -> x + 2)
let _ = inspect (fun x y -> x + y)
let _ = inspect (fun x y z -> x + y + z)


let _ = inspect (let a = 1 in fun x -> x + a)
let _ = inspect (let a = 1 and b = 2 in fun x -> x + a + b)
let _ = inspect (let a = 1 and b = 2 and c = 3 in fun x -> x + a + b + c)
let _ = inspect (let a = 1 and b = 2 and c = 3 and d = [10;11;12;13]
                 in fun x -> x + a + b + c + List.fold_right (+) d 0)
            
let a,b,c,d,e,f,g,h,i = 1,2,3,4,5,6,7,8,9

let _ = inspect (fun x -> x + a)
let _ = inspect (fun x y -> a+x, b+y)
let _ = inspect (fun x y z -> a+x, b+y, c + z)
let _ = inspect (fun x y z x1 -> a+x, b+y, c+z, d+x1)
let _ = inspect (fun x y z x1 y1 -> a+x, b+y, c + z, d + x1, e + y1)
let _ = inspect (fun x y z x1 y1 z1 -> a+x, b+y, c + z, d + x1, e + y1, f + z1)
let _ = inspect (fun x y z x1 y1 z1 x2  -> a+x, b+y, c + z, d + x1, e + y1, f + z1, g + x2)
let _ = inspect (fun x y z x1 y1 z1 x2 y2 -> a+x, b+y, c + z, d + x1, e + y1,
                                             f + z1, g + x2, h + y2)
let _ = inspect (fun x y z x1 y1 z1 x2 y2 z2-> a+x, b+y, c + z, d + x1, e + y1,
                                             f + z1, g + x2, h + y2, i + z2)
        
type t_rec = {env : int; key : int list ; index : int; mutable subst : Obj.t option}

let _ = let x : t_rec = {
    env = 1
  ; key = [1;2;3]
  ; index = 15
  ; subst = None } in
  inspect x 

let _ = inspect (1,2,'a',(fun () -> ()))

let _ = inspect Float.(add 2.)
let _ = inspect 1.
let _ = inspect 2.
let _ = inspect (-2.)
let _ = inspect (5.)
let _ = inspect Float.infinity
let _ = inspect Float.neg_infinity
let _ = inspect Float.nan
let _ = inspect Float.pi
let _ = inspect (1., 2., -2.,5.)

type dr = {
  a : float
; b : float
; c : float
; d : float}

let _ = inspect {a=1.; b=2.; c=(-2.); d=5.}
        
let _ = inspect Printf.printf

let _ = inspect "abcdefg"
let _ = inspect "abcdefgh"
let _ = inspect "abcdefgh1234567"
let _ = inspect "abcdefgh1234567\001\002\002\127\240"
let _ = inspect ""
let _ = inspect "\255\252\000\000\000"
let _ = inspect @@ Bytes.of_string "\255\252\000\000\000"
                 
type ('a, 'b) node =
    Nil
  | Cons  of 'a * 'b
  | Table of 'b list

type 'a rseqnc = ('a, 'b) node as 'b
         
let rec of_list : 'a list -> 'a rseqnc = function
  | [] -> Nil
  | h :: t -> Cons(h, of_list t)

let rec interleave xs ys : 'a rseqnc =
  match xs with
  | Nil -> ys
  | Cons (h, t) -> Cons (h, interleave ys t)
  | Table nodes ->
    match flatten nodes, ys with
    | Table a , Table b -> Table (a @ b)
    | Table _ , _       -> interleave ys xs
    | l, _              -> interleave l ys
and flatten : 'a rseqnc list -> 'a rseqnc = function
  | []      -> Table []
  | n :: [] -> n
  | n :: ns -> interleave n (Table ns)
 

let tb : int rseqnc = (Cons(101, Cons(102, Table [(of_list [103;104;105;106]);
                                         (of_list [107;108;109;110]);
                                         (Cons(111, Cons(112, Table [(Table [(Table [(of_list [113;114]);
                                                                                     (of_list [115;116])]);
                                                                             (of_list [117;118;119;120]);
                                                                             (of_list [121;122;123;124]);
                                                                             (of_list [125;126;127;128])]);
                                                                     (of_list [129;130;131;132]);
                                                                     (of_list [133;134;135;136]);
                                                                     (of_list [137;138;139;140]);])))])))


let _ = inspect tb
let _ = inspect of_list 
let _ = inspect flatten
let _ = inspect interleave 
let _ = inspect @@ interleave (of_list [1;2;3])

(* mutual recursion *)                              
let rec f x y  = g x y 
and g x y = h x x y 
and h x y z = foo x (y z) 
and foo x y  = f x y 

let _ = inspect f
let _ = inspect g
let _ = inspect h
let _ = inspect foo
let _ = inspect @@ foo succ


(* none-termination of the c code
type 'a ll = Nil | Cons of 'a * ('a ll Lazy.t)
let _ = let rec ones = Cons(1, lazy ones) in inspect (lazy ones)
*)
(* segfault
let _ = inspect @@ Stream.of_channel stdin
let _ = inspect stdin
let _ = inspect stdout
let _ = inspect stderr
let _ = inspect @@ Printf.printf "Hello, %s!\n"
*)
