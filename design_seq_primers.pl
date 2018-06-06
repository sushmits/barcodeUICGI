#!/usr/bin/perl -w
use strict;
use warnings;
use bc;
use bc_plot;
use CGI;
my $self="design_seq_primers.pl";

my $FC1="AATGATACGGCGACCACCGAGATCTA";
my $FC2="CAAGCAGAAGACGGCATACGAGAT";
my $SP1="CACTCTTTCCCTACACGACGCTCTTCCGATCT";
my $BC1="CGTGAT";
my $SP2="GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT";
my $TS_F_primer="AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT";
my $TS_R_primer="CAAGCAGAAGACGGCATACGAGAT[CGTGAT]GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT";


my $cgi=CGI->new();

my $res=$cgi->param("res");

my $cmd_line=shift;

if(defined($cmd_line)){ 
    $res=1;
    init_vars();
}
sub init_vars{
    $cgi->param("tru"=>24);
#    $cgi->param("user"=>"ATCACG");
}

sub mk_popup_lnk{
    my $lnk=shift;
    my $text=shift;
    return "<a href=\"$lnk\" onclick=\"javascript:void window.open('$lnk','1525474484891','width=700,height=500,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0');return false;\"> $text </a>\n";
} 

print "Content-type: text/html\n\n";
print "<html>\n";
print "<head> <style type=\"text/css\"> 
input { text-align:right; }
h5 { 
    display: block;
    font-size: 1.0em;
    margin-top: 1.67em;
    margin-bottom: 1.67em;
    margin-left: 0;
    margin-right: 0;
    font-weight: bold;
    color: red;
} 
h6 { 
    display: block;
    font-size: 1.3em;
    margin-top: 1.67em;
    margin-bottom: 1.67em;
    margin-left: 0;
    margin-right: 0;
    font-weight: bold;
    color: green;
}
body {background-color: powderblue;}
p {color: red;} 
p2 {color: blue;} 
p3 {color: green;} 
p4 {color: darkgray;} 
</style>
</head>
\n";
print "<body>\n";


if(!defined($res)){
    my $lnk=mk_popup_lnk("./bc_help.html","help"); 
    print "<H4> $lnk";
#    print " &nbsp;&nbsp;&nbsp; <a href=./doc/Barcode_caddy.pdf> writeup </a> ";
    print " &nbsp;&nbsp;&nbsp; <a href=./$self> Home </a> ";
    print " &nbsp;&nbsp;&nbsp; <a style=\"font-size:12px;\" href=/tools.html> Girihlet Tools  </a>  
</H4> \n";  

    print "<H2>Primer designs for sequencing amplicons </H2>";

    print "<p> Generates appropriate primers so you can amplify and spike in 
amplicons into run, just choose the barcodes wisely, so you can add it a multiplex set that is being loaded on to the sequencer</p>\n";

    print "  <p><h4>Pick barcodes from the following sets:</h4></p>\n";
    mk_sets_form();

}else {

  ## results
    print "<H4> <a href=./$self> Tool Home  </a>  &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; <a href=http://girihlet.com/tools.html> Girihlet Tools </a></H4>\n";


    $FC1=  $cgi->param("FC1");
    $FC2=  $cgi->param("FC2");
    $SP1=  $cgi->param("SP1");
    $SP2=  $cgi->param("SP2");
    $BC1=  $cgi->param("BC1");

    my $CFP=  $cgi->param("CFP");
    my $CRP=  $cgi->param("CRP");

    $BC1=~tr/A-Z/a-z/;
    my $final_primer_F="<p>$FC1<p2>$SP1</p2><p3>$CFP</p3>";
    my $final_primer_R="<p>$FC2<p4>$BC1</p4><p2>$SP2</p2><p3>$CRP</p3>";
  print "<H3> F primer </H3>\n";
  print "$final_primer_F\n";
  print "<H3> R primer </H3>\n";
  print "$final_primer_R\n";

  mk_sets_form();
}
print "<br>\n";

print "<a href=mailto:ravi\@girihlet.com> Contact </a> for criticisms/suggestions/bugs \n";
print "<br>\n";
print "<p>\n";
print "<img width=1000 src=fig/ill_tru.jpg>\n";
print "</body></html>\n";

exit;

sub make_tbl{
    my $str=shift;

    my $file=shift;

    if(defined($file)){ 
	open OM,">$file" or die "FAIL:$file";
	print OM "<html> <body> \n";
    } 
    if(!defined($str)){ 
	$str=",ACGGTA,TTGTCC
	ACGGTA,0,5
	TTGTCC,,0
    ";
    } 
    my @str=split(/\n/,$str);

    my $tbl_str=     "<table border=1>\n";
    my $head=$str[0];$head=~s/,/<\/th><th>/g;
    $tbl_str.="<tr> <th> #</th> <th> $head </th></tr>\n";
    my $cnt=0;
    for(my $i=1;$i<@str;$i++){
	next if($str[$i]=~/^\s*$/);
	$str[$i]=~s/,/<\/td><td>/g;
	$cnt++;
	$tbl_str.= "<tr><td> $cnt</td> <td> $str[$i] </td></tr>\n";
    }
    $tbl_str.= "</table>\n";

    if(defined($file)){ 
	print OM $tbl_str;
	print OM "</body></html> \n";
	close OM;
    }else { print $tbl_str;} 
} 


sub seq_row{ 
  my $seq_name=shift;
  my $seq=shift;
  my $red=shift;
    my $l=length($seq);
  if(!defined($l) || $l ==0){ $l=23;}
  
  print " <tr>  <td> $seq_name </a></td> <td>  ";
  my $lm=$l+15;
  $l+=10;
  my $col="";
  if($red){ $col="color: red;"}
  print "<input style=\"text-align: left; $col\" type=string name=$seq_name  value=$seq size=$l maxlength=$lm/></td> ";
  print "</tr>\n";
}

sub mk_sets_form{

    print "<form action=$self method=post>\n";
    print "<input type=\"hidden\" name=\"res\" value=\"1\">\n";

    print "<table> <tr> <th> Name </th><th> Sequence &nbsp;&nbsp; </th> </tr>\n";



    seq_row("FC1",$FC1);
    seq_row("FC2",$FC2);

    seq_row("SP1",$SP1);
    seq_row("SP2",$SP2);
    seq_row("BC1",$BC1,1);
    print "
       <tr> <td style=\"vertical-align: center;\"> custom F primer </td> <td>
	    <textarea name=CFP rows=1 cols=24></textarea> </td></tr>
       <tr> <td style=\"vertical-align: center;\"> custom R primer </td> <td>
	    <textarea name=CRP rows=1 cols=24></textarea> </td></tr>
</table>\n";
print "<input type=\"Submit\">    </form>";

} 


