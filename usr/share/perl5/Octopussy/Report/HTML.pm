=head1 NAME

Octopussy::Report::HTML - Octopussy HTML Report module

=cut
package Octopussy::Report::HTML;

use strict;
no strict 'refs';

use Octopussy;

=head1 FUNCTIONS

=head2 CSS($style)

=cut
sub CSS($)
{
	my $style = shift;

	my $css = "";
	my $dir = AAT::Directory("themes");
	open(FILE, " < $dir$style/report_style.css");
	while (<FILE>)
		{ $css .= $_; }
	close(FILE);
	
	return ($css);
}

=head2 Encode($data)

Encodes HTML characters

=cut
sub Encode($)
{
  my $data = shift;

  $data =~ s/&/&amp;/g;
  $data =~ s/</&lt;/g;
  $data =~ s/>/&gt;/g;

  return ($data);
}

=head2 Header($title, $devices, $services, $begin, $end, $fields, 
	$headers, $lang)

Returns Page Header HTML code

=cut
sub Header
{
  my ($title, $devices, $services, $begin, $end, $fields, $headers, $lang) = @_;
	my @cols = split(/,/, $fields);
  my ($b_year, $b_month, $b_day, $b_hour, $b_min) = ($1, $2, $3, $4, $5)
    if ($begin =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/);
  my ($e_year, $e_month, $e_day, $e_hour, $e_min) = ($1, $2, $3, $4, $5)
    if ($end =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/);
		
  my $html .= "<table class=\"report\">\n";
	$html .= "<tr class=\"report\"><td colspan=" . ($#cols+1) 
		. " class=\"report\">\n";
	$html .= "<b>" . AAT::Translation::Get($lang, "_TITLE") 
		. ":</b> " . Encode($title) . "</td></tr>";
	$html .= "<tr class=\"report\"><td colspan=" . ($#cols+1)
	    . " class=\"report\">\n";
	$html .= "<b>" . AAT::Translation::Get($lang, "_DEVICES")
	    . ":</b> " . Encode(join(", ", @{$devices})) . "</td></tr>";
	$html .= "<tr class=\"report\"><td colspan=" . ($#cols+1)
      . " class=\"report\">\n";
  $html .= "<b>" . AAT::Translation::Get($lang, "_SERVICES")
      . ":</b> " . Encode(join(", ", @{$services})) . "</td></tr>";
  $html .= "<tr class=\"report\"><td colspan=" . ($#cols+1)
		. " class=\"report\">\n";
	$html .= "<b>" . AAT::Translation::Get($lang, "_PERIOD") 
		. ":</b> " . Encode("$b_day/$b_month/$b_year $b_hour:$b_min");
  $html .= " -> " . Encode("$e_day/$e_month/$e_year $e_hour:$e_min");
  $html .= "</td></tr>";
	$html .= "<tr class=\"report\"><td colspan="
		. ($#cols+1) . " class=\"report\"><hr></td></tr>\n";
	my @headers_td = split(/,/, $headers);
  $html .= "<tr class=\"report\"><td class=\"report-header\"><b>" 
		. join("</td><td class=\"report-header\"><b>", @headers_td) 
		. "</b></td></tr>"
		if ($#headers_td >= 0);

  return ("$html\n");
}

=head2 Footer($stats, $fields, $lang)

Returns Page Footer HTML code

=cut
sub Footer($$$)
{
  my ($stats, $fields, $lang) = @_;
	my $minutes = int($stats->{seconds} / 60);
  my $seconds = $stats->{seconds} % 60;
	my @cols = split(/,/, $fields);
	
	my $html .= "<tr class=\"report\"><td colspan=" 
		. ($#cols+1) . " class=\"report\"><hr></td></tr>\n";
	$html .= "<tr class=\"report\"><td colspan="
		. ($#cols+1) . " class=\"report\"><font size=-2>\n";
  $html .= AAT::Translation::Get($lang, "_MSG_REPORT_GENERATED_BY") 
		. " v" . Octopussy::Version() . "</font></td></tr>\n";
	$html .= "<tr class=\"report\"><td colspan="
		. ($#cols+1) . " class=\"report\"><font size=-2>\n";
	$html .= sprintf(AAT::Translation::Get($lang, "_MSG_REPORT_DATA_SOURCE"), 
		$stats->{nb_files}, $stats->{nb_lines}, $minutes, $seconds);
	$html .= "</font></td></tr>\n";
  $html .= "</table>\n";

  return ($html);
}

=head2 Generate($file, $title, $begin, $end, $devices, $services, 
	$data, $fields, $headers, $stats, $lang)

=cut
sub Generate
{
  my ($file, $title, $begin, $end, $devices, $services, $data, $fields, 
		$headers, $stats, $lang) = @_;
	my @field_list = split(/,/, $fields);
  my $html = "<html>\n<head>";
	$html .= "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">";
	$html .= "<title>" . Encode($title) . "</title></head>\n";
	$html .= "<body>\n" . CSS("DEFAULT");
	$html .= Header($title, $devices, $services, $begin, $end, 
		$fields, $headers, $lang);

  foreach my $line (@{$data})
  {
    $html .= "<tr class=\"report\">";
    foreach my $f (@field_list)
    {
			my $value = "";
      my $result = Octopussy::Plugin::Field_Data($line, $f);
      if (defined $result)
      {
        if (ref $result eq "ARRAY")
        {
          foreach my $res (@{$result})
          {
            $res = "<a href=\"$1\">$1<\/a>"   if ($res =~ /^(https?:\/\/.+)/);
            $value .= "$res<br>";
          }
        }
        else
        {
          $result = "<a href=\"$1\">$1<\/a>" if ($result =~ /^(https?:\/\/.+)/);
          $value .= $result;
        }
      }
      else
      	{ $value .= Encode($line->{$f} || "N/A"); }
      $html .= "<td class=\"report\" align=\"" 
				. ($value =~ /^\d+(\.\d+)?( \S+)?$/ ? "right" : "left") . "\">$value</td>";
    }
    $html .= "</tr>\n";
  }
  $html .= Footer($stats, $fields, $lang) . "</body>\n</html>";

  open(OUTPUT, "> $file");
  print OUTPUT $html;
  close(OUTPUT);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
