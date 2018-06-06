#!/usr/bin/perl -w
use strict;
use CGI;
my $cgi=CGI->new();

#my $term=shift;
my $term =$cgi->param("term");
#print STDERR  "term=$term\n";
if(!defined($term)){ $term="bioo6";}

$term=~s/\s*//g;
my $str="ID,barcode,set,name\n";
$str.=`grep ',$term,' data/bc_list.csv`;

print "Content-type: text/html\n\n";
print "<html> <body>\n";
print "<H2> <a href=./barcode.pl>  Home  </a> </H2>\n";
print "<H4> Barcode set :$term:</H4>\n";

my $ofile="tmp/tmpset$$.csv";

print "<h6> <a href=./$ofile> Download set </a></h6>\n";


open OUT,">$ofile" or die "FAIL:$ofile";
print OUT $str;
close OUT;

make_tbl($str);
print "</body></html> \n";

exit;

sub make_tbl{
    my $str=shift;
    if(!defined($str)){
	$str=",ACGGTA,TTGTCC
ACGGTA,0,5
TTGTCC,,0
    ";
    }
    my @str=split(/\n/,$str);
    print "<table border=1>\n";
    my $head=$str[0];$head=~s/,/<\/th><th>/g;
    print "<tr> <th> $head </th></tr>\n";
    for(my $i=1;$i<@str;$i++){
	next if($str[$i]=~/^\s*$/);
	$str[$i]=~s/,/<\/td><td>/g;
	print "<tr> <td> $str[$i] </td></tr>\n";
    }
    print "</table>\n";
}
