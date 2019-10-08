requires 'Mojolicious', '8.0';
requires 'Mojolicious::Plugin::RevealJS';

on develop => sub {
  requires 'Mojolicious::Plugin::Export';
};

