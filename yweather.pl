#!/usr/bin/perl

#################################################################
# Yahoo Weather Rss Information Atomizer
# Version 0.7.7
# loudbit.co
# daniel.baucom@loudbit.co
# Provided As Is
#################################################################

use strict;
use XML::XPath;
use LWP::Simple;
use XML::XPath::XMLParser;
use Getopt::Long;
use File::Copy;

#################################################################
# Variables
#################################################################
# Constants (Change these to localize)
my $zipcode = "29301";
my $unit = "F";
my $scripthome = "/Users/<user>/bin/yweather-dir/";
my $icondir = $scripthome."images/";
my $datadir = $scripthome."data/";
my $datafile = $datadir."weather.xml";
my $imagefile = $icondir."weather.png";

# Constants (Do not change these)
my $pre="yweather";
my $uri="http://xml.weather.yahoo.com/ns/rss/1.0";
my $url="http://xml.weather.yahoo.com/forecastrss?p=$zipcode&u=$unit";
my %data;
my $xp;

#################################################################
# Subroutines
#################################################################
# Print usage
sub usage {
	print "Yahoo Weather Information\n\n";
	print "Usage:\n";
	print "	./yweather.pl -ct	Displays current temperature\n\n";
	print "Arguments: \n";
	print "	-lc 			City	\n";
	print "	-lr			Region\n";
	print "	-lt			Country\n";
	print "	-cc			Weather Code (used for images)\n";
	print "	-ct			Current Temperature\n";
	print "	-cw			Current Weather Description\n";
	print "	-cd			Current Date\n";
	print "	-ah			Current Humidity\n";
	print "	-av			Current Visibilty\n";
	print "	-ap			Current Barometric Pressure\n";
	print "	-ar			Change in Barometric Pressure\n";
	print "	-sr			Time of Sunrise\n";
	print "	-ss			Time of Sunset\n";
	print "	-wc			Current Wind Chill\n";
	print "	-wd			Current Wind Direction\n";
	print "	-ws			Current Wind Speed\n";
	print "	-ut			Temperature Unit\n";
	print "	-ud			Distance Unit\n";
	print "	-up			Pressure Unit \n";
	print "	-us			Speed Unit\n";
	print "	-fd1			Today's Day\n";
	print "	-fg1			Today's Date\n";
	print "	-fl1			Today's Low Temp\n";
	print "	-fh1			Today's High Temp\n";
	print "	-ft1			Today's Description\n";
	print "	-fc1			Today's Weather Code\n";
	print "	-fd2			Tomorrow's Day\n";
	print "	-fg2			Tomorrow's Date\n";
	print "	-fl2			Tomorrow's Low Temp\n";
	print "	-fh2			Tomorrow's High Temp\n";
	print "	-ft2			Tomorrow's Description\n";
	print "	-fc2			Tomorrow's Weather Code\n";
	print "	--copyimage		Copy Appropriate Image to Current Image (deprecated)\n";
	print "	--update		Update xml source file\n"	;
	print "	\n";
	print "All data is returned without units. To get data with units,\n";
	print "use a combination of commands.\n\n";
	print "Example: (Displays Current temperature with unit)\n";
	print "	./yweather.pl -ct && ./yweather.pl -ut\n";
}

# Print data
sub args{
	my ($arg) = @_;
	print $data{$arg} . "\n";
}

# Subroutine to update xml data from yahoo
sub update_weather {
 	LWP::Simple::getstore($url,$datafile);
}

# Subroutine to download images from yahoo
sub get_images {
	my $imgurl = "http://l.yimg.com/a/i/us/nws/weather/gr/";
	for (0..47) {
		LWP::Simple::getstore($imgurl.$_."d.png",$icondir.$_."d.png");
		LWP::Simple::getstore($imgurl.$_."n.png",$icondir.$_."n.png");
	}
}

# Parse XML
sub get_data {
	my $ret;
	my($element, $attribute, $index) = @_;
	if ($index){$index=1;}
	
	my $nodeset = $xp->find("//yweather:$element");
	my $node = $nodeset->get_node($index);
	$ret = $node->getAttribute($attribute);
	return $ret;
}

# Copy correct image to the image define in $imagefile
sub copy_image {
	my ($second, $minute, $hour, $dayOfMonth, $month, 
		$yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	my $night = $data{'ss'};
	my $morning = $data{'sr'};
	my $imagesub;
   if ($hour > 11){
		if(($hour-12) < int(substr($night,0,1))){
			$imagesub = "d";
		}elsif(($minute) < int(substr($night,2,3))){
			$imagesub = "d";
		}else{
			$imagesub = "n";
		}
	} else {
		if(($hour) < int(substr($morning,0,1))){
			$imagesub = "n";
		}elsif(($minute) < int(substr($morning,2,3))){
			$imagesub = "n";
		}else{
			$imagesub = "d";
		}
	}
	File::Copy::copy($icondir.$data{'cc'}.$imagesub.".png", $imagefile) 
		or die $icondir . $data{'cc'}.$imagesub.".png" . " could not be copied to " . 
		$imagefile;
}

#################################################################
# Check that files exist
#################################################################
#ensure directories exist
unless(-d $datadir){
    mkdir $datadir or die;
}
unless(-d $icondir){
    mkdir $icondir or die;
}

# Check if images exist
if (!(-e $icondir."0d.png")){get_images()}

# Check if weather.xml exists
if (!(-e $datafile)){update_weather()}
$xp = XML::XPath->new(filename => $datafile);
$xp->set_namespace($pre, $uri);


#################################################################
# Data Setup
#################################################################
# Location Information
$data{'lc'} = get_data("location","city");
$data{'lr'} = get_data("location","region");
$data{'lt'} = get_data("location","country");

# Current Weather Information
$data{'cc'} = get_data("condition","code");
$data{'ct'} = get_data("condition","temp");
$data{'cw'} = get_data("condition","text");
$data{'cd'} = get_data("condition","date");

# Current Atmosphere Information 
$data{'ah'} = get_data("atmosphere","humidity");
$data{'av'} = get_data("atmosphere","visibility");
$data{'ap'} = get_data("atmosphere","pressure");
$data{'ar'} = get_data("atmosphere","rising");

# Todays Sunrise and sunset
$data{'sr'} = get_data("astronomy","sunrise");
$data{'ss'} = get_data("astronomy","sunset");

# Current wind information
$data{'wc'} = get_data("wind","chill");
$data{'wd'} = get_data("wind","direction");
$data{'ws'} = get_data("wind","speed");

# Unit information
$data{'ut'} =get_data("units","temperature");
$data{'ud'} =get_data("units","distance");
$data{'up'} =get_data("units","pressure");
$data{'us'} =get_data("units","speed");

# Forecast (Today)
$data{'fd1'} =get_data("forecast[1]","day");
$data{'fg1'} =get_data("forecast[1]","date");
$data{'fl1'} =get_data("forecast[1]","low");
$data{'fh1'} =get_data("forecast[1]","high");
$data{'ft1'} =get_data("forecast[1]","text");
$data{'fc1'} =get_data("forecast[1]","code");

# Forecast (Tomorrow)
$data{'fd2'} =get_data("forecast[2]","day");
$data{'fg2'} =get_data("forecast[2]","date");
$data{'fl2'} =get_data("forecast[2]","low");
$data{'fh2'} =get_data("forecast[2]","high");
$data{'ft2'} =get_data("forecast[2]","text");
$data{'fc2'} =get_data("forecast[2]","code");

# Check if image exist
if (!(-e $imagefile)){copy_image()}

#################################################################
# Parse arguments
#################################################################
if(($#ARGV + 1) == 1){
	my $arg = substr($ARGV[0],1);
	if (defined($data{$arg})){
		args($arg);
	} elsif($arg eq "-update"){
		update_weather();
	} elsif($arg eq "-copyimage"){
		copy_image();
	} else {
		usage();
	}
} else {
	usage();
}
