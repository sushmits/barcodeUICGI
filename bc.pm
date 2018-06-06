use strict;
use warnings;
package bc;
use lib("/home/ravi","/Users/ravi");
use common::generic::myUtil;
my $my=common::generic::myUtil->new();

use Text::Levenshtein qw(distance);

## ## ## ## ## ## ## ## ## ## ## ## ## ## 
### parsing the files
## ## ## ## ## ## ## ## ## ## ## ## ## ## 
my @bc;
my %set_cnt;
my %set;
my %bc_info;
my @dist;

my $bclist="./data/bc_list.csv";
my $bcdist="./data/bc_dist.csv";
my $master_csv="./data/sequences.csv";

##### ##### ##### ##### ##### ##### #####
##### new constructor.
##### ##### ##### ##### ##### ##### #####
sub new{
 my $name = shift;
 my $class = ref($name) || $name;
 my $this = {};
 bless $this,$class;
 return $this;
}




sub gen_files{
    my $this=shift;
  my $str=`cut -f 1,2,3 -d , $master_csv `;
  my @wrds=split(/\n/,$str);

  open OUT,">bc_list.csv" or die "FAIL:bc_list.csv";
  foreach my $wrd(@wrds){
      if($wrd!~/barcode/){ 
	  my ($ind,$set,$bc)=$wrd=~/(\w+),(\w+),(\w+)/;
	  #	print "bc=<$bc>,set=<$set>\n";
#	  push(@{$set{$set}},[$bc,$ind]);
	  my $num=@bc;
#	  $bc_info{"$bc.$set"}=[$set,$num,$ind];
	  print OUT "$num,$bc,$set,$ind\n";
	  push(@bc,$bc);
      }
  }
  close OUT;

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
  ### parsed the files
  ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
  #print "filling Dist\n";
  open OUT,">bc_dist.csv" or die "FAIL:bc_dist.csv";
  for(my $i=0;$i<@bc;$i++){    
      my $w1_ref=$bc[$i];
      for(my $j=$i+1;$j<@bc;$j++){    
	  my $w2_ref=$bc[$j];
	  my $ham_grade=hamming_grade($w1_ref,$w2_ref);
	  my ($myd,$ham,$code)=my_dist($w1_ref,$w2_ref);
#	  $dist[$i]->[$j]=[$myd,$ham,$ham_grade];
	  print OUT "$i,$j,$myd,$ham,$ham_grade\n";
#	  print "$w1_ref\n$w2_ref\n";	  print "$i,$j,$myd,$ham,$ham_grade\n";

	  if($code){ 
	      ## ones that have distance changed
	      #	    print "$w1_ref,$w2_ref,dist=$myd\n";
	  } 
      } 
  }
  close OUT;
}


sub read_data{
    my $this=shift;
#	my $str=`cut -f 2,3 -d , sequences.csv `;
#	my @wrds=split(/\n/,$str);
    open OUT,$bclist or die "FAIL:$bclist";
    while(my $line=<OUT>){
	chomp($line);
	if($line=~/^\s*$/){ next;}
	my ($num,$bc,$set,$ind)=split(/,/,$line);
#	  print OUT "$num,$bc,$set,$ind\n";
	push(@{$set{$set}},[$bc,$num]);
	$bc[$num]=[$bc,$ind];
	$bc_info{"$bc.$num"}=[$set,$ind];
    }
    close OUT;

    foreach my $nm(keys %set){
#	print "bc.pm, read_data setname=$nm\n";
	$set_cnt{$nm}=@{$set{$nm}};
    } 
    ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
    ### parsed the files
    ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
#    print "bc.pm read_data filling Dist\n";
	
    open OUT,"$bcdist" or die "FAIL:$bcdist";
    while(my $line=<OUT>){
	chomp($line);
	next if($line=~/^\s*$/);
	my ($i,$j,$myd,$ham,$ham_grade)=split(/,/,$line);	    
	$dist[$i]->[$j]=[$myd,$ham,$ham_grade];
    }
    close OUT;
}
###### ###### ###### ###### ###### ###### ###### ######
###### validate_set
###### ###### ###### ###### ###### ###### ###### ######
sub validate_set{
    my $this=shift;
    my $P_ret_set=shift;
    return(valid_set($P_ret_set));
}

###### ###### ###### ###### ###### ###### ###### ######
###### valid_set
###### ###### ###### ###### ###### ###### ###### ######
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#### valid_set
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 

sub find_bad_in_set{
    my $this=shift;
    my $P_ret_set=shift;
    my $tot=@{$P_ret_set};
    my $good=1;
    my $ret_str="";
    for(my $i=0;$i<$tot;$i++){
	for(my $j=($i+1);$j<$tot;$j++){
	    my ($d,$h,$myh)=my_dist($P_ret_set->[$i],$P_ret_set->[$j]);
	    if($d < 3){
		$ret_str.=$P_ret_set->[$i].":".$P_ret_set->[$j].":$d,";
		$good=0;	   
	    }
	}
    }
    $ret_str=~s/,$//;
    return ($good,$ret_str);
}


###### ###### ###### ###### ###### ###### ###### ######
###### valid_set
###### ###### ###### ###### ###### ###### ###### ######
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#### valid_set
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
sub valid_set{
    my $P_ret_set=shift;
    my $tot=@{$P_ret_set};
    for(my $i=0;$i<$tot;$i++){
	for(my $j=($i+1);$j<$tot;$j++){
	    my ($d,$h,$myh)=my_dist($P_ret_set->[$i],$P_ret_set->[$j]);
	    if($d < 3){		return 0;	    }
	}
    }
     return 1;
}
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#### #### mk_dist_matrix
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
sub mk_dist_matrix{
    my $this=shift;
    my $P_ret_set=shift;
    my $tot=@{$P_ret_set};

    my $ret="";
    for(my $i=0;$i<$tot;$i++){
	$ret.=",".$P_ret_set->[$i];
    }
    $ret.="\n";
    for(my $i=0;$i<$tot;$i++){
	$ret.=$P_ret_set->[$i];
	for(my $j=0;$j<$i;$j++){
	    $ret.=",";
	}
	$ret.=",0";
	for(my $j=($i+1);$j<$tot;$j++){
	    my ($d,$h,$myh)=my_dist($P_ret_set->[$i],$P_ret_set->[$j]);
	    if($d < 3){
		$ret.=",$d:BAD";
	    } else{
		$ret.=",$d";
	    }
	}
	$ret.="\n";
    }
    return $ret;
}


##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 
##### pick_from_set
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 
sub rand_arr{
    my $P_arr=shift;
    my $n=@{$P_arr};
    for(my $i=0;$i<$n;$i++){ 
	my $j=int(rand($n));

#	print "$n,switch($i,$j)\n";
	my $tmp=$P_arr->[$i];
	$P_arr->[$i]=$P_arr->[$j];
	$P_arr->[$j]=$tmp;
    }
}

sub pick_from_set{
    my $this=shift;
    my $set=shift;
    my $total=shift;
    my $P_pick_set=shift;

#    print "bc.pm pick_from_set, set=$set,total=$total\n";
    my @tmpset=@{$set{$set}};
    rand_arr(\@tmpset);

    my %bad;
    my $diff=$total-@{$P_pick_set};
    for(my $j=0;$j<$diff;$j++){
	    my @t_try;
	if(@{$P_pick_set} == $total){return;}
	for(my $i=0;$i<@tmpset;$i++){
	    if(defined($bad{$i})){ next;}
	    if(@{$P_pick_set} == $total){return;}
	    my ($bct,$num)=@{$tmpset[$i]};
	    my ($myd,$ham_av,$ham_grade_av)=$this->dist_to_ret_set($bct,$num,$P_pick_set);
	    if($myd < 3){$bad{$i}=1;next;}
	#    print "ham_grade_av $i=$ham_grade_av\n";
	    if($ham_grade_av > 8.0){## big enough so pick
		$bad{$i}=1;
		push(@{$P_pick_set},[$bct,$num]);
		@t_try=();
		next;
	    } else { 
		push(@t_try,[$ham_grade_av,$bct,$num]);
	    }
	}
	if(@t_try>0){ 
	    @t_try=sort{$b->[0] <=> $a->[0]} @t_try;
	    push(@{$P_pick_set},[$t_try[0]->[1],$t_try[0]->[2]]);
	}
    } 
    #    if(@{$P_pick_set} == $total){last;}
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### mk_div
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
sub mk_div{
  my $this=shift;
  my $P_set=shift;

  my @pos;
  my $tot=@{$P_set};
  my $minL=8;
  for(my $i=0;$i<@{$P_set};$i++){
      my $L=length($P_set->[$i]);
      if($L<$minL){$minL=$L;} 
      my @tmp=split(//,$P_set->[$i]);
      for(my $j=0;$j<$minL;$j++){ 
	  $pos[$j]->{$tmp[$j]}++;
      } 
  } 
  my @w=qw ( A C G T );
  my $ret="";
  my $retf="";
  for(my $i=0;$i<$minL;$i++){
      $ret.=",$i";
      $retf.=",$i";
  }
  $ret.="\n";
  $retf.="\n";
  for(my $i=0;$i<@w;$i++){ 
      $ret.= "$w[$i]";
      $retf.= "$w[$i]";
    for(my $j=0;$j<$minL;$j++){ 
      my $f=defined($pos[$j]->{$w[$i]}) ? $pos[$j]->{$w[$i]}:0;
      $ret.= ",$f";
      $f=sprintf("%.3f",$f/$tot);
      $retf.= ",$f";
    } 
      $ret.= "\n";
      $retf.= "\n";
  } 
  return ($ret,$retf);
} 


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### get_barcodes
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
sub get_barcodes{
  my $this=shift;
  my $pick_str=shift;
  my $pre_set_str=shift;
    
  $pick_str=~s/\s+//g;
  my @picks=split(/,/,$pick_str);
  my @pick_cnt;
  foreach(@picks){ my @tmp=split(/:/,$_);push(@pick_cnt,[@tmp]);}

  my  @ret_set=();
  
  my $tot=0;

  my @tmp_set; #only used to validate sets

  if(defined($pre_set_str) && $pre_set_str=~/\S/){
    $pre_set_str=~s/(\w)\s+(\w)/$1,$2/msg;
    $pre_set_str=~s/\s+//g;
    if($pre_set_str!~/:/){ 
	@tmp_set=split(/,/,$pre_set_str);
	my $cnt=0;
	foreach my $ts(@tmp_set){ 
	    $cnt++;
	    push(@ret_set,[$ts,"user$cnt"]);
	} 
    } else { ## names are attached to the barcode with :
	my @t_tmp_set=split(/,/,$pre_set_str);
	foreach my $tts (@t_tmp_set){
	    my ($t_bc,$t_ind)=split(/:/,$tts);
	    push(@tmp_set,$t_bc);
	    push(@ret_set,[$t_bc,$t_ind]);
	}
    } 
    ## initialize with the first set input
    $tot=@ret_set;
  } 
  ## fill out counts for each set here
  for(my $i=0;$i<@pick_cnt;$i++){ 
      $tot+=$pick_cnt[$i]->[1];
      $pick_cnt[$i]->[1]=$tot;
  }
  my $mess="";

  
  my $def_t=0; ## deficits in sets due to lack of picks (say 24 tru, but only 23 designs possible)
  for(my $i=0;$i<@pick_cnt;$i++){ 
      my ($set,$pick_tot)=@{$pick_cnt[$i]};
      $pick_tot-=$def_t;
    $this->pick_from_set($set,$pick_tot,\@ret_set);
    if($pick_tot > @ret_set){
	my $def=$pick_tot - @ret_set;
	$mess.="<p><b> $set is missing $def barcodes, due to constraints</b></p>";
	$def_t+=$def;
    }  
  } 
  my @final_set;

#  print "ret_set=\n";$my->pp(\@ret_set);exit;
    
  foreach(@ret_set){ 
    my ($t,$n)=@{$_};
    if($n!~/^\d+$/){ push(@final_set,[$t,$n,"user"]);}
    else { 
	## push in index of the barcodes
	my ($l_set,$l_ind)=@{$bc_info{"$t.$n"}};#=[$set,$ind];
	#	push(@final_set,[$t,$bc[$n]->[1]]);
	push(@final_set,[$t,$l_ind,$l_set]);
    } 
  }
  return (\@final_set,$mess);
  #    foreach(@ret_set){print "$_\n";} 
}

#### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#### #### #### #### #### #### ret_dists
#### #### #### #### #### #### #### #### #### #### #### #### #### #### 
sub ret_dists{
    my $this=shift;
    my $w1_ref=shift;
    my $w2_ref=shift;
    my $ham_grade=hamming_grade($w1_ref,$w2_ref);
    my ($myd,$ham,$code)=my_dist($w1_ref,$w2_ref);
    return ($myd,$ham,$ham_grade);
}

sub dist_to_ret_set{
    my $this=shift;
    my $mem=shift;
    my $num=shift;
    my $P_ret_set=shift;

    my $myd_min=1000;
    my $ham_av=0;
    my $ham_grade_av=0;

    #    my $num=$bc_info{$mem}->[1];

    ## first element, anything is acceptable
    if(@{$P_ret_set}==0){ 
	return (10,10,10);
    }
    
    my $cnt;
    foreach my $tlbc (@{$P_ret_set}){ 
      my ($lbc,$lnum)=@{$tlbc};
	my ($myd,$ham,$hamg);
#	if(!defined($bc_info{$lbc})){
      if($lnum!~/^\d+$/){ 
	($myd,$ham,$hamg)=$this->ret_dists($mem,$lbc);
      } else{ 
	if($lnum==$num){ ($myd,$ham,$hamg)=(0,0,0);	    } 
	elsif($lnum < $num){	($myd,$ham,$hamg)=@{$dist[$lnum]->[$num]};}
	else  {
#	    print "num=$num, lnum=$lnum\n";
	    ($myd,$ham,$hamg)=@{$dist[$num]->[$lnum]};   
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

### ### ### ### ### ### ### ### ### ### ### 
### hamming distance weighted by position
### ### ### ### ### ### ### ### ### ### ### 
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
	if($w1[$i] ne $w2[$i]){$d+=(3 - $i * 0.5);} 
    } 
    return $d;
} 
### ### ### ### ### ### ### ### ### ### ### 
### pure hamming distance
### ### ### ### ### ### ### ### ### ### ### 
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
### ### ### ### ### ### ### ### ### ### ### 
### my_dist  ---mostly levenshtein, with some corrections for 2-mers 
### ### ### ### ### ### ### ### ### ### ### 

sub my_dist{
    my $w1=shift;
    my $w2=shift;
    

    my $rw1=$w1;
    my $rw2=$w2;
    if(length($w1) ==6 || length($w2)==6){ 
	$w1=~s/^(\w{6})\w+$/$1/;
	$w2=~s/^(\w{6})\w+$/$1/;
    } 
    my $d=distance($w1,$w2);
    my $ham=hamming($w1,$w2);  

    if($d == $ham){ 
	#	print "hamming agrees,d=$d so correct\n";
	return ($d,$ham,0);
    } 
  
#    print "$w1,$w2 d=$d,ham=$ham\n";

    ## no need to change d in these cases
    if($d == 1){return ($d,$ham,0);}
    if($d > 2){ return ($d,$ham,0);}

    ## change d in case the levenshtein distance is == 2 if it arises from a shift
    ## (so insertion + deletion is needed for the thing to coincide)

    my @w1=split(//,$w1);
    my @w2=split(//,$w2);

    my $l1=length($w1);

    ### finds 3,3 or other patterns, exhaustively
    for(my $dd=0;$dd<($l1-1);$dd++){ 
	if(check_nm($w1,$w2,$dd,$l1-$dd-2,0)){ ##XXXXX
#	    print "fail for  dd=$dd\n";
	    $d++;
	    return ($d,$ham,1);#    next;
	} 
    } 
    ## this is only for cases like 2,2,2 or 2,3,2  AAGAGTCT  AACGAGCT
    my $ii=0;
    while($w1[$ii] eq $w2[$ii]){ 
	$ii++;
    } 
#    print "ii=$ii\n";    print "$rw1,$rw2, $w1,$w2\n";    exit;
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
    ## does not ever come here., usually means case that was not considered earlier.
    print "rw1=$rw1,w1=$w1,rw2=$rw2, w2=$w2, l=$l\n";
    print "came to impossible place\n";
    die "";
    exit;
}

### ### ### ### ### ### ### ### ### ### ### 
### used 
### ### ### ### ### ### ### ### ### ### ### 
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



#### #### #### #### #### #### #### #### #### #### #### #### 
#### check_nm  -- checks two words for common n-mer followed by  a common m-mer
#### #### #### #### #### #### #### #### #### #### #### #### 
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

1;


