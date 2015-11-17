#!/usr/bin/perl

use strict;
use Date::Manip;

open(INF,"<transactions.csv") or die "can't open transactions.csv";
<INF>;
my %t_by_date = ();
my %t_by_day_of_week = ();
while($_=<INF>) {
   chomp($_);
   $_=~s/^"//g;
   $_=~s/",$//g;
   
   (my $category,my $subcategory,my $date,my $location,my $payee,my $description,my $method,my $amount) = split('","',$_);
   $amount =~ s/\$//g;
   my $pdate = ParseDate($date);
   my $d = UnixDate($pdate,'%Y%m%d,%Y,%m,%W,%j,%d,%w');
   $t_by_date{$d} += $amount+1-1;
   $t_by_day_of_week{UnixDate($pdate,'%w')} += $amount+1-1;
}

foreach my $date (sort keys %t_by_date) {
   print "$date,$t_by_date{$date}\n";
}

foreach my $date (sort keys %t_by_day_of_week) {
   print "$date - $t_by_day_of_week{$date}\n";
}

exit;

=begin comment
   my $pdate = ParseDate($date);
   my $day_of_week = UnixDate($pdate,'%w');
   my $day_of_month = UnixDate($pdate,'%e');
   my $day_of_year = UnixDate($pdate,'%j');
   my $week_of_year = UnixDate($pdate,'%W');
   my $month_of_year = UnixDate($pdate,'%m');
   my $year = UnixDate($pdate,'%Y');
   #print "$amount; $date - $year, $month_of_year, $week_of_year, $day_of_week, $day_of_month, $day_of_year\n";
=end comment

=cut

