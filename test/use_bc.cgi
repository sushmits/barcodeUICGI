use strict;
use warnings;

use CGI;
my $cgi=CGI->new();

my $mode=$cgi->param("mode");

if(!defined($mode)){ $mode="genbcs";}
my $req=$cgi->param("req");

perl use_bc.pl genbcs amar:4,neb:4,tru:2 ACGGTA:myown1,TTGTCC:myown2
perl use_bc.pl genmat ACGGTA,TTGTCC
perl use_bc.pl gendiv ACGGTA,TTGTCC