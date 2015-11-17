#!/usr/bin/perl

use strict;
use Date::Manip;

open(INF,"<Checking1.csv") or die "can't open Checking1.csv";
my %expenses_by_date = ();
my %income_by_date = ();
my %expense_count_by_date = ();
my %income_count_by_date = ();
my %t_by_date = ();
my %t_by_day_of_week = ();
while($_=<INF>) {
   chomp($_);
   $_=~s/^"//g;
   $_=~s/"$//g;
   (my $date,my $amount,my $xx,my $xxx,my $payee) = split('","',$_);
   $amount =~ s/\$//g;
   my $pdate = ParseDate($date);
   my $d = UnixDate($pdate,'%Y%m%d,%Y,%m,%W,%j,%d,%w');
   #my $d = UnixDate($pdate,'%Y%m%d,%j,%d,%w');
   $amount = $amount +1-1;
   if($amount<0 and $amount > -4000 and 1) {
      $expenses_by_date{$d} += $amount;
      $expense_count_by_date{$d} += 1;
   } elsif ($amount>0 and $amount < 6000 and 1) {
      $income_by_date{$d} += $amount;
      $income_count_by_date{$d} += 1;
   }
   $t_by_date{$d} += $amount+1-1;
   $t_by_day_of_week{UnixDate($pdate,'%w')} += $amount+1-1;
}

my $switch = 1;
my $bal = 0;
my @run30_queue = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
my $run30 = 0;
my @run7_queue = (0,0,0,0,0,0,0);
my $run7 = 0;
foreach my $date (sort keys %t_by_date) {
   if(defined $expenses_by_date{$date} or defined $income_by_date{$date} and $switch) {
      my $delta = $expenses_by_date{$date}+$income_by_date{$date};
      print $expenses_by_date{$date}+$income_by_date{$date}.",$bal,$run7_queue[6],$run7_queue[5],$run7,$run30,$date\n";
      $bal+=$delta;
      $run7 += ($delta - shift @run7_queue);
      push @run7_queue, $delta;
      $run30 += ($delta - shift @run30_queue);
      push @run30_queue, $delta;
   }
   if(defined $income_by_date{$date} and !$switch) {
      print "$income_by_date{$date},$date\n";
   }
}

