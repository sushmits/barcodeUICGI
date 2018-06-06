use strict;
use Text::Levenshtein qw(distance);
## ## ## ## ## ## ## ## ## ## ## ## ## ## 
### parsing the files
## ## ## ## ## ## ## ## ## ## ## ## ## ## 
my @bc;
my %set;
my %bc_info;
my @dist;

my $bclist="./data/bc_list.csv";
my $bcdist="./data/bc_dist.csv";

my $pick_str=shift; ### amar:4,neb:4,tru:2
my $pre_set=shift; ## ACGGTA,TTGCAA

die "Usage:$0 amar:4,neb:4,tru:2 ACGGTA,TTGTCC" if(!defined($pick_str));

init();


$pick_str=~s/\s+//g;

my @picks=split(/,/,$pick_str);

my @pick_cnt;
foreach(@picks){ my @tmp=split(/:/,$_);push(@pick_cnt,[@tmp]);}

my  @ret_set;



if($pre_set=~/\S/){ 
    $pre_set=~s/\s+//g;
    @ret_set=split(/,/,$pre_set);
    if(!valid_set(\@ret_set)){
	print "set not valid\n";
	exit;
    } 
    my $tot=@ret_set;
    for(my $i=0;$i<@pick_cnt;$i++){ 
	$tot+=$pick_cnt[$i]->[1];
	$pick_cnt[$i]->[1]=$tot;
    } 
} else {
    my $set1=$pick_cnt[0]->[0];
    my @tmpset=@{$set{$set1}};
    push(@ret_set,$tmpset[int(rand(@tmpset))]);
    my $tot=0;
    for(my $i=0;$i<@pick_cnt;$i++){ 
	$tot+=$pick_cnt[$i]->[1];
	$pick_cnt[$i]->[1]=$tot;
    } 
} 

for(my $i=0;$i<@pick_cnt;$i++){ 
    my ($set,$pick)=@{$pick_cnt[$i]};
    pick_set($set,$pick,\@ret_set);
} 

foreach(@ret_set){print "$_\n";} 


exit;



sub pick_set{
    my $set=shift;
    my $pick=shift;
    my $P_pick_set=shift;

    my @tmpset=@{$set{$set}};

    while(@{$P_pick_set} < $pick){ 
	my @t_try;
	foreach my $t (@tmpset){ 
	    my ($myd,$ham_av,$ham_grade_av)=dist_to_ret_set($t,$P_pick_set);
	    if($myd <=2){next;}
	    push(@t_try,[$ham_grade_av,$t]);
	} 
	@t_try=sort{$b->[0] <=> $a->[0]} @t_try;
	push(@{$P_pick_set},$t_try[0]->[1]);
    }
} 

exit;
sub ret_dists{
    my $w1_ref=shift;
    my $w2_ref=shift;
    my $ham_grade=hamming_grade($w1_ref,$w2_ref);
    my ($myd,$ham,$code)=my_dist($w1_ref,$w2_ref);
    return ($myd,$ham,$ham_grade);
}

sub dist_to_ret_set{
    my $mem=shift;
    my $P_ret_set=shift;

    my $myd_min=1000;
    my $ham_av=0;
    my $ham_grade_av=0;

    my $num=$bc_info{$mem}->[1];

    my $cnt;
    foreach my $lbc (@{$P_ret_set}){ 
	my ($myd,$ham,$hamg);
	if(!defined($bc_info{$lbc})){
	    ($myd,$ham,$hamg)=ret_dists($mem,$lbc);
	} else{ 
	    my $id=$bc_info{$lbc}->[1];	
	    if($id==$num){
		($myd,$ham,$hamg)=(0,0,0);
	    } 
	    elsif($id < $num){ 
		($myd,$ham,$hamg)=@{$dist[$id]->[$num]};
	    } else  {
		($myd,$ham,$hamg)=@{$dist[$num]->[$id]};
	    }
	}
	if($myd_min > $myd){ $myd_min=$myd;}
	$ham_av+=$ham;
	$ham_grade_av+=$hamg;
	$cnt++;
    } 
    $ham_av/=$cnt;
    $ham_grade_av/=$cnt;
    return ($myd_min,$ham_av,$ham_grade_av);
} 

exit;

sub hamming_grade{
    my $w1=shift;
    my $w2=shift;
    my @w1=split(//,$w1);
    my @w2=split(//,$w2);
    my $d=0;

    my $num=@w1;

    if($num > @w2){ $num = @w2;}
    
    $num=6;
    for(my $i=0;$i<$num;$i++){ 
	if($w1[$i] ne $w2[$i]){$d+=(3 - $i*.0.5);} 
    } 
    return $d;
} 

sub hamming{
    my $w1=shift;
    my $w2=shift;
    my @w1=split(//,$w1);
    my @w2=split(//,$w2);
    my $d=0;

    my $num=@w1;

    if($num > @w2){ $num = @w2;}

    for(my $i=0;$i<$num;$i++){ 
	if($w1[$i] ne $w2[$i]){$d++;} 
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

    my $ham=hamming($w1,$w2);
    if($d == $ham){ 
	#	print "hamming agrees,d=$d so correct\n";
	return ($d,$ham,0);
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
	return ($d,$ham,1);#    next;
    } 
    if(check_nm($w1,$w2,$l-2,1,$DBG)){ 
	#print "$l-2,1 match found\n";
	$d++;
	return ($d,$ham,1);#    next;
    } 
    if(check_nm($w1,$w2,1,$l-2,$DBG)){ 
	#print "1,$l-2 match found\n";
	$d++;
	return ($d,$ham,1);#    next;
    } 
    if($l >= 5){ 
	if(check_nm($w1,$w2,2,$l-3,$DBG)){ 
	    #   print "2,$l-3 match found\n";
	    $d++;
	    return ($d,$ham,1);#    next;
	} 
	if(check_nm($w1,$w2,$l-3,2,$DBG)){ 
	    #  print "$l-3,2 match found\n";
	    $d++;
	    return ($d,$ham,1);#    next;
	} 
    } 
    if($l >= 6){ 
	
	if(check_nm($w1,$w2,3,$l-4,$DBG)){ 
	    #		print "3,$l-4 match found\n";
	    $d++;
	    return ($d,$ham,1);#    next;
	} 
	if(check_nm($w1,$w2,$l-4,3,$DBG)    ){ 
	    #	    print "$l-4,3 match found\n";
	    $d++;
	    return ($d,$ham,1);#    next;
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
sub     init{
#	my $str=`cut -f 2,3 -d , data/sequences.csv `;
#	my @wrds=split(/\n/,$str);


    
	open OUT,$bclist or die "FAIL:$bclist";
	while(my $line=<OUT>){
	    chomp($line);
	    if($line=~/^\s*$/){ next;}
	    my ($num,$bc,$set)=split(/,/,$line);
	    push(@{$set{$set}},$bc);
	    $bc[$num]=$bc;
	    $bc_info{$bc}=[$set,$num];
	}
	close OUT;
	## ## ## ## ## ## ## ## ## ## ## ## ## ## 
	### parsed the files
	## ## ## ## ## ## ## ## ## ## ## ## ## ## 
	#print "filling Dist\n";

	
	open OUT,"$bcdist" or die "FAIL:$bcdist";
	while(my $line=<OUT>){
	    chomp($line);
	    next if($line=~/^\s*$/);
	    my ($i,$j,$myd,$ham,$ham_grade)=split(/,/,$line);	    
	    $dist[$i]->[$j]=[$myd,$ham,$ham_grade];
	}
	close OUT;
}

sub valid_set{
    my $P_ret_set=shift;
    my $tot=@{$P_ret_set};
    my $ret="";
    for(my $i=0;$i<$tot;$i++){
	for(my $j=($i+1);$j<$tot;$j++){
	    my ($d,$h,$myh)=my_dist($P_ret_set->[$i],$P_ret_set->[$j]);
	    if($d < 3){
		$ret.="$i,$j:$d:XX\n";
	    } else{
		$ret.="$i,$j:$d\n";
	    }
	}
    }
    if($ret=~/XX/){
	print "$ret\n";
	return 0;
    }
    return 1;
}
