#!/usr/bin/perl

use strict;
use Date::Manip;

open(INF,"<transactions.csv") or die "can't open transactions.csv";
<INF>;
my $tid = 0;
my %word_hash = ();
my %word_count= ();
while($_=<INF>) {
   chomp($_);
   $tid++;
   $_=~s/^"//g;
   $_=~s/",$//g;
   (my $category,my $subcategory,my $date,my $location,my $payee,my $description,my $method,my $amount) = split('","',$_);

   my $pdate = ParseDate($date);
   my $day_of_week = UnixDate($pdate,'%w');
   my $day_of_month = UnixDate($pdate,'%e');
   my $day_of_year = UnixDate($pdate,'%j');
   my $week_of_year = UnixDate($pdate,'%W');
   my $month_of_year = UnixDate($pdate,'%m');
   my $year = UnixDate($pdate,'%Y');
   print "$amount; $date - $year, $month_of_year, $week_of_year, $day_of_week, $day_of_month, $day_of_year\n";

   my @desc_arr = split(" ",$description);
   #print join(",",@desc_arr) . "\n";
   $word_hash{$date} = $word_hash{$date} . "$tid,";
   $word_count{$date}++;
   foreach my $word (@desc_arr) {
      $word_hash{$word} = $word_hash{$word} . "$tid,";
      $word_count{$word}++;
   }
   #print "$category\n";
   #print "$description\n";
   #print "$amount\n";
}

my $last = "";
foreach my $word (sort {$word_hash{$a} cmp $word_hash{$b}} keys %word_hash) {
   if($word_count{$word} < 2) {
      next;
   }
   #print "$word - $word_hash{$word}\n";
   if($word_hash{$word} ne $last) {
      print "\n";
   } else {
      print " ";
   }
   print "$word ($word_count{$word})";
   $last = $word_hash{$word};
}

