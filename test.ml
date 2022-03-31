open Oinsp

let plus : int -> int -> int -> int = fun x y z -> x + y + z

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
let _ = inspect @@ interleave (of_list [1;2;3])


                 






(* mutual recursion where each is a partial application *)
let rec f x y z =  plus x ((g y) z)
and g x = h x x
and h x y = foo  x y y
and foo x y z = f x y z

let _ = inspect f
let _ = inspect (foo 1 2)
let _ = inspect (f 10 11)
let _ = let k = h 4 in inspect k
    
let bar = h 4
let _ = inspect bar

    

(* none-termination of the c code
type 'a ll = Nil | Cons of 'a * ('a ll Lazy.t)
let _ = let rec ones = Cons(1, lazy ones) in inspect (lazy ones)
*)
(* segfault
let _ = inspect @@ Printf.printf "Hello, %s!\n"
*)
(* let triple_sum (x,y,z) = x + y + z 
let _ = inspect triple_sum
*)
