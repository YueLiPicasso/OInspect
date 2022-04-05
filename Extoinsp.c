/* OCaml Runtime Value Inspector

          Li Yue @ JBR 
              2022

Developed with OCaml 4.12.0  */

#define CAML_NAME_SPACE
#include "caml/mlvalues.h"
#include <stdio.h>

#define Color_hd(hd)   ((color_t)((hd >> 8) & ((header_t) 3)))
#define mprintf        margin(m);printf
#define DBPC 20 // precision for printing a double 

// data from the same level are printed with the same margin 
void margin (value n)
{ while (n-- > 0) printf("."); return;}

CAMLprim value inspect (value v, value m)
{
  m = Long_val(m); // margin size for pretty printing
  printf("\n");
  mprintf("OCaml Value : %0#18lX\n", v);
  if (Is_long(v)) {
    mprintf(" Is integer : %ld (decimal)\n", Long_val(v));
  }
  else if (Is_block(v))
    {
      // v is already a pointer to the first field
      const header_t * hp     = Hp_val(v);     // pointer to header
      const header_t   hd     = Hd_hp(hp);     // header itself
      const mlsize_t   wosize = Wosize_hd(hd); // number of fields
      const tag_t      tag    = Tag_hd(hd);
      const uintnat*   tp     = hp + wosize;   // pointer to the last field

      if (tag != Closure_tag) {
	mprintf("     Header : %0#18lX\n", hd);
	mprintf("              wo-size : %lu\n", wosize);
	mprintf("              color : %lu\n", Color_hd(hd));
      }
     
      if (tag == Closure_tag) {
	
	const intnat  info      = Closinfo_val(v);
        const uintnat env       = Start_env_closinfo(info);
	const uintnat * ep      = (uintnat*)(hp) + env + 1;   // pointer to env
	intnat  arity           = Arity_closinfo(info);
	uintnat * ptr           = (uintnat*)hp;                         // init.

	/*                      Structure of a closure block 

	 closure block ::=  { header 
	                      code-pointer 
                              info
                              [code-pointer] }+
                            [env]
         header ::= wosize color (closure-tag | infix-tag)
         info   ::= arity env-start
	 env    ::= { value }+ code-pointer  */
	
	while (ptr < ep) { 
	  // print header 
	  if (Tag_hd(*ptr) == Infix_tag) {
	    mprintf("    Field %lu : %0#18lX ... infix header\n",
		    (mlsize_t)(ptr-(uintnat*)v), Hd_hp(ptr));
	  } else {
	    mprintf("     Header : %0#18lX\n", Hd_hp(ptr)); }
	  mprintf("              wo-size : %lu\n",  Wosize_hd(Hd_hp(ptr)));
	  mprintf("              color : %lu\n",    Color_hd(Hd_hp(ptr)));
	  if (Tag_hd(*ptr) == Infix_tag) {
	    mprintf("              infix tag : %u\n", Tag_hd(Hd_hp(ptr)));
	  } else {
	    mprintf("              closure tag : %u\n", Tag_hd(Hd_hp(ptr))); }    
	  // print main code pointer   
	  ptr++;
	  mprintf("    Field %lu : %0#18lX ... code pointer.\n",
		  (mlsize_t)(ptr-(uintnat*)v), *ptr);
	  // print info
	  ptr++;
	  mprintf("    Field %lu : %0#18lX ... info\n",
		  (mlsize_t)(ptr-(uintnat*)v), *ptr);
	  mprintf("              Arity : %ld\n", arity = Arity_closinfo(*ptr));
	  mprintf("              Env.  : %lu\n", Start_env_closinfo(*ptr));
	  // print optional code pointer
	  ptr++;
	  if (arity != 1 && arity != 0) { // total function appl. code next
	    mprintf("    Field %lu : %0#18lX ... code pointer\n",
		    (mlsize_t)(ptr-(uintnat*)v), *ptr);
	    ptr++; }} // end of while (ptr < ep)
	// print env
	if (ep <= tp) { // then there is env
	  mprintf("    env starts ...\n");
	  while (ep <= ptr && ptr <= tp) {
	    mprintf("    Field %lu :", (mlsize_t)(ptr-(uintnat*)v));
	    inspect((value)(*ptr), Val_long(m+4));
	    ptr++; }
	} else {
	  mprintf("    ... no env.\n"); }
	
      } else if (tag == Infix_tag) {
	
	margin(m); printf("              infix tag : %u\n", tag);
	const code_t *  cpp         = (code_t*) (v);
	const mlsize_t  infix_offset = Wosize_hd(hd); // the size field of hd is wosize
	const value     top_v        = (value)((value *)(v) - infix_offset);
	mprintf("       Code : %0#18lX\n", (unsigned long)(*cpp));
	mprintf("      Closure defined by mutual recursion.\n");
	mprintf("      Refer to field %ld of OCaml object %0#18lX.\n",
			  infix_offset, top_v);
	
      } else if (tag == Double_tag) {
	mprintf("              double tag : %u\n", tag);
	mprintf("    Field 0 : %0#18lX (raw hex)\n", hp[1]);
	mprintf("              %.*f (decimal; precision %d)\n",
		DBPC, ((double*)(hp))[1], DBPC);
	
      } else if (tag == Double_array_tag) {
	
	mprintf("              double array tag : %u\n", tag);
	for (mlsize_t i = 0; i < wosize; i++) {
	  mprintf("    Field %lu : %0#18lX (raw hex)\n", i, hp[1+i]);
	  mprintf("              %.*f (decimal; precision %d)\n",
		  DBPC, ((double*)(hp))[1+i], DBPC);}
	
      } else if (tag == String_tag) {
	
	mprintf("              string tag : %u\n", tag);
	// string pointer : first byte of first field
	const  unsigned char * str = (unsigned char *)(v);
	// pointer to the last byte of last field
	const unsigned char *  lbp = (unsigned char *)(hp + wosize) + 7;
	// last byte of last field
	const unsigned char lb = *lbp;
	// pointer to the byte after the last byte of the OCaml string
	const unsigned char * olbp = lbp - lb;
	mlsize_t id = 0;  // current str idx
	// print all the bytes in all the fields
	for (mlsize_t i = 0; i < wosize; i++) {
	  mprintf("    Field %lu :\n", i);
	  for (mlsize_t j = 0 ; j < sizeof(value); j++) {
	    id = i * sizeof(value) + j;
	    if (str[id] >= 33 && str[id] <= 126) {
	      mprintf("     Byte-%lu : %c\n", j, str[id]);
	    } else {
	      mprintf("     Byte-%lu : (#%d)\n", j, str[id]);}}}
	// print the original OCaml string
	mprintf("    OCaml string/bytes : ");
	for (unsigned char * i = (unsigned char*)str; i < olbp; i++)
	  if (*i >= 33 && *i <= 126) printf("%c", *i); else printf("(#%d)", *i);
	printf("\n");
	
	// values of an OCaml abstract type may NOT have an abstract tag 
      } else if (tag == Abstract_tag) { 
	
	mprintf("              abstract tag : %u\n", tag);
	for (mlsize_t i = 0; i < wosize; i++) {
	  mprintf("    Field %lu : %0#18lX (raw hex)\n", i, hp[1+i]); }
	
      } else if (tag == Custom_tag) { 
	
	mprintf("              custom tag : %u\n", tag);
	mprintf("    Field 0 : %0#18lX (raw hex) ... method suit pointer\n", hp[1]); 
	mprintf("    Field 1 : %0#18lX (raw hex) ... data\n", hp[2]); 
	
      } else if (tag == Object_tag) {

	mprintf("              object tag : %u\n", tag);
	const intnat class_id = Class_val(v);
	const intnat obj_id   = Oid_val(v);
	for (mlsize_t i = 0 ; i < wosize ; i++) {
	  if (i == 0) {// method suit pointer
	    mprintf("    Field %lu : method suit pointer %0#18lX\n", i, class_id);
	  } else if (i == 1) { // object id
	    mprintf("    Field %lu : object (decimal) id %ld\n", i, obj_id);
	  } else { // instance variable values
	    mprintf("    Field %lu:", i);
	    inspect(Field(v,i), Val_long(m + 4));
	  }
	}
	
      } else  { // non-constant constructor, non-float array, record, tuple, etc
	mprintf("              Constr. tag : %u\n", tag);
	for (mlsize_t i = 0 ; i < wosize ; i++) {
	  mprintf("    Field %lu :", i);
	  inspect(Field(v,i), Val_long(m + 4)); }}
    }
  return Val_unit;
}
