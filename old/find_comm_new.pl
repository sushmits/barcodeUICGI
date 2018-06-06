use strict;

use Text::Levenshtein qw(distance);

my $str=`cut -f 3 -d , sequences.csv `;

my @wrds=split(/\n/,$str);

my $w1= "ACATGA";
my $w2= "ACTGAT";


my $w1= "ACTTGA";
my $w2= "ACTGAT";

my $w1="CGACTGGA";
my $w2="CGATGT";
my @w=(
   ["ACTTGA","ACTGAT"],
    ["CGACTGGA","CGATGT"],
    ["CGACTGGA","CGACTTGG"]
   );

my @bc;

foreach(@wrds){if($_!~/barcode/){ push(@bc,$_);}} # print "<$_>\n";}}


for(my $i=0;$i<@bc;$i++){    
    my $w1_ref=$bc[$i];

    for(my $j=$i+1;$j<@bc;$j++){    
	my $w2_ref=$bc[$j];
#	print "$i,$j w12=\n<$w1_ref>\n<$w2_ref>\n";
#	my ($w1,$w2)=($w1_ref,$w2_ref);
#	my $d=distance($w1,$w2)	if($d > 2){next;}
	my ($myd,$code)=my_dist($w1_ref,$w2_ref);
	if($code){ 
	    print "$w1_ref,$w2_ref,dist=$myd\n";
	} 
    } 
} 

exit;
sub hamming{
    my $w1=shift;
    my $w2=shift;
    my @w1=split(//,$w1);
    my @w2=split(//,$w2);
    my $d=0;
    for(my $i=0;$i<@w1;$i++){ 
	if($w1[$i] ne $w2[$i]){ 
	    $d++
	} 
    } 
    return $d;
} 

sub my_dist{
    my $w1=shift;
    my $w2=shift;
    
    if(length($w1) ==6 || length($w2)==6){ 
	$w1=~s/^(\w{6})\w+$/$1/;
	$w2=~s/^(\w{6})\w+$/$1/;
    } 
    my $d=distance($w1,$w2);

    if($d == 1){return ($d,0);}
    if($d > 2){ return ($d,0);}

    if($d == hamming($w1,$w2)){ 
#	print "hamming agrees,d=$d so correct\n";
	return ($d,0);
	next;
    } 
	
#    print "$w1\n$w2\n";
#    print "d=$d\n";

    my @w1=split(//,$w1);
    my @w2=split(//,$w2);
    my $ii=0;
    while($w1[$ii] eq $w2[$ii]){ 
	$ii++;
    } 
    if($ii > 0){ 
	my $w1_new="";
	for(my $jj=$ii;$jj<@w1;$jj++){$w1_new.=$w1[$jj];} 
	$w1=$w1_new;
	my $w2_new="";
	for(my $jj=$ii;$jj<@w2;$jj++){$w2_new.=$w2[$jj];} 
	$w2=$w2_new;
	#print "new w1=$w1\n";
	#print "new w2=$w2\n"; 
    }
    
#    print "removed the first common nucleotides\n$w1\n$w2\n";
#    print "d=$d\n";

    my $l=length($w1);
    my $DBG=0;
    if(check_nm($w1,$w2,$l-1,0,$DBG)){ 
#	print "$l-1 match found\n";
	$d++;
	return ($d,1);#    next;
    } 
    if(check_nm($w1,$w2,$l-2,1,$DBG)){ 
	#print "$l-2,1 match found\n";
	$d++;
	return ($d,1);
    } 
    if(check_nm($w1,$w2,1,$l-2,$DBG)){ 
	#print "1,$l-2 match found\n";
	$d++;
	return ($d,1);
    } 
    if($l >= 5){ 
	if(check_nm($w1,$w2,2,$l-3,$DBG)){ 
	 #   print "2,$l-3 match found\n";
	    $d++;
	    return ($d,1);
	} 
	if(check_nm($w1,$w2,$l-3,2,$DBG)){ 
	  #  print "$l-3,2 match found\n";
	    $d++;
	    return ($d,1);
	} 
    } 
    if($l >= 6){ 
	
	if(check_nm($w1,$w2,3,$l-4,$DBG)){ 
#		print "3,$l-4 match found\n";
	    $d++;
	    return ($d,1);
	} 
	if(check_nm($w1,$w2,$l-4,3,$DBG)    ){ 
#	    print "$l-4,3 match found\n";
	    $d++;
	    return ($d,1);
	} 
    } 
    ## does not ever come here.
    exit;
}

exit;


sub check_32{
    my $w1=shift;
    my $w2=shift;
    my @mer3;
    for(my $i=0;$i<=(length($w1)-3);$i++){
	push(@mer3,[$i,substr($w1,$i,3)]);
    }
    my @mer2;
    for(my $i=0;$i<=(length($w1)-2);$i++){
	push(@mer2,[$i,substr($w1,$i,2)]);
    }

    for(my $i=0;$i<=(length($w2)-3);$i++){
	my $good3=0;
	my $goodi=0;
	foreach my $m(@mer3){
	    my ($ii,$m3)=@{$m};
	    if($w2=~/^.{$i}$m3/){
		$good3=1;
		$goodi=$ii;
		last;
	    } 
	}
	if($good3){ 
	    my $j=$i+3; ## ensures 4mer is also found, (otherwise use 3)

	    my $good2=0;
	    for(my $k=$j;$k<=(length($w2)-2);$k++){
		foreach my $m(@mer2){
		    my ($ii,$m2)=@{$m};
		    if($ii <= $goodi){ next;}
		    if($w2=~/^.{$k}$m2/){
			$good2=1;
			last;
		    } 
		}
		if($good2){ return 1;}
	    }
	} 
    } 
    return 0;
}




sub check_41{
    my $w1=shift;
    my $w2=shift;
    my @mer4;
    for(my $i=0;$i<=(length($w1)-4);$i++){
	push(@mer4,[$i,substr($w1,$i,4)]);
    }
	my @mer1;
#    my @mer1=split(//,$w1);
    for(my $i=0;$i<=(length($w1)-1);$i++){
	push(@mer1,[$i,substr($w1,$i,1)]);
    }

    for(my $i=0;$i<=(length($w2)-4);$i++){
	my $good4=0;
	my $goodi=0;
	foreach my $m(@mer4){
	    my ($ii,$m4)=@{$m};
	    if($w2=~/^.{$i}$m4/){
		$good4=1;
		$goodi=$ii;
		last;
	    } 
	}
	if($good4){ 
	    my $j=$i+4; ## ensures 4mer is also found, (otherwise use 4)

	    my $good1=0;
	    for(my $k=$j;$k<=(length($w2)-1);$k++){
		foreach my $m(@mer1){
		    my ($ii,$m1)=@{$m};
		    if($ii <= $goodi){ next;}
		    if($w2=~/^.{$k}$m1/){
			$good1=1;
			last;
		    } 
		}
		if($good1){ return 1;}
	    }
	} 
    } 
    return 0;
}


sub check_nm{
    my $w1=shift;
    my $w2=shift;
    my $nn=shift;
    my $mm=shift;

    my $DBG=shift;
    $DBG=0 if(!defined($DBG));

    my @mer3;
    for(my $i=0;$i<=(length($w1)-$nn);$i++){
	push(@mer3,[$i,substr($w1,$i,$nn)]);
    }

    my @mer2;
    if($mm>0){ 
	for(my $i=0;$i<=(length($w1)-$mm);$i++){
	    push(@mer2,[$i,substr($w1,$i,$mm)]);
	}
    } 

    for(my $i=0;$i<=(length($w2)-$nn);$i++){
	my $good3=0;
	my $goodi=0;
	foreach my $m(@mer3){
	    my ($ii,$m3)=@{$m};
	    if($w2=~/^.{$i}$m3/){
		$good3=1;
		$goodi=$ii;
		last;
	    } 
	}
	if($good3){ 
#	    print "good=$good3\n" if($DBG);
	    my $j=$i+$nn; ## ensures 4mer is also found, (otherwise use 3)

	    if($mm==0){ 
		return 1;
	    } 

	    my $good2=0;
	    for(my $k=$j;$k<=(length($w2)-$mm);$k++){
		foreach my $m(@mer2){
		    my ($ii,$m2)=@{$m};
		    if($ii <= $goodi){ next;}
		    if($w2=~/^.{$k}$m2/){
			$good2=1;
			last;
		    } 
		}
		if($good2){ return 1;}
	    }
	} 
    } 
    return 0;
}


exit;
