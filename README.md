# barcode_diversity
for ensuring barcode diversity
all functions now defined in bc.pm

bc_plot.pm defines the plotting

barcode.pl prints front page, as well as results


test/use_bc.pl  allows you to test functionality provided by bc.pm, which is used in barcode.pl

Use cases
  1) The user can ask for a combination of barcodes from different sets, 
  2) The user can already have a pre-existing set, and ask to add more barcodes from
       different sets
  3) The user can ask to check if a set of barcodes are compatible

The Interface needs to convey user requests and return data/figures to user.
  1) the interface will return the selected set
  2) the interface will show the distances between the barcodes
  3) the interface will show the diversity of nucleotides at each position on the barcode


use_bc.pl uses various modes which cover all cases of input from users and output required of
  the interface. 

## four example uses of use_bc.pl are shown, 

1) perl use_bc.pl genbcs amar:4,neb:4,tru:2 ACGGTA,TTGTCC
    the user starts with two pre-existing barcodes ( ACGGTA,TTGTCC) and wants to add
       4 barcodes from the set amar, 4 from the set neb and 2 from the set tru       
  
2) perl use_bc.pl gendist
     This is only used once, to generate the bc_list.csv and bc_dist.csv files. should not
     be run normally

3) perl use_bc.pl genbcs amar:4,neb:4,tru:2 ACGGTA:myown1,TTGTCC:myown2
   This is similar to case 1, but the user wants to give some names of their own to the
   the barcodes they already have (the barcodes are named "myown1" and "myown2" in this case)

4) perl use_bc.pl genmat ACGGTA,TTGTCC
    This generates the distance matrix for the set supplied by the user as a comma-separated list

5) perl use_bc.pl gendiv ACGGTA,TTGTCC
   This generates the diversity at each position for the set supplied by the user as a
   	comma separated list

ADDING a new set

  sed -e 's/^\([[:digit:]][[:digit:]]*\)[[:space:]][[:space:]]*\([[:alnum:]][[:alnum:]]*\)/\1,biooSm,\2,BiooSmRNA/' bioosm.txt > bioosm.csv

  lines of this sort
  1,biooSm,ATCACG,BiooSmRNA 

## make sure bioosm.csv has no headers
cat bioosm.csv  >> data/sequences.csv 
perl barcode.pl 1 gendist

## maybe save copies of bc_dist.csv and bc_list.csv in data before doing this
 mv bc_*.csv data/.