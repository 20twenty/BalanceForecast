#!/usr/bin/perl

use strict;
use Date::Manip;

#my $last_date_s = UnixDate(ParseDate("11/13/2015"),'%s');
my $last_date_s = UnixDate(ParseDate("today"),'%s');
my $end_balance = 16872.23;
my $min_days_ago = 1000000;
my $max_days_ago = 0;

open(INF,"<Checking1.csv") or die "can't open Checking1.csv";
my %expenses_by_date = ();
my %income_by_date = ();
my %expense_count_by_date = ();
my %income_count_by_date = ();
my %t_by_date = ();
my %t_by_day_of_week = ();
my @transactions = ();
while($_=<INF>) {
   chomp($_);
   $_=~s/^"//g;
   $_=~s/"$//g;
   (my $date,my $amount,my $xx,my $xxx,my $payee) = split('","',$_);
   $amount =~ s/\$//g;
   my $pdate = ParseDate($date);
   my $days_ago = int(($last_date_s - UnixDate($pdate,'%s'))/(60*60*24)+0.5);
   #print "$days_ago\n";
   if($days_ago > $max_days_ago) {
      $max_days_ago = $days_ago;
   }
   if($days_ago < $min_days_ago) {
      $min_days_ago = $days_ago;
   }
   if(!defined $transactions[$days_ago]{'date_attr'}) {
      #$transactions[$days_ago]{'date_attr'} = $days_ago . "," . UnixDate($pdate,'%Y%m%d,%Y,%m,%W,%j,%d,%w');
      $transactions[$days_ago]{'date_attr'} = $days_ago . "," . UnixDate($pdate,'%Y,%m,%W,%j,%d,%w');
   }
   $amount = $amount +1-1;
   if($amount < 0) {
      $transactions[$days_ago]{'expense'} += $amount;
      $transactions[$days_ago]{'expense_count'} += 1;
      #$transactions[$days_ago]{'expense'} += 0;
      #$transactions[$days_ago]{'expense_count'} += 0;
   } elsif($amount > 0) {
      $transactions[$days_ago]{'income'} += $amount;
      $transactions[$days_ago]{'income_count'} += 1;
   }
   #$t_by_date{$d} += $amount+1-1;
   #$t_by_day_of_week{UnixDate($pdate,'%w')} += $amount+1-1;
}

close(INF);

#print "$min_days_ago\n";
#print "$max_days_ago\n";
$transactions[$min_days_ago]{'starting_balance'} = $end_balance-($transactions[$min_days_ago]{'income'}+$transactions[$min_days_ago]{'expense'});

my $max_lookback = 60;
for (my $i = $min_days_ago; $i <=$max_days_ago; $i++) {
   if(!defined $transactions[$i]{'expense'}) {$transactions[$i]{'expense'}=0;}
   if(!defined $transactions[$i]{'expense_count'}) {$transactions[$i]{'expense_count'}=0;}
   if(!defined $transactions[$i]{'income'}) {$transactions[$i]{'income'}=0;}
   if(!defined $transactions[$i]{'income_count'}) {$transactions[$i]{'income_count'}=0;}
   if($i>$min_days_ago) {
      $transactions[$i]{'starting_balance'} = $transactions[$i-1]{'starting_balance'}-($transactions[$i]{'income'}+$transactions[$i]{'expense'});
   }
   for(my $j=1; $j<=$max_lookback; $j++) {
      if($i-$j >= $min_days_ago) {
         $transactions[$i-$j]{'lookback'}[$j]{'expense'} += $transactions[$i]{'expense'};
         $transactions[$i-$j]{'lookback'}[$j]{'income'} += $transactions[$i]{'income'};
         $transactions[$i-$j]{'lookback'}[$j]{'expense_count'} += $transactions[$i]{'expense_count'};
         $transactions[$i-$j]{'lookback'}[$j]{'income_count'} += $transactions[$i]{'income_count'};
         for(my $k = $j; $k <= $max_lookback; $k++) {
            $transactions[$i-$j]{'slookback'}[$k]{'expense'} += $transactions[$i]{'expense'};
            $transactions[$i-$j]{'slookback'}[$k]{'income'} += $transactions[$i]{'income'};
            $transactions[$i-$j]{'slookback'}[$k]{'expense_count'} += $transactions[$i]{'expense_count'};
            $transactions[$i-$j]{'slookback'}[$k]{'income_count'} += $transactions[$i]{'income_count'};
         }
      }
   }
}


open(OUTF, ">transactions.csv") or die "Can't open transactions.csv";

print OUTF "w,delta,days_ago,Y,M,W,dayOfY,dayOfM,dayOfW,SatSun,bal";
for(my $j = 1; $j<=$max_lookback; $j++) {
   print OUTF ",lb${j}_exp,lb${j}_expc,lb${j}_inc,lb${j}_incc";
   print OUTF ",slb${j}_exp,slb${j}_expc,slb${j}_inc,slb${j}_incc";
}
print OUTF "\n";

for (my $i = $min_days_ago; $i <=$max_days_ago-$max_lookback; $i++) {
   my $d = DateCalc("today", "- $i days");
   my $dd = UnixDate($d,'%Y,%m,%W,%j,%d,%w');
   my $weekday = UnixDate($d,'%w');
   my $ss = 0;
   if($weekday=="6" or $weekday=="7") {
      $ss = 1;
   }
   my $weight = 1;
   if($transactions[$i]{'expense'} < -4000 or $transactions[$i]{'income'} > 6000) {
      $weight = 0;
   }
   if(defined $transactions[$i]{'date_attr'} or 1) {
      print OUTF $weight;
      print OUTF "," . ($transactions[$i]{'expense'}+$transactions[$i]{'income'});
      print OUTF "," . $i;
      print OUTF "," . $dd;
      print OUTF "," . $ss;
      #print OUTF "," . $transactions[$i]{'date_attr'};
      print OUTF "," . $transactions[$i]{'starting_balance'};
      for(my $j = 1; $j<=$max_lookback; $j++) {
         print OUTF "," . $transactions[$i]{'lookback'}[$j]{'expense'};
         print OUTF "," . $transactions[$i]{'lookback'}[$j]{'expense_count'};
         print OUTF "," . $transactions[$i]{'lookback'}[$j]{'income'};
         print OUTF "," . $transactions[$i]{'lookback'}[$j]{'income_count'};

         print OUTF "," . $transactions[$i]{'slookback'}[$j]{'expense'};
         print OUTF "," . $transactions[$i]{'slookback'}[$j]{'expense_count'};
         print OUTF "," . $transactions[$i]{'slookback'}[$j]{'income'};
         print OUTF "," . $transactions[$i]{'slookback'}[$j]{'income_count'};
      }
      print OUTF "\n";
   }
}

