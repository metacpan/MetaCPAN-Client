requires "Carp" => "0";
requires "HTTP::Tiny" => "0.056";
requires "IO::Socket::SSL" => "1.42";
requires "JSON::MaybeXS" => "0";
requires "JSON::PP" => "0";
requires "Moo" => "0";
requires "Moo::Role" => "0";
requires "Net::SSLeay" => "1.49";
requires "Ref::Util" => "0";
requires "Safe::Isa" => "0";
requires "URI::Escape";
requires "perl" => "5.010";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "Test::Fatal" => "0";
  requires "Test::More" => "0";
  requires "Test::Requires" => "0";
  requires "base" => "0";
  requires "blib" => "1.01";
  recommends "HTTP::Tiny::Mech" => "0";
  recommends "LWP::Protocol::https" => "0";
  recommends "WWW::Mechanize::Cached" => "1.48";
};

on 'develop' => sub {
  requires "HTTP::Tiny::Mech" => "0";
  requires "LWP::Protocol::https" => "0";
  requires "WWW::Mechanize::Cached" => "1.48";
};
