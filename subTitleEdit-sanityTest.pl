#! /usr/bin/perl
use 5.010;
use open qw(:locale);
use strict;
use utf8;
use warnings qw(all);

#
# run sanity test on subTitleEdit data file
# check if time continuously increases. 
# otherwise, some programs using this data fail
#
# @author am
# open source - MIT License

# to run the test
# perl subTitleEdit-sanityTest.pl < testFiles/DANCE_BLACK_AMERICA_Title_01_01.srt 
# 
# replace the data file with your own
# if there is an error, it will be printed. if there is no error
# nothing will happen
#

# data format
#
# each record has the following pattern
#
# number
# time
# multiple lines of text 
# empty line(s)
#
# repeat

# when state is 1, we are expecting a record number or 
# in the middle of blank lines
# when state is 2, we are expecting the time strings
# when state is 3, we are expecting the caption text (zero or more lines)

my $state = 1; 

my $recordNum;

my $prevTime = -1;
my $prevTimeStr = "";

my $debug = 0;

my ($first, $second);

while(<>) {
    chomp;

    my $line;

    # if empty line, set state to 1, and skip
    $line = $_;


    if ($state == 1) {
        
        if ($line =~ /(\d+)/ ) {
            debugPrint("state=1, matched number ", $line);
            $recordNum = $1;
            $state = 2;
        } 
        elsif ($line =~ /\s*\S/) {
            # error
            print("ERROR: expecting number, found ", $line);
        }
        # else, look for a number in the next line
        else {
           # no op
        }
    }
    elsif ($state == 2) {
        # 00:00:00,301 --> 00:00:04,246
        debugPrint("state=2, line=", $line, "\n");
        
        ($first, $second) = split( /\-\-\>/, $line);

        debugPrint("after split, first=" , $first, " second=" , $second, "\n");
        my ($firstTime) = &timeParser($first);
        my ($secondTime) = &timeParser($second);


        if ($secondTime < $firstTime) {
            # error
            print("ERROR, second less than first! \n", $first, "\n", $second, "\nrecordNum=", $recordNum, "\n");

        } 
        
        elsif($secondTime < $prevTime) {
            # error
            print("ERROR, current record time less than prev! ", $prevTimeStr, " ", $second, " recordNum= ", $recordNum);
       
        } else {
            $prevTime = $secondTime;
            $prevTimeStr = $second;
        }


        $state = 3;

    }
    elsif ($state == 3) {
        # if this is an empty line, current record has ended
        debugPrint("state=3, line=", $line, "\n");
        if ($line =~ /\s*\S+\s*/) {
            # not an empty line
            next;
        }
        else {
            # end of record
            $state = 1;
        }
    }
    else {
        print("ERROR: unknown state");
    }
    
}

sub timeParser {
    # 00:00:00,301
    my ($timeStr) = @_;

    my ($first,$msec ) = split( /,/, $timeStr);
    my ($hr, $min, $sec) = split( /:/, $first);

    debugPrint("timeStr= $timeStr ");
    debugPrint("hr= $hr ");
    debugPrint("min= $min ");
    debugPrint("sec= $sec ");
    debugPrint("msec= $msec ");

    my $totalMsec = $msec + 1000 * ($sec + $min * 60 + $hr * 3600);

    debugPrint("totalMsec= $totalMsec \n");
    my  @result = ($totalMsec);
    return (@result);
}

sub debugPrint {
    if ($debug > 0) {
        print @_;
    }
}
