<%
my $login = $Session->{AAT_LOGIN};
my $tpl = $Request->QueryString("template");

my $conf = Octopussy::Search_Template::Configuration($login, $tpl);
my $dev_str = join(",", AAT::ARRAY($conf->{device}));
my $serv_str = join(",", AAT::ARRAY($conf->{service}));
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<template><%= $conf->{name} %></template>
	<device><%= $dev_str %></device>
	<service><%= $serv_str %></service>
  <loglevel><%= $conf->{loglevel} %></loglevel>
  <taxonomy><%= $conf->{taxonomy} %></taxonomy>
  <msgid><%= $conf->{msgid} %></msgid>
  <begin><%= $conf->{begin} %></begin>
  <end><%= $conf->{end} %></end>
	<re_include><%= $conf->{re_include} %></re_include>
  <re_include2><%= $conf->{re_include2} %></re_include2>
  <re_include3><%= $conf->{re_include3} %></re_include3>
	<re_exclude><%= $conf->{re_exclude} %></re_exclude>
  <re_exclude2><%= $conf->{re_exclude2} %></re_exclude2>
  <re_exclude3><%= $conf->{re_exclude3} %></re_exclude3>
</root>
