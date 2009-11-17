# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT - Apache::ASP Toolkit module

=head1 SYNOPSIS

=begin 

 <AAT:PageTop title="Apache::ASP Toolkit Demo" />
 <AAT:Button name="dialog_ok" />
 <AAT:Button name="dialog_cancel" />
 <AAT:Label value="_MONDAY" color="red" tooltip="1st day of the week" />
 <AAT:Label value="label bold blue" color="blue" style="bold" />
 <AAT:Label value="label size +2" color="green" size="+2" />
 <AAT:Entry name="name" value="write what you want" size=40 />
 <AAT:Password name="password" value="" size=40 /><br>
 <AAT:TextArea name="tarea" cols=80 rows=10 data="your data" /><br>
 <AAT:PageBottom credits="1" />

=head1 DESCRIPTION
	
AAT is useful to create Web Interface rapidly and easily.

Features:

=item * Integrated User Authentication/Role

=item * Integrated Database Functions

=item * Integrated XML Read/Write (with Cache) Functions

=item * Multilanguage 

=item * Themable

=cut

package AAT;

use strict;
use warnings;
use Readonly;

use File::Path;
use LWP;
use AAT::Application;
use AAT::Certificate;
use AAT::Datetime;
use AAT::DB;
use AAT::File;
use AAT::FS;
use AAT::LDAP;
use AAT::List;
use AAT::NSCA;
use AAT::Object;
use AAT::Proxy;
use AAT::SMTP;
use AAT::Syslog;
use AAT::Theme;
use AAT::Translation;
use AAT::User;
use AAT::WebService;
use AAT::XML;
use AAT::XMPP;
use AAT::Zabbix;

Readonly my $FILE_DEBUG => '/var/run/aat/AAT.debug';

=head1 FUNCTIONS

=head2 DEBUG($text)

Prints Debug Message $text in AAT Debug file

=cut

sub DEBUG
{
  my $text = shift;
  $text =~ s/"//g;

  my ($sec, $min, $hour) = localtime();

  if (defined open(my $FILE, '>>', $FILE_DEBUG))
  {
    print $FILE "$hour:$min:$sec > $text\n";
    close($FILE);
  }

  return ("$hour:$min:$sec > $text");
}

=head2 NOT_NULL($value)

Checks that value '$value' is not null (undef or '')

=cut

sub NOT_NULL
{
  my $value = shift;

  if (ref $value eq 'ARRAY')
  {
    return (
      scalar(@{$value}) > 1
      ? 1
      : (((scalar(@{$value}) == 1) && (AAT::NOT_NULL(${$value}[0]))) ? 1 : 0)
    );
  }

  return (((defined $value) && ($value ne '')) ? 1 : 0);
}

=head2 NULL($value)

Checks that value '$value' is null (undef or '')

=cut

sub NULL
{
  my $value = shift;

  if (ref $value eq 'ARRAY')
  {
    return (
      scalar(@{$value}) > 1
      ? 0
      : (((scalar(@{$value}) == 1) && (AAT::NOT_NULL(${$value}[0]))) ? 0 : 1)
    );
  }

  return (((defined $value) && ($value ne '')) ? 0 : 1);
}

=head2 ARRAY($value)

Converts $value to an array ( @{$value) )

=cut

sub ARRAY
{
  my $value = shift;

  return (
    (
      NOT_NULL($value)
      ? ((ref $value eq 'ARRAY') ? @{$value} : ("$value"))
      : ()
    )
  );
}

=head2 ARRAY_REF($value)

Converts $value to an array reference ( \@{$value} )

=cut

sub ARRAY_REF
{
  my $value = shift;

  return (
    (
      NOT_NULL($value)
      ? ((ref $value eq 'ARRAY') ? \@{$value} : ["$value"])
      : []
    )
  );
}

=head2 HASH($value)

Converts $value to an hash ( %{$value} )

=cut

sub HASH
{
  my $value = shift;

  return ((AAT::NOT_NULL($value)) ? %{$value} : ());
}

=head2 HASH_KEYS($value)

Returns keys for the converted hash $value ( keys %{$value} )

=cut

sub HASH_KEYS
{
  my $value = shift;

  return ((AAT::NOT_NULL($value)) ? keys %{$value} : ());
}

=head2 Padding($str, $padding)

Fills the string $str with '0' to have $padding characters 
( ex: Padding("7", 3) returns "007" )

=cut

sub Padding
{
  my ($str, $padding) = @_;
  $padding ||= 3;

  return (('0' x ($padding - length($str))) . $str);
}

=head2 Directory($dir)

Returns Configuration Directory for directory '$dir'

=cut

sub Directory
{
  my $dir = shift;

  return (AAT::Application::Directory('AAT', $dir));
}

=head2 File($file)

Returns Configuration filename for file '$file'

=cut

sub File
{
  my $file = shift;

  return (AAT::Application::File('AAT', $file));
}

=head2 Download($appli, $download, $dest)

Downloads $download to local $dest

=cut

sub Download
{
  my ($appli, $download, $dest) = @_;
  my $pc = AAT::Proxy::Configuration($appli);
  my $proxy =
      (NOT_NULL($pc->{server}) ? "http://$pc->{server}" : '')
    . (NOT_NULL($pc->{port})   ? ":$pc->{port}"         : '');

  my $ua = LWP::UserAgent->new;
  $ua->agent($appli);
  $ua->proxy('http', $proxy);
  my $req = HTTP::Request->new(GET => $download);
  my $res = $ua->request($req);
  if ($res->is_success)
  {
    if (defined open(my $FILE, '>', $dest))
    {
      print $FILE $res->content;
      close($FILE);
      return ($dest);
    }
  }
  else
  {
    $download =~ s/\%\d\d/ /g;    # '%' is not good for sprintf used by syslog
    AAT::Syslog($appli, 'DOWNLOAD_FAILED', $download);
  }

  return (undef);
}

=head2 Update_Configuration($appli, $file, $conf, $rootname)

=cut

sub Update_Configuration
{
  my ($appli, $file, $conf, $rootname) = @_;

  my $file_xml = AAT::Application::File($appli, $file);
  if (NOT_NULL($file_xml))
  {
    AAT::XML::Write($file_xml, $conf, $rootname);
  }
}

=head2 Version()

Returns AAT Version

=cut

sub Version
{
  my $info = AAT::Application::Info('AAT');

  return ($info->{version});
}

=head2 WebSite()

Returns AAT WebSite

=cut

sub WebSite
{
  my $info = AAT::Application::Info('AAT');

  return ($info->{website});
}

=head2 Language($lang)

Get/Set AAT Language

=cut

sub Language
{
  my $lang = shift;

  $main::Session->{AAT_LANGUAGE} = (NOT_NULL($lang) ? $lang : 'EN');

  return ($main::Session->{AAT_LANGUAGE});
}

=head2 Menu_Mode($mode)

Get/Set AAT Menu Mode (Icons&Text, IconsOnly, TextOnly)

=cut

sub Menu_Mode
{
  my $mode = shift;

  $main::Session->{AAT_MENU_MODE} = (NOT_NULL($mode) ? $mode : 'ICONS_AND_TEXT');

  return ($main::Session->{AAT_MENU_MODE});
}

=head2 Theme($theme)

Get/Set AAT Theme

=cut

sub Theme
{
  my $theme = shift;

  $main::Session->{AAT_THEME} = (NOT_NULL($theme) ? $theme : 'DEFAULT');

  return ($main::Session->{AAT_THEME});
}

=head2 Translation($str)

Translates $str with language $main::Session->{AAT_LANGUAGE}

=cut

sub Translation
{
  my $str       = shift;
  my $sess_lang = $main::Session->{AAT_LANGUAGE};
  my $lang      = (NOT_NULL($sess_lang) ? $sess_lang : 'EN');

  return (AAT::Translation::Get($lang, $str));
}

=head2 Syslog($module, $msg, @args)


=cut

sub Syslog
{
  my ($module, $msg, @args) = @_;

  AAT::Syslog::Message($module, $msg, @args);
}

##################################################

=head2 PageTop($args, $body)

Usage: <AAT:PageTop title="Octopussy Login" icon="IMG/octopussy.gif" />

=cut

sub PageTop
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_PageTop.inc', %{$args});
}

=head2 PageBottom($args, $body)

Usage: <AAT:PageBottom credits="1" />

=cut

sub PageBottom
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_PageBottom.inc', %{$args});
}

=head2 PageTheme($args, $body)

Usage: <AAT:PageTheme />

=cut

sub PageTheme
{
  my ($args, $body) = @_;
  my $theme = Theme();
  my $style = AAT::Theme::CSS_File($theme);
  if (defined $style)
  {
    $main::Response->Include('AAT/INC/AAT_CSS_Inc.inc', file => $style);
  }
}

=head2 Inc($args, $body)

Usage: <AAT:Inc file="octo_selector_taxonomy" name="taxonomy"
        selected="$r_taxo" any="1" />

=cut

sub Inc
{
  my ($args, $body) = @_;

  $main::Response->Include("INC/$args->{file}.inc", %{$args});
}

=head2 CSS_Inc($args, $body)

Usage:

=cut

sub CSS_Inc
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_CSS_Inc.inc', %{$args});
}

=head2 JS_Inc($args, $body)

Usage: <AAT:JS_Inc file="INC/AAT_tooltip.js" />

=cut

sub JS_Inc
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_JS_Inc.inc', %{$args});
}

=head2 File_Save($conf)

=cut 

sub File_Save
{
  my $conf = shift;

  $main::Response->{ContentType} = $conf->{contenttype};
  $main::Response->AddHeader('Content-Disposition',
    "filename=\"$conf->{output_file}\"");
  if (AAT::NOT_NULL($conf->{input_file}))
  {
    if (defined open(my $FILE, '<', $conf->{input_file}))
    {
      while (<$FILE>) { $main::Response->BinaryWrite($_); }
      close($FILE);
    }
  }
  elsif (AAT::NOT_NULL($conf->{input_data}))
  {
    $main::Response->BinaryWrite($conf->{input_data});
  }
  $main::Response->End();
}

=head2 Button($args, $body)

Usage: <AAT:Button name="remove" popup_link="$remove_link" />

=cut

sub Button
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Button.inc', %{$args});
}

=head2 Box($args, $body)

Usage: <AAT:Box icon="buttons/bt_report" title="_REPORTS_VIEWER">
       <AAT:BoxRow><AAT:BoxCol>
       ...
       </AAT:BoxCol></AAT:BoxRow>
       </AAT:Box>

=cut

sub Box
{
  my ($args, $body) = @_;
  $main::Response->Include('AAT/INC/AAT_BoxTop.inc', %{$args});
  print $body;
  $main::Response->Include('AAT/INC/AAT_BoxBottom.inc');
}

=head2 BoxCol($args, $body)

Usage: <AAT:BoxRow><AAT:BoxCol>
       ...
       </AAT:BoxCol></AAT:BoxRow>

=cut

sub BoxCol
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_BoxColBegin.inc', %{$args});
  print $body;
  $main::Response->Include('AAT/INC/AAT_BoxColEnd.inc');
}

=head2 BoxRow($args, $body)

Usage: <AAT:BoxRow><AAT:BoxCol>
       ...
       </AAT:BoxCol></AAT:BoxRow>

=cut

sub BoxRow
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_BoxRowBegin.inc', %{$args});
  print $body;
  $main::Response->Include('AAT/INC/AAT_BoxRowEnd.inc');
}

=head2 BoxRowMenu($args, $body)

Usage: <AAT:BoxRowMenu><AAT:BoxCol>
       ...
       </AAT:BoxCol></AAT:BoxRowMenu>

=cut

sub BoxRowMenu
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_BoxRowMenu.inc', %{$args});
  print $body;
  $main::Response->Include('AAT/INC/AAT_BoxRowEnd.inc');
}

=head2 DD_Box($args, $body)

Usage:

=cut

sub DD_Box
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_DD_BoxTop.inc', %{$args});
  print $body;
  $main::Response->Include('AAT/INC/AAT_DD_BoxBottom.inc');
}

=head2 DD_BoxRow($args, $body)

Usage:

=cut

sub DD_BoxRow
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_DD_BoxRowBegin.inc', %{$args});
  print $body;
  $main::Response->Include('AAT/INC/AAT_DD_BoxRowEnd.inc');
}

=head2 CheckBox($args, $body)

Usage: <AAT:CheckBox name="$value" />

=cut

sub CheckBox
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_CheckBox.inc', %{$args});
}

=head2 CheckBox_DayOfMonth($args, $body)

Usage: <AAT:CheckBox_DayOfMonth name="$value" />

=cut

sub CheckBox_DayOfMonth
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_CheckBox_DayOfMonth.inc', %{$args});
}

=head2 CheckBox_DayOfWeek($args, $body)

Usage: <AAT:CheckBox_DayOfWeek name="$value" />

=cut

sub CheckBox_DayOfWeek
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_CheckBox_DayOfWeek.inc', %{$args});
}

=head2 CheckBox_Month($args, $body)

Usage: <AAT:CheckBox_Month name="$value" />

=cut

sub CheckBox_Month
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_CheckBox_Month.inc', %{$args});
}

=head2 Config_Certificate($args, $body)

Usage: <AAT:Config_Certificate tooltip="_TOOLTIP_SYSTEM_CERTIFICATE" />

=cut

sub Config_Certificate
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_Certificate.inc', %{$args});
}

=head2 Config_Database($args, $body)

Usage: <AAT:Config_Database tooltip="_TOOLTIP_SYSTEM_DB" />

=cut

sub Config_Database
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_Database.inc', %{$args});
}

=head2 Config_LDAP_Contacts($args, $body)

Usage: <AAT:Config_LDAP_Contacts tooltip="_TOOLTIP_SYSTEM_LDAP" />

=cut

sub Config_LDAP_Contacts
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_LDAP_Contacts.inc', %{$args});
}

=head2 Config_LDAP_Users($args, $body)

Usage: <AAT:Config_LDAP_Users tooltip="_TOOLTIP_SYSTEM_LDAP" />

=cut

sub Config_LDAP_Users
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_LDAP_Users.inc', %{$args});
}

=head2 Config_NSCA($args, $body)

Usage: <AAT:Config_NSCA tooltip="_TOOLTIP_SYSTEM_NSCA" />

=cut

sub Config_NSCA
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_NSCA.inc', %{$args});
}

=head2 Config_Proxy($args, $body)

Usage: <AAT:Config_Proxy tooltip="_TOOLTIP_SYSTEM_PROXY" />

=cut

sub Config_Proxy
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_Proxy.inc', %{$args});
}

=head2 Config_SMTP($args, $body)

Usage: <AAT:Config_SMTP tooltip="_TOOLTIP_SYSTEM_SMTP" />

=cut

sub Config_SMTP
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_SMTP.inc', %{$args});
}

=head2 Config_XMPP($args, $body)

Usage: <AAT:Config_XMPP tooltip="_TOOLTIP_SYSTEM_JABBER" />

=cut

sub Config_XMPP
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_XMPP.inc', %{$args});
}

=head2 Config_Zabbix($args, $body)

Usage: <AAT:Config_Zabbix tooltip="_TOOLTIP_SYSTEM_ZABBIX" />

=cut

sub Config_Zabbix
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Config_Zabbix.inc', %{$args});
}

=head2 Entry($args, $body)

Usage: <AAT:Entry name="directory" size="40" />

=cut

sub Entry
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Entry.inc', %{$args});
}

=head2 Export_FTP($args, $body)

Usage: <AAT:Export_FTP width="100%" />

=cut

sub Export_FTP
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Export_FTP.inc', %{$args});
}

=head2 Export_SCP($args, $body)

Usage: <AAT:Export_SCP width="100%" />

=cut

sub Export_SCP
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Export_SCP.inc', %{$args});
}

=head2 Form($args, $body)

Usage: <AAT:Form method="POST" action="$action">

=cut

sub Form
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Form_Begin.inc', %{$args});
  print $body;
  $main::Response->Include('AAT/INC/AAT_Form_End.inc', %{$args});
}

=head2 Form_Button($args, $body)

Usage: <AAT:Form_Button name="remove" value="remove_template" />

=cut

sub Form_Button
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Form_Button.inc', %{$args});
}

=head2 Form_Hidden($args, $body)

Usage: <AAT:Form_Hidden name="msg_pattern" value="$pattern" />

=cut

sub Form_Hidden
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Form_Hidden.inc', %{$args});
}

=head2 Form_Submit($args, $body)

Usage: <AAT:Form_Submit value="_EDIT" />

=cut

sub Form_Submit
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Form_Submit.inc', %{$args});
}

=head2 Help($args, $body)

Usage: <AAT:Help page="login" />

=cut

sub Help
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Help.inc', %{$args});
}

=head2 IMG($args, $body)

Usage: <AAT:IMG name="mime/pdf" tooltip="_REPORT_PDF"
        link="${url_base}&filename=$report.$ext" />

=cut

sub IMG
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_IMG.inc', %{$args});
}

=head2 Label($args, $body)

Usage: <AAT:Label value="_MODIFICATION" style="B" />

=cut

sub Label
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Label.inc', %{$args});
}

=head2 Logo($args, $body)

Usage: 

Print Logo of the item $args{name} from the List $args{list}

=cut

sub Logo
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Logo.inc', %{$args});
}

=head2 Menu($args, $body)

Usage: <AAT:Menu align="C" items=\@items />

=cut

sub Menu
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Menu.inc', %{$args});
}

=head2 Message($args, $body)

Usage: <AAT:Message level="$level" msg="$msg" />

=cut

sub Message
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Message.inc', %{$args});
}

=head2 Msg_Error()

Usage:

=cut

sub Msg_Error
{
  if (NOT_NULL($main::Session->{AAT_MSG_ERROR}))
  {
    print '<div align=\"center\">\n';
    $main::Response->Include(
      'AAT/INC/AAT_Message.inc',
      level => 2,
      msg   => $main::Session->{AAT_MSG_ERROR}
    );
    print '</div>\n';
  }
  $main::Session->{AAT_MSG_ERROR} = undef;
}

=head2 Password($args, $body)

Usage: <AAT:Password name="pword" value="$pwd" size="12" />

=cut

sub Password
{
  my ($args, $body) = @_;

  $main::Response->Include(
    'AAT/INC/AAT_Password.inc',
    name      => $args->{name},
    value     => $args->{value},
    size      => $args->{size},
    maxlength => $args->{maxlength}
  );
}

=head2 Picture($args, $body)

Usage: <AAT:Picture file="IMG/octopussy.gif" width="200"
        alt="Octopussy Logo" />

=cut

sub Picture
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Picture.inc', %{$args});
}

=head2 ProgressBar($args, $body)

Usage: <AAT:ProgressBar title="Report Generation $reportname"
        msg="Report Generation: $reportname" desc=$desc 
        current=$cur total=$total
        cancel="./report_in_progress.asp?cancel=yes&pid=$pid" />

=cut

sub ProgressBar
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_ProgressBar.inc', %{$args});
}

=head2 RRD_Graph($args, $body)

Usage: <AAT:RRD_Graph url="./index.asp" name="syslog_dtype" mode="$rrd_mode" />

=cut

sub RRD_Graph
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_RRD_Graph.inc', %{$args});
}

=head2 Selector($args, $body)

Usage: <AAT:Selector name="report" list=\@report_list />

=cut

sub Selector
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector.inc', %{$args});
}

=head2 Selector_Color($args, $body)

Usage: <AAT:Selector_Color name="color" selected="red" />

=cut

sub Selector_Color
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_Color.inc', %{$args});
}

=head2 Selector_Country_Code($args, $body)

Usage: <AAT:Selector Country_Code name="country" selected="fr" />

=cut

sub Selector_Country_Code
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_Country_Code.inc', %{$args});
}

=head2 Selector_Database($args, $body)

Usage: <AAT:Selector_Database name="db_type" selected="$type" />

=cut

sub Selector_Database
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_Database.inc', %{$args});
}

=head2 Selector_Date($args, $body)

Usage: <AAT:Selector_Date name="$name" start_year="1920" />

=cut

sub Selector_Date
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_Date.inc', %{$args});
}

=head2 Selector_DateTime($args, $body)

Usage: <AAT:Selector_DateTime name="dt" start_year="2000"
        url="$url" selected="$selected" />

=cut

sub Selector_DateTime
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_DateTime.inc', %{$args});
}

=head2 Selector_DateTime_Simple($args, $body)

Usage: <AAT:Selector_DateTime_Simple name="dt" 
        start_year="2000" url="$url"
        selected1="$d1/$m1/$y1/$hour1/$min1" 
        selected2="$d2/$m2/$y2/$hour2/$min2" />

=cut

sub Selector_DateTime_Simple
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_DateTime_Simple.inc',
    %{$args});
}

=head2 Selector_EnabledDisabled($args, $body)

Usage: <AAT:Selector_EnabledDisabled name="status" selected="$status" />

=cut

sub Selector_EnabledDisabled
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_EnabledDisabled.inc',
    %{$args});
}

=head2 Selector_Language($args, $body)

Usage: <AAT:Selector_Language />

=cut

sub Selector_Language
{
  my ($args, $body) = @_;
  my $language = Language();
  my @list     = (
    {label => '_ENGLISH',    value => 'EN'},
    {label => '_FRENCH',     value => 'FR'},
    {label => '_GERMAN',     value => 'DE'},
    {label => '_ITALIAN',    value => 'IT'},
    {label => '_PORTUGUESE', value => 'PT'},
    {label => '_RUSSIAN',    value => 'RU'},
    {label => '_SPANISH',    value => 'ES'},
  );

  $main::Response->Include(
    'AAT/INC/AAT_Selector.inc',
    name     => 'AAT_Language',
    list     => \@list,
    selected => $language
  );
}

=head2 Selector_List($args, $body)

Usage:

=cut

sub Selector_List
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_List.inc', %{$args});
}

=head2 Selector_MenuMode($args, $body)

=cut

sub Selector_MenuMode
{
  my ($args, $body) = @_;
  my $mode = Menu_Mode();
  my @list = (
    {label => '_ICONS_AND_TEXT', value => 'ICONS_AND_TEXT'},
    {label => '_ICONS_ONLY',     value => 'ICONS_ONLY'},
    {label => '_TEXT_ONLY',      value => 'TEXT_ONLY'},
  );

  $main::Response->Include(
    'AAT/INC/AAT_Selector.inc',
    name     => 'AAT_MenuMode',
    list     => \@list,
    selected => $mode
  );
}

=head2 Selector_Number($args, $body)
 
Usage: <AAT:Selector_Number name="graph_width"
        min="300" max="3000" step="50" selected="$g_width" />

=cut

sub Selector_Number
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_Number.inc', %{$args});
}

=head2 Selector_Theme($args, $body)

Usage: <AAT:Selector_Theme />

=cut

sub Selector_Theme
{
  my ($args, $body) = @_;
  my $theme  = Theme();
  my @themes = AAT::Theme::List();

  $main::Response->Include(
    'AAT/INC/AAT_Selector.inc',
    name     => 'AAT_Theme',
    list     => \@themes,
    selected => $theme
  );
}

=head2 Selector_Time($args, $body)

Usage: <AAT:Selector_Time name="time_start" step="5" selected="0/0"/>

=cut

sub Selector_Time
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_Time.inc', %{$args});
}

=head2 Selector_User_Role($args, $body)

Usage: <AAT:Selector_User_Role />

=cut

sub Selector_User_Role
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_User_Role.inc', %{$args});
}

=head2 Selector_YesNo($args, $body)

Usage: <AAT:Selector_YesNo name="xmpp_tls" selected="$tls" />

=cut

sub Selector_YesNo
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_Selector_YesNo.inc', %{$args});
}

=head2 TextArea($args, $body)

Usage: <AAT:TextArea name="comment" cols="80" rows="10" />

=cut

sub TextArea
{
  my ($args, $body) = @_;

  $main::Response->Include('AAT/INC/AAT_TextArea.inc', %{$args});
}

1;

=head1 SEE ALSO

AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
